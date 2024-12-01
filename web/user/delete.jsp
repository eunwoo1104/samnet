<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<t:layout pageName="계정탈퇴" requireLogin="true">
    <jsp:attribute name="head">
        <script>
            const sessionKey = localStorage.getItem("session");
            window.onload = () => {
                const deleteButton = document.getElementById("delete-button");
                deleteButton.addEventListener("click", event => {
                    deleteButton.disabled = "disabled";
                    api("${pageContext.request.contextPath}", true, true)
                        .user.delete(data => {
                            const msgDiv = document.getElementById("submit-message");
                            msgDiv.children[0].innerHTML = "탈퇴가 완료되었습니다. 그동안 SamNet을 이용해주셔서 감사합니다.<br>잠시후 로그아웃됩니다.";
                            msgDiv.className = "ok-box";
                            msgDiv.style.display = "block";

                            sleep(3 * 1000).then(() => {
                                moveto("${pageContext.request.contextPath}/user/logout.jsp");
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
                                    msg = "계정탈퇴 권한이 없습니다.";
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
                            deleteButton.disabled = null;
                        });
                });
            }
        </script>
        <style>
            #submit-message {
                margin-top: 1.25rem;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <h2>
            계정탈퇴
        </h2>
        <p>
            정말로 탈퇴하시겠어요?<br>탈퇴 후에는
            <span style="color: lightcoral; text-decoration: underline">모든 데이터 복구가 불가능합니다.</span><br><br>
            동의하신다면 아래 버튼을 눌러주세요.
        </p>
        <button class="mt-lg custom-button" style="color: lightcoral; border-color: lightcoral" id="delete-button">
            계정탈퇴
        </button>
        <div class="mt-mid" style="display: none" id="submit-message">
            <p>placeholder</p>
        </div>
    </jsp:body>
</t:layout>