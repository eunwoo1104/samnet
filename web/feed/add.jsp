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
            window.onload = () => {
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
                font-size: 0.9rem;
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
        </style>
    </jsp:attribute>
    <jsp:body>
        <h2>
            피드 추가
        </h2>
        <form>
            <label class="mb-mid">
                오늘 준비한 피드는 뭔가요?
                <textarea name="content" maxlength="4096" required></textarea>
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
            <input class="custom-button mt-xl" type="submit" value="업로드">
        </form>
    </jsp:body>
</t:layout>