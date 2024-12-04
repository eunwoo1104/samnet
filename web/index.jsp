<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%
    String keyFromSession = (String) request.getSession().getAttribute("key");
    if (keyFromSession != null) {
        pageContext.forward("/feed/index.jsp");
        return;
    }
%>
<t:layout>
    <jsp:attribute name="head">
        <style>
            .welcome {
                text-align: center;
            }

            @media (min-width: 1024px) {
                .welcome {
                    text-align: start;
                }
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <h2>
            환영해요!
        </h2>
        <p class="welcome">
            로그인 후 SamNet의 SNS 기능을 사용해보세요.
        </p>
        <button class="custom-button mt-mid" onclick="moveto('${pageContext.request.contextPath}/user/restore.jsp')">
            로그인
        </button>
        <button class="custom-button mt-mid" onclick="moveto('${pageContext.request.contextPath}/user/register.jsp')">
            회원가입
        </button>
    </jsp:body>
</t:layout>