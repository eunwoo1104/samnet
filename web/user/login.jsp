<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<t:layout pageName="로그인">
    <jsp:attribute name="head">
        <script>
            window.onload = () => {
                const form = document.querySelector("form");

                form.addEventListener("submit", event => {
                    // don't use redirect
                    event.preventDefault();

                    const submitData = {
                        email: event.target.email.value,
                        password: event.target.password.value,
                    };

                    $.ajax({
                        url: "${pageContext.request.contextPath}/api/login",
                        type: "POST",
                        dataType: "json",
                        data: submitData,
                        success: data => {
                            // console.log(data)
                            localStorage.setItem("id", data.data.id);
                            localStorage.setItem("session", data.data.key);
                            window.location.href = "${pageContext.request.contextPath}/index.jsp";
                        },
                        error: (xhr, status, error) => {
                            // console.log(xhr);
                            const data = xhr.responseJSON;
                            let msg = "";
                            switch (data.code) {
                                case "MISSING_DATA":
                                    msg = "해당 이메일로 가입된 계정이 없습니다.";
                                    break;
                                case "INVALID_DATA":
                                    msg = "데이터에 오류가 있습니다. 새로고침 후 다시 시도해주세요.";
                                    break;
                                case "CREDENTIAL_ERROR":
                                    msg = "비밀번호가 일치하지 않습니다.";
                                    break;
                                default:
                                    msg = "알 수 없는 오류가 발생하였습니다.";
                                    break;
                            }
                            const msgDiv = document.getElementById("submit-message");
                            msgDiv.children[0].innerText = msg;
                            msgDiv.className = "error-box";
                            msgDiv.style.display = "block";
                        }
                    });
                });
            };
        </script>
      <style>
          h2 {
              display: block;
              text-align: center;
              line-height: 4rem;
              font-size: 2rem;
          }

          form > label {
              font-weight: 400;
              line-height: 1.5rem;
          }

          form > input[type=submit] {
              margin-top: 1.25rem;
          }

          #submit-message {
              padding: 1.25rem;
              font-weight: 700;
          }
      </style>
    </jsp:attribute>
    <jsp:body>
        <h2>
            로그인
        </h2>
        <form>
            <label>
                아이디 (이메일)
                <input class="short-input mb-mid" name="email" type="email" placeholder="user@example.com" autocomplete="email" required>
            </label>
            <label>
                비밀번호
                <input class="short-input" name="password" type="password" placeholder="password" autocomplete="current-password" required>
            </label>
            <input class="custom-button mb-mid" type="submit" value="로그인">
        </form>
        <div class="mb-mid" style="display: none" id="submit-message" >
            <p>placeholder</p>
        </div>
        <p style="font-weight: 300; font-size: 0.8rem; margin: 0.3rem 0">
            계정이 없으신가요? 간단하게 SamNet 서비스에 회원가입을 하실 수 있습니다.
        </p>
        <button class="custom-button" onclick="moveto('register.jsp')">
            회원가입
        </button>
    </jsp:body>
</t:layout>