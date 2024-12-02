<%@ page import="dao.UserDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (request.getSession().getAttribute("key") == null) {
%>
<!DOCTYPE html>
<html>
<head>
    <title>SamNet - 로그아웃</title>
    <script src="${pageContext.request.contextPath}/js/global.js"></script>
    <script>
        if (localStorage.getItem("session")) {
            moveto("${pageContext.request.contextPath}/user/login.jsp?logout=true");
        } else {
            alert("로그인 정보가 없습니다.");
            moveto("${pageContext.request.contextPath}/index.jsp");
        }
    </script>
</head>
</html>
<%
        return;
    }
    String userId = (String) request.getSession().getAttribute("id");
    if (userId != null) {
        UserDAO userDAO = new UserDAO();
        userDAO.invalidateSession(userId);
    }
    request.getSession().invalidate();
    response.sendRedirect(request.getContextPath() + "/user/login.jsp?logout=true");
%>