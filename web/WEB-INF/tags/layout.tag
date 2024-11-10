<%@tag description="Main Layout" language="java" pageEncoding="UTF-8" %>
<%@attribute name="pageName" required="false" %>
<%@attribute name="head" fragment="true" required="false" %>
<html lang="ko">
<head>
    <title>SamNet<%=pageName != null ? " - " + pageName : "" %>
    </title>
    <meta name=viewport content="width=device-width, initial-scale=1, user-scalable=0">
    <meta charset="utf-8"/>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
    <jsp:invoke fragment="head"/>
</head>
<body>
<header class="flex-row" style="align-items: center; justify-content: space-between">
    <span class="material-icons" style="flex-basis: 0">menu</span>
    <h1 style="font-size: 1.5rem">
        SamNet
    </h1>
    <% if (session.getAttribute("key") == null) { %>
    <span class="material-icons" style="flex-basis: 0">login</span>
    <% } else { %>
    <span class="material-icons" style="flex-basis: 0">account_circle</span>
    <% } %>
</header>
<div class="content">
    <jsp:doBody/>
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