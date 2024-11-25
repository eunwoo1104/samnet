<%@tag description="Main Layout" language="java" pageEncoding="UTF-8" %>
<%@attribute name="pageName" required="false" %>
<%@attribute name="fillBlank" required="false" %>
<%@attribute name="requireLogin" required="false" %>
<%@attribute name="head" fragment="true" required="false" %>
<%
    if (requireLogin != null && requireLogin.equals("true")) {
        if (session.getAttribute("key") == null) {
            String query = request.getQueryString();
            if (query == null) {
                query = "";
            }
            String tgtUrl = request.getServletPath() + "%3F" + query;
            response.sendRedirect(request.getContextPath() + "/user/login.jsp?redirect=" + tgtUrl);
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <title>SamNet<%=pageName != null ? " - " + pageName : "" %>
    </title>
    <meta name=viewport content="width=device-width, initial-scale=1, user-scalable=0">
    <meta charset="utf-8"/>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/component.css">
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/global.js"></script>
    <script src="${pageContext.request.contextPath}/js/component.js"></script>
    <script>
        function handleMenu() {
            const mainMenu = document.getElementById("main-menu");
            const displayState = mainMenu.style.display;
            if (displayState === "none") {
                mainMenu.style.display = "flex";
            } else {
                mainMenu.style.display = "none";
            }
        }

        function handleAccount() {
            const accountMenu = document.getElementById("account-menu");
            const displayState = accountMenu.style.display;
            if (displayState === "none") {
                accountMenu.style.display = "flex";
            } else {
                accountMenu.style.display = "none";
            }
        }
    </script>
    <style>
        .main-menu {
            position: fixed;
            flex-direction: column;
            justify-content: center;
            align-items: start;
            gap: 0.5rem;
            background-color: #23272A;
            margin-top: 0.5rem;
            padding: 1rem;
            border-radius: 0.5rem;
            z-index: 10;
        }

        .main-menu#main-menu {
            align-items: start;
        }

        .main-menu#account-menu{
            align-items: end;
            right: 0;
        }

        .main-menu > div > a {
            text-decoration: none;
            font-weight: 600;
            padding: 0.1rem;
        }
    </style>
    <jsp:invoke fragment="head"/>
</head>
<body>
<header class="flex-row" style="align-items: center; justify-content: space-between">
    <span class="material-icons clickable" style="flex-basis: 0" onclick="handleMenu()">menu</span>
    <h1 class="clickable" style="font-size: 1.5rem" onclick="moveto('${pageContext.request.contextPath}/index.jsp')">
        SamNet
    </h1>
    <% if (session.getAttribute("key") == null) { %>
    <span class="material-icons clickable" style="flex-basis: 0" onclick="moveto(
        '${pageContext.request.contextPath}/user/login.jsp?redirect=' + encodeURIComponent(window.location.href)
            )">login</span>
    <% } else { %>
    <span class="material-icons clickable" style="flex-basis: 0" onclick="handleAccount()">account_circle</span>
    <% } %>
</header>
<div class="content flex-col">
    <div class="main-menu" id="main-menu" style="display: none">
        <div>
            <a href="${pageContext.request.contextPath}/feed">
                피드 목록
            </a>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/feed/add.jsp">
                피드 작성
            </a>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/user/list.jsp">
                유저 검색
            </a>
        </div>
    </div>
    <div class="main-menu content-margin" id="account-menu" style="display: none">
        <div>
            <a href="${pageContext.request.contextPath}/user">
                내 정보
            </a>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/user/logout.jsp">
                로그아웃
            </a>
        </div>
    </div>
    <jsp:doBody/>
    <% if (fillBlank == null || fillBlank.equals("true")) { %>
    <div style="flex-grow: 1;"></div>
    <% } %>
</div>
<footer class="text-light-white">
    <%-- copyright and link area --%>
    <h3 class="default-hide">SamNet</h3>
    <p class="font-light">
        &copy; 2024 <a href="https://eunwoo.dev" target="_blank" rel="noreferrer noopener">eunwoo.dev</a>, All rights
        reserved.
    </p>
    <%-- docs area --%>
    <div class="default-hide">
        <h4>문서</h4>
        <a href="">이용약관</a>
        <a href="">개인정보처리방침</a>
    </div>
</footer>
</body>
</html>