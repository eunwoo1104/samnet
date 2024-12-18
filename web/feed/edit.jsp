<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%
    request.setCharacterEncoding("UTF-8");

    String feedId = request.getParameter("id");
    if (feedId == null) {
        pageContext.forward("/404.jsp?type=feed");
        return;
    }

    request.setAttribute("feedId", "\"" + feedId + "\"");
%>
<t:layout pageName="피드 수정" requireLogin="true">
    <jsp:attribute name="head">
        <script>
            const sessionKey = localStorage.getItem("session");
            const feedId = ${feedId};
            let imgChanged = null;
            let showImg = false;

            function onError(xhr, status, error) {
                // TODO: different actions per error codes
                alert("오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
            }

            let feed = api("${pageContext.request.contextPath}", true, false)
                .feed.get(feedId, null, onError);

            function resetPreviews(images) {
                const previewContainer = document.getElementById("preview-container");
                const previews = document.getElementById("previews");

                while (previews.lastChild) {
                    previews.removeChild(previews.lastChild);
                }

                if (!images) {
                    previewContainer.style.display = "none";
                    return
                }

                images.forEach(img => {
                    if (!img) return;
                    const imgChild = document.createElement("img");
                    imgChild.setAttribute("src", img.src);
                    imgChild.setAttribute("alt", img.alt);
                    imgChild.className = "preview-item";
                    previews.appendChild(imgChild);
                });

                previewContainer.style.display = "block";
            }

            function showDeleteDiv() {
                const deleteDiv = document.getElementById("delete-feed");
                if (deleteDiv.style.display === "none") {
                    deleteDiv.style.display = "block";
                } else {
                    deleteDiv.style.display = "none";
                }
            }

            function deleteFeed() {
                const deleteButton = document.getElementById("delete-feed-button");
                deleteButton.disabled = "disabled";
                api("${pageContext.request.contextPath}", true, true)
                    .feed.delete(feedId, data => {
                    alert("피드가 정상적으로 삭제되었습니다.");
                    moveto("${pageContext.request.contextPath}/feed");
                }, (xhr, status, error) => {
                    // console.log(xhr);
                    const data = xhr.responseJSON;
                    let msg = "";
                    switch (data.code) {
                        case "NO_SESSION":
                        case "INVALID_SESSION":
                            msg = "로그인 정보에 오류가 있습니다. 다시 로그인해주세요.";
                            break;
                        case "USER_BLOCKED":
                            msg = "피드 삭제 권한이 없습니다.";
                            break;
                        case "INVALID_DATA":
                            msg = "데이터에 오류가 있습니다. 새로고침 후 다시 시도해주세요.";
                            break;
                        case "MISSING_DATA":
                            msg = "피드를 찾을 수 없습니다.";
                            break;
                        default:
                            msg = "알 수 없는 오류가 발생하였습니다.";
                            break;
                    }
                    alert(msg);
                    deleteButton.disabled = null;
                });
            }

            window.onload = () => {
                if (!feed) return;

                const feedContent = document.getElementById("fc");
                feedContent.value = feed.content;

                const fileInput = document.getElementById("file");
                const fileLabel = document.getElementById("file-label");
                const fileContainer = document.getElementById("file-container");
                fileInput.addEventListener("change", event => {
                    imgChanged = true;
                    if (!event.target.files.length) {
                        resetPreviews(null);
                        fileLabel.innerHTML = "여기서 이미지 첨부...";
                        fileLabel.className = null;
                        fileContainer.style.textAlign = "center";
                        return;
                    }

                    let fileList = "";
                    resetPreviews([...event.target.files].map(
                        f => {
                            fileList += f.name + "<br>";
                            const imgURL = URL.createObjectURL(f);
                            return {src: imgURL, alt: f.name};
                        }
                    ));

                    fileLabel.innerHTML = fileList;
                    fileLabel.className = "file-names";
                    fileContainer.style.textAlign = "start";
                });

                const imageResetButton = document.getElementById("remove-images");
                imageResetButton.addEventListener("click", () => {
                    imgChanged = true;
                    fileLabel.innerHTML = "여기서 이미지 첨부...";
                    fileLabel.className = null;
                    fileContainer.style.textAlign = "center";
                    fileInput.value = null;
                    resetPreviews(null);
                });

                if (feed.images) {
                    resetPreviews(feed.images.trim().split(",").map(
                        img => {
                            if (!img) return;
                            return {
                                src: "${pageContext.request.contextPath}/resource/image?id=" + img,
                                alt: img
                            };
                        }
                    ));
                }

                const form = document.querySelector("form");
                form.addEventListener("submit", event => {
                    event.preventDefault();

                    const submitData = new FormData();
                    submitData.append("id", feedId);
                    submitData.append("content", event.target.content.value);
                    submitData.append("imgChanged", imgChanged);
                    if (event.target.file.files.length) {
                        [...event.target.file.files].forEach(f => {
                            submitData.append("image", f);
                        });
                    }

                    const editButton = document.getElementById("edit");
                    editButton.disabled = "disabled";

                    api("${pageContext.request.contextPath}", true, true)
                        .feed.edit(submitData, data => {
                            const msgDiv = document.getElementById("submit-message");
                            msgDiv.children[0].innerText = "수정 성공! 잠시 후 피드로 이동합니다.";
                            msgDiv.className = "ok-box mt-mid";
                            msgDiv.style.display = "block";

                            sleep(3 * 1000).then(() => {
                            moveto("${pageContext.request.contextPath}/feed/view.jsp?id=" + feedId);
                            });
                        }, (xhr, status, error) => {
                            const data = xhr.responseJSON;
                            let msg = "";
                            switch (data.code) {
                                case "NO_SESSION":
                                case "INVALID_SESSION":
                                    msg = "로그인 정보에 오류가 있습니다. 다시 로그인해주세요.";
                                    break;
                                case "USER_BLOCKED":
                                case "NO_PERMISSION":
                                    msg = "피드 수정 권한이 없습니다.";
                                    break;
                                case "INVALID_DATA":
                                    msg = "데이터에 오류가 있습니다. 새로고침 후 다시 시도해주세요.";
                                    break;
                                default:
                                    msg = "알 수 없는 오류가 발생하였습니다.";
                                    break;
                            }
                            const msgDiv = document.getElementById("submit-message");
                            msgDiv.children[0].innerText = msg;
                            msgDiv.className = "error-box mt-mid";
                            msgDiv.style.display = "block";
                            editButton.disabled = null;
                        });
                });
            }
        </script>
        <style>
            .preview {
                display: flex;
                flex-wrap: nowrap;
                overflow-x: scroll;
                overflow-y: hidden;
            }

            .preview-item {
                display: inline-block;
                height: 10rem;
            }

            .file-names {
                font-weight: 300;
                font-size: 0.8rem;
                color: #fbfbfb;
                opacity: 75%;
            }

            #remove-images {
                background-color: transparent;
                color: lightcoral;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <h2>
            피드 수정
        </h2>
        <form>
            <label class="mb-mid">
                피드 내용
                <textarea name="content" maxlength="4096" id="fc"></textarea>
            </label>
            <label>새로 첨부할 이미지를 선택해주세요.<br>신규 이미지 첨부 시 기존 이미지는 삭제됩니다.</label>
            <label class="file-upload-label mb-sm" id="file-container">
                <span id="file-label">여기서 이미지 첨부...</span>
                <input name="file" id="file" type="file" accept="image/*" multiple>
            </label>
            <button class="mb-mid clickable" type="button" id="remove-images">
                이미지 전체 삭제
            </button>
            <div id="preview-container" style="display: none">
                <label>이미지 미리보기</label>
                <div class="preview" id="previews"></div>
            </div>
            <input class="custom-button mt-lg" type="submit" value="피드 수정" id="edit">
            <div class="mt-mid" style="display: none" id="submit-message">
                <p>placeholder</p>
            </div>
        </form>
        <button class="custom-button mt-lg" style="color: lightcoral; border-color: lightcoral"
                onclick="showDeleteDiv()">
            피드 삭제
        </button>
        <div class="mt-mid" style="display: none" id="delete-feed">
            <p>
                정말로 이 피드를 삭제하시겠어요?<br>삭제 후에는
                <span style="color: lightcoral; text-decoration: underline">복구가 불가능합니다.</span><br><br>
                삭제하시려면 아래 버튼을 눌러주세요.
            </p>
            <button class="mt-lg custom-button" style="color: lightcoral; border-color: lightcoral"
                    id="delete-feed-button" onclick="deleteFeed()">
                삭제하기
            </button>
        </div>
    </jsp:body>
</t:layout>