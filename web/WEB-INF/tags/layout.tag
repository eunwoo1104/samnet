<%@tag description="Main Layout" language="java" pageEncoding="UTF-8" %>
<%@attribute name="pageName" required="false" %>
<%@attribute name="head" fragment="true" required="false" %>
<html lang="ko">
<head>
    <title>SamNet<%=pageName != null ? " - " + pageName : "" %>
    </title>
    <meta name=viewport content="width=device-width, initial-scale=1, user-scalable=0">
    <meta charset="utf-8"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <jsp:invoke fragment="head"/>
</head>
<body>
<header>
<h1>
    SamNet
</h1>
</header>
<jsp:doBody/>
<footer>
    <%-- copyright and link area --%>
    <h3>SamNet</h3>
    <p>
        &copy; 2024 <a href="https://eunwoo.dev" target="_blank" rel="noreferrer noopener">eunwoo.dev</a>, All rights
        reserved.
    </p>
    <%-- docs area --%>
    <h4>문서</h4>
    <a href="">이용약관</a>
    <a href="">개인정보처리방침</a>
</footer>
</body>
</html>