<%@tag description="Main Layout" language="java" pageEncoding="UTF-8" %>
<%@attribute name="pageName" required="false" %>
<%@attribute name="fillBlank" required="false" %>
<%@attribute name="head" fragment="true" required="false" %>
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
    <jsp:invoke fragment="head"/>
</head>
<body>
<header class="flex-row" style="align-items: center; justify-content: space-between">
    <span class="material-icons clickable" style="flex-basis: 0">menu</span>
    <h1 class="clickable" style="font-size: 1.5rem" onclick="moveto('${pageContext.request.contextPath}/index.jsp')">
        SamNet
    </h1>
    <% if (session.getAttribute("key") == null) { %>
    <span class="material-icons clickable" style="flex-basis: 0" onclick="moveto('${pageContext.request.contextPath}/user/login.jsp')">login</span>
    <% } else { %>
    <span class="material-icons clickable" style="flex-basis: 0">account_circle</span>
    <% } %>
</header>
<div class="content flex-col">
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