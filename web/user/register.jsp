<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<t:layout pageName="회원가입">
    <jsp:attribute name="head">
        <script>
            window.onload = () => {
                const form = document.querySelector("form");

                form.addEventListener("submit", event => {
                    // don't use redirect
                    event.preventDefault();

                    encrypt(event.target.password.value).then(
                        password => {
                            const submitData = {
                                email: event.target.email.value,
                                password: password,
                                nickname: event.target.nickname.value,
                                username: event.target.username.value,
                            }

                            const submit = document.getElementById("submit-input");
                            submit.disabled = "disabled";

                            $.ajax({
                                url: "${pageContext.request.contextPath}/api/register",
                                type: "POST",
                                dataType: "json",
                                data: submitData,
                                success: data => {
                                    // console.log(data)
                                    const msgDiv = document.getElementById("submit-message");
                                    msgDiv.children[0].innerText = "성공적으로 가입했습니다. 잠시 후 로그인 페이지로 이동합니다.";
                                    msgDiv.className = "ok-box";
                                    msgDiv.style.display = "block";

                                    sleep(3 * 1000).then(() => {
                                        window.location.href = "${pageContext.request.contextPath}/user/login.jsp";
                                    });
                                },
                                error: (xhr, status, error) => {
                                    // console.log(xhr);
                                    const data = xhr.responseJSON;
                                    let msg = "";
                                    switch (data.code) {
                                        case "RESOURCE_EXISTS":
                                            msg = "해당 이메일로 가입된 계정이 이미 있습니다.";
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
                                    submit.disabled = null;
                                }
                            });
                        }
                    )

                });

                const pw = document.getElementById("pw");
                const rpw = document.getElementById("rpw");
                rpw.addEventListener("input", (event) => {
                    rpw.setCustomValidity("");

                    if (!rpw.validity.valid) return;
                    if (pw.value !== rpw.value) {
                        rpw.setCustomValidity("비밀번호가 일치하지 않습니다.");
                    }
                });
            }
        </script>
      <style>
          form > input[type=submit] {
              margin-top: 1.25rem;
          }

          #submit-message {
              margin-top: 1.25rem;
          }
      </style>
    </jsp:attribute>
    <jsp:body>
        <h2>
            회원가입
        </h2>
        <form>
            <label>
                아이디 (이메일)
                <input class="mb-mid" name="email" type="email" placeholder="user@example.com"
                       autocomplete="email" required>
            </label>
            <label>
                비밀번호
                <input class="mb-mid" name="password" type="password" placeholder="비밀번호" id="pw"
                       autocomplete="new-password" required>
            </label>
            <label>
                비밀번호 확인
                <input class="mb-mid" name="repassword" type="password" placeholder="비밀번호 재입력" id="rpw"
                       autocomplete="new-password" required>
            </label>
            <label>
                닉네임 (표시할 이름)
                <input class="mb-mid" name="nickname" type="text" placeholder="닉네임" required>
            </label>
            <label>
                유저네임
                <input name="username" type="text" placeholder="유저네임" pattern="^[a-zA-Z0-9]+$" required>
            </label>
            <input class="custom-button" type="submit" value="회원가입" id="submit-input">
            <div style="display: none" id="submit-message">
                <p>placeholder</p>
            </div>
        </form>
    </jsp:body>
</t:layout>