<%@ page import="dao.UserDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%
    String userId = request.getParameter("id");
    String listType = request.getParameter("type");

    UserDAO userDAO = new UserDAO();
    if (listType == null || userId == null || !userDAO.idExists(userId.trim())) {
        pageContext.forward("/404.jsp?type=user");
        return;
    }

    request.setAttribute("userId", userId);
    request.setAttribute("listType", listType);
    request.setAttribute("pageTitle", listType.equals("followings") ? "팔로우" : "팔로워");
%>
<t:layout pageName="${pageTitle} 목록" requireLogin="true">
    <jsp:attribute name="head">
        <script>
            const userId = "${userId}";
            const listType = "${listType}";
            let currentPage = 1;

            function onError(xhr, status, error) {
                // TODO: different actions per error codes
                alert("오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
            }

            function loadFollows() {
                const userListArea = document.getElementById("follow-list");
                const loadButton = document.getElementById("load-follows");
                loadButton.disabled = "disabled"
                loadButton.textContent = "로드중..."
                api("${pageContext.request.contextPath}", true, true).user.list(
                    ++currentPage, listType, userId, users => {
                        if (users.length === 0) {
                            loadButton.textContent = "더이상 유저가 없어요.";
                            return;
                        }
                        users.forEach((user, index) => {
                            const userProfile = profileComponent(user, "${pageContext.request.contextPath}", true);
                            userProfile.addEventListener("click", () => moveto("${pageContext.request.contextPath}/user?id=" + user.id))
                            userListArea.appendChild(userProfile);
                        });
                        loadButton.disabled = null;
                    }, onError
                );
            }

            let userList = api("${pageContext.request.contextPath}", true, false)
                .user.list(currentPage, listType, userId, null, onError);

            window.onload = () => {
                const userListArea = document.getElementById("follow-list");
                const loadButton = document.getElementById("load-follows");
                const userInfoButton = document.getElementById("show-user-info");
                if (userList.length === 0) {
                    const noFollow = document.createElement("p");
                    noFollow.className = "not-found";
                    if (listType === "followings") {
                        noFollow.textContent = "팔로우 중인 유저가 없어요.";
                    } else {
                        noFollow.textContent = "유저의 팔로워가 없어요.";
                    }
                    userListArea.appendChild(noFollow);
                    userInfoButton.style.display = "block";
                    return;
                }
                const title = document.createElement("h2");
                title.textContent = "${pageTitle} 목록";
                userListArea.appendChild(title);
                userList.forEach((user, index) => {
                    const userProfile = profileComponent(user, "${pageContext.request.contextPath}", true);
                    userProfile.className += " clickable";
                    userProfile.addEventListener("click", () => moveto("${pageContext.request.contextPath}/user?id=" + user.id))
                    userListArea.appendChild(userProfile);
                });
                loadButton.style.display = "block";
            }
        </script>
        <style>
            .not-found {
                font-size: 1.4rem;
                font-weight: bold;
                text-align: center;
                margin-top: 30vh;
            }

            #follow-list {
                display: flex;
                flex-direction: column;
                justify-content: center;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <div id="follow-list"></div>
        <button class="custom-button mt-mid" style="display: none" onclick="moveto('${pageContext.request.contextPath}/user?id=${userId}')" id="show-user-info">
            유저 정보로 돌아가기
        </button>
        <button class="custom-button mt-mid" style="display: none" onclick="loadFollows()" id="load-follows">
            더 불러오기
        </button>
    </jsp:body>
</t:layout>