<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    String toRedirect = request.getParameter("redirect");
    if (toRedirect == null) {
        toRedirect = request.getContextPath() + "/index.jsp";
    } else if (!toRedirect.startsWith("http")) {
        toRedirect = request.getContextPath() + toRedirect;
    }
    // toRedirect = request.getContextPath() + (toRedirect != null ? toRedirect : "/index.jsp");

    request.setAttribute("redirect", toRedirect);

    if (request.getSession().getAttribute("key") == null) {
%>
<!DOCTYPE html>
<html>
<head>
    <title>SamNet</title>
    <script src="${pageContext.request.contextPath}/js/global.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
    <script>
        const sessionKey = localStorage.getItem("session");
        const loginURL = "${pageContext.request.contextPath}/user/login.jsp?redirect=${redirect}";
        if (sessionKey) {
            $.ajax(
                {
                    url: "${pageContext.request.contextPath}/api/user/restore",
                    type: "GET",
                    dataType: "json",
                    async: false,
                    beforeSend: xhr => {
                        xhr.setRequestHeader("Authorization", sessionKey);
                    },
                    success: data => {
                        moveto("${redirect}");
                    },
                    error: (xhr, status, error) => {
                        // TODO: different actions per error codes
                        alert("오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
                        moveto(loginURL);
                    }
                }
            );
        } else {
            moveto(loginURL);
        }
    </script>
</head>
</html>
<%
        return;
    }
    request.getSession().invalidate();
    response.sendRedirect(request.getContextPath() + "/user/login.jsp?logout=true");
%>