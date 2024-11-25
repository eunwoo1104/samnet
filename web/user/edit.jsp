<%@ page import="dao.UserDAO" %>
<%@ page import="dao.UserObj" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<t:layout pageName="프로필 수정" requireLogin="true">
    <jsp:attribute name="head">
        <script>
            const sessionKey = localStorage.getItem("session");
            let setDefaultAvatar = false;
            let userData = null;
            $.ajax(
                {
                    url: "${pageContext.request.contextPath}/api/user",
                    type: "GET",
                    dataType: "json",
                    async: false,
                    beforeSend: xhr => {
                        xhr.setRequestHeader("Authorization", sessionKey);
                    },
                    success: data => {
                        userData = data.data;
                    },
                    error: (xhr, status, error) => {
                        // TODO: different actions per error codes
                        alert("오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
                    }
                }
            );

            function setImgPreview(src, alt) {
                const container = document.getElementById("avatar-container");
                const preview = document.getElementById("avatar-preview");
                while (container.lastChild) {
                    container.removeChild(container.lastChild);
                }

                if (src) {

                    const imgDiv = avatarImage(src, alt, "pf-avatar");
                    container.appendChild(imgDiv);
                    preview.style = null;
                } else {
                    preview.style.display = "none";
                }
            }

            window.onload = () => {
                if (!userData) return;
                const form = document.querySelector("form");
                const nicknameInput = document.getElementById("fn");
                const usernameInput = document.getElementById("fu");
                const bioInput = document.getElementById("fb");
                const avatarInput = document.getElementById("file");
                const resetAvatar = document.getElementById("set-default-avatar");

                nicknameInput.value = userData.nickname;
                usernameInput.value = userData.username;
                bioInput.value = userData.bio;

                if (userData.avatar) {
                    const prevAvatarURL = "${pageContext.request.contextPath}/resource/image?id=" + userData.avatar;
                    setImgPreview(prevAvatarURL, userData.avatar);
                }

                avatarInput.addEventListener("change", event => {
                    if (!event.target.files.length) {
                        setImgPreview(null, null);
                        setDefaultAvatar = true;
                        return;
                    }
                    const tgtImg = event.target.files[0];
                    const imgURL = URL.createObjectURL(tgtImg);
                    setImgPreview(imgURL, tgtImg.name);
                    setDefaultAvatar = false;
                });

                resetAvatar.addEventListener("click", event => {
                    setDefaultAvatar = true;
                    setImgPreview(null, null);
                    avatarInput.value = null;
                })

                form.addEventListener("submit", event => {
                    event.preventDefault();

                    const submitData = new FormData();
                    submitData.append("nickname", event.target.nickname.value);
                    submitData.append("username", event.target.username.value);
                    submitData.append("bio", event.target.bio.value);
                    submitData.append("defaultAvatar", setDefaultAvatar);
                    if (event.target.file.files.length) {
                        [...event.target.file.files].forEach(f => {
                            submitData.append("image", f);
                        });
                    }

                    const editButton = document.getElementById("edit");
                    editButton.disabled = "disabled";

                    $.ajax(
                        {
                            url: "${pageContext.request.contextPath}/api/user",
                            type: "POST",
                            dataType: "json",
                            data: submitData,
                            processData: false,
                            contentType: false,
                            beforeSend: xhr => {
                                xhr.setRequestHeader("Authorization", sessionKey);
                            },
                            success: data => {
                                const msgDiv = document.getElementById("submit-message");
                                msgDiv.children[0].innerText = "수정 성공! 잠시 후 프로필로 이동합니다.";
                                msgDiv.className = "ok-box";
                                msgDiv.style.display = "block";

                                sleep(3 * 1000).then(() => {
                                    window.location.href = "${pageContext.request.contextPath}/user";
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
                                        msg = "프로필 수정 권한이 없습니다.";
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
                                editButton.disabled = null;
                            }
                        }
                    );
                });
            }
        </script>
        <style>
            #submit-message {
                margin-top: 1.25rem;
            }

            #avatar-container {
                display: flex;
                justify-content: center;
                align-items: center;
            }

            #pf-avatar {
                height: 10rem;
                margin: 0.5rem;
            }

            #set-default-avatar {
                background-color: transparent;
                color: lightcoral;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <h2>
            프로필 수정
        </h2>
        <form>
            <label>
                닉네임 (표시할 이름)
                <input class="mb-mid" name="nickname" id="fn" type="text" placeholder="닉네임" required>
            </label>
            <label>
                유저네임
                <input class="mb-mid" name="username" id="fu" type="text" placeholder="유저네임" pattern="^[a-zA-Z0-9]+$" required>
            </label>
            <label>
                소개
                <textarea class="mb-mid" name="bio" id="fb" placeholder="간단한 소개 문구" maxlength="1024"></textarea>
            </label>
            <label>
                프로필 사진
            </label>
            <label class="file-upload-label">
                여기를 눌러 새 프로필 사진 선택...
                <input name="file" id="file" type="file" accept="image/*">
            </label>
            <button class="mt-sm clickable" type="button" id="set-default-avatar">
                기본 프로필 사진 사용하기
            </button>
            <div class="mt-sm" style="display: none" id="avatar-preview">
                <label>프로필 사진 미리보기</label>
                <div id="avatar-container"></div>
            </div>
            <input class="custom-button mt-lg" type="submit" value="수정하기" id="edit">
        </form>
        <div class="mb-mid" style="display: none" id="submit-message">
            <p>placeholder</p>
        </div>
        <p class="mt-mid" style="font-weight: 300; font-size: 0.8rem; margin-bottom: 0.3rem">
            계정 탈퇴는 아래 버튼을 눌러 하실 수 있습니다.
        </p>
        <button class="custom-button" style="color: lightcoral; border-color: lightcoral" onclick="moveto('delete.jsp')">
            계정탈퇴
        </button>
    </jsp:body>
</t:layout>