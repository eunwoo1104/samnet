<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<t:layout pageName="유저 목록" requireLogin="true">
    <jsp:attribute name="head">
        <script>
            let page = 1;

            function renderList(users, reset=false) {
                const renderDiv = document.getElementById("user-list");
                if (reset) {
                    while (renderDiv.lastChild) {
                        renderDiv.removeChild(renderDiv.lastChild);
                    }
                }

                users.forEach((user, index) => {
                    const userProfile = profileComponent(user, "${pageContext.request.contextPath}", true);
                    userProfile.className += " clickable";
                    userProfile.addEventListener("click", () => moveto("${pageContext.request.contextPath}/user?id=" + user.id))
                    renderDiv.appendChild(userProfile);
                });
            }

            window.onload = () => {
                const form = document.querySelector("form");
                const msg = document.getElementById("start-search");

                form.addEventListener("submit", event => {
                    event.preventDefault();

                    let urlQuery = "?";
                    if (page > 0) {
                        urlQuery += "page=" + page;
                    }
                    urlQuery += "&query=" + event.target.query.value;
                    $.ajax(
                        {
                            url: "${pageContext.request.contextPath}/api/user/list" + urlQuery,
                            type: "GET",
                            dataType: "json",
                            beforeSend: xhr => {
                                xhr.setRequestHeader("Authorization", localStorage.getItem("session"));
                            },
                            success: data => {
                                const users = data.data;
                                renderList(users, page === 1);
                                if (users.length) {
                                    msg.style.display = "none";
                                } else {
                                    msg.style.display = "block";
                                    msg.textContent = "검색 결과가 없습니다.";
                                }
                            },
                            error: (xhr, status, error) => {
                                // TODO: different actions per error codes
                                alert("오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
                            }
                        }
                    );
                });
            }
        </script>
    </jsp:attribute>
    <jsp:body>
        <h2>
            유저 목록
        </h2>
        <form>
            <label class="mb-mid">
                <input name="query" type="text" placeholder="검색어">
            </label>
            <input class="custom-button mb-mid" type="submit" value="검색" id="submit-input">
        </form>
        <p id="start-search">
            유저 목록을 확인하려면 검색어를 입력해주세요.
        </p>
        <div id="user-list"></div>
    </jsp:body>
</t:layout>