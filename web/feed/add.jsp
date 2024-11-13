<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%
    if (session.getAttribute("key") == null) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp?redirect=/feed/add.jsp");
        return;
    }
%>
<t:layout pageName="피드 추가">
    <jsp:attribute name="head">
        <script>
            const sessionKey = localStorage.getItem("session");
            if (!sessionKey) {
                alert("세션 오류로 다시 로그인해주세요.");
                moveto("${pageContext.request.contextPath}/user/login.jsp?redirect=/feed/add.jsp");
            }

            window.onload = () => {
                const userInfo = document.getElementById("user-info")
                $.ajax(
                    {
                        url: "${pageContext.request.contextPath}/api/user",
                        type: "GET",
                        dataType: "json",
                        beforeSend: xhr => {
                            xhr.setRequestHeader("Authorization", sessionKey);
                        },
                        success: data => {
                            const user = data.data;
                            userInfo.innerHTML = "<span class='bold'>@" + user.username + "(" + user.email + ")</span>로 로그인됨";
                        },
                        error: (xhr, status, error) => {
                            // TODO: different error messages per error codes
                            alert("세션 오류로 다시 로그인해주세요.");
                            moveto("${pageContext.request.contextPath}/user/login.jsp?redirect=/feed/add.jsp");
                        }
                    }
                )

                const fileInput = document.getElementById("file");
                fileInput.addEventListener("change", event => {
                    const fileLabel = document.getElementById("file-label");
                    const fileContainer = document.getElementById("file-container");
                    const previewContainer = document.getElementById("preview-container");
                    const previews = document.getElementById("previews")

                    while (previews.lastChild) {
                        previews.removeChild(previews.lastChild);
                    }

                    if (event.target.files.length) {
                        let fileList = "";
                        // console.log(event.target.files);
                        [...event.target.files].forEach(f => {
                            // console.log(f)
                            fileList += f.name + "<br>";
                            const imgURL = URL.createObjectURL(f);
                            const imgChild = document.createElement("img");
                            imgChild.setAttribute("src", imgURL);
                            imgChild.setAttribute("alt", f.name);
                            imgChild.className = "preview-item";
                            previews.appendChild(imgChild);
                        });
                        fileLabel.innerHTML = fileList;
                        fileLabel.className = "file-names";
                        fileContainer.style.textAlign = "start";

                        previewContainer.style.display = "block";
                    } else {
                        fileLabel.innerHTML = "여기서 이미지 첨부...";
                        fileLabel.className = null;
                        fileContainer.style.textAlign = "center";

                        previewContainer.style.display = "none";
                    }
                });

                const form = document.querySelector("form");
                form.addEventListener("submit", event => {
                    // don't use redirect
                    event.preventDefault();

                    const submitData = new FormData();
                    submitData.append("content", event.target.content.value);
                    if (event.target.file.files.length) {
                        [...event.target.file.files].forEach(f => {
                            submitData.append("image", f);
                        });
                    }

                    const upload = document.getElementById("upload");
                    upload.disabled = "disabled";

                    $.ajax(
                        {
                            url: "${pageContext.request.contextPath}/api/feed",
                            type: "POST",
                            dataType: "json",
                            data: submitData,
                            processData: false,
                            contentType: false,
                            beforeSend: xhr => {
                                xhr.setRequestHeader("Authorization", sessionKey);
                            },
                            success: data => {
                                const feedId = data.data.id;
                                const msgDiv = document.getElementById("submit-message");
                                msgDiv.children[0].innerText = "업로드 성공! 잠시 후 피드로 이동합니다.";
                                msgDiv.className = "ok-box";
                                msgDiv.style.display = "block";

                                sleep(3 * 1000).then(() => {
                                    window.location.href = "${pageContext.request.contextPath}/feed/index.jsp?id=" + feedId;
                                });
                            },
                            error: (xhr, status, error) => {
                                // console.log(xhr);
                                const data = xhr.responseJSON;
                                let msg = "";
                                switch (data.code) {
                                    case "NO_SESSION":
                                    case "INVALID_SESSION":
                                        msg = "로그인 정보에 오류가 있습니다. 다시 로그인해주세요.";
                                        break;
                                    case "USER_BLOCKED":
                                        msg = "피드 추가 권한이 없습니다.";
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
                                msgDiv.className = "error-box";
                                msgDiv.style.display = "block";
                                upload.disabled = null;
                            }
                        }
                    );
                });
            }
        </script>
        <style>
            textarea {
                height: 10rem;
                resize: none;
            }

            .upload-label {
                width: 100%;
                box-sizing: border-box;
                padding: 0.5rem;
                background-color: #1b1e23;
                border-radius: 0.25rem;
                outline: none;
                border-width: 2px;
                border-style: dashed;
                border-color: dimgrey;
                color: snow;
                caret-color: snow;
                text-align: center;
                font-weight: 300;
                font-size: 0.8rem;
            }

            .upload-label:hover {
                opacity: 75%;
                cursor: pointer;
            }

            .upload-label:focus-visible {
                opacity: 75%;
            }

            .file-names {
                font-weight: 300;
                font-size: 0.8rem;
                color: #fbfbfb;
                opacity: 75%;
            }

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

            .user-info-container {
                display: flex;
                flex-direction: column;
            }

            .user-info {
                font-size: 0.8rem;
                opacity: 80%;
            }

            #submit-message {
                padding: 1.25rem;
                margin-top: 1.25rem;
                font-weight: 700;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <h2>
            피드 추가
        </h2>
        <div class="user-info-container mb-sm">
            <p class="user-info" id="user-info"></p>
            <a class="user-info" href="${pageContext.request.contextPath}/user/login.jsp?redirect=/feed/add.jsp">본인이
                아닌가요?</a>
        </div>
        <form>
            <label class="mb-mid">
                오늘 준비한 피드는 뭔가요?
                <textarea name="content" maxlength="4096"></textarea>
            </label>
            <label>첨부할 이미지를 선택해주세요.</label>
            <label class="upload-label mb-mid" id="file-container">
                <span id="file-label">여기서 이미지 첨부...</span>
                <input name="file" id="file" type="file" accept="image/*" multiple>
            </label>
            <div id="preview-container" style="display: none">
                <label>이미지 미리보기</label>
                <div class="preview" id="previews"></div>
            </div>
            <input class="custom-button mt-lg" type="submit" value="업로드" id="upload">
            <div class="mt-mid" style="display: none" id="submit-message">
                <p>placeholder</p>
            </div>
        </form>
    </jsp:body>
</t:layout>