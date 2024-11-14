<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%
    request.setCharacterEncoding("UTF-8");
    String notFoundType = request.getParameter("type");
    if (notFoundType == null)
        notFoundType = "";
    /*
    // getting "Arrow in case statement supported from Java 14 onwards only" issue though using JDK 21
    // should invest this later
    String msg = switch (notFoundType) {
        case "feed" -> "피드가 존재하지 않습니다.";
        case "user" -> "유저가 존재하지 않습니다.";
        default -> "페이지가 존재하지 않습니다.";
    };
    */
    String msg;
    if (notFoundType.equals("feed"))
        msg = "피드가 존재하지 않습니다.";
    else if (notFoundType.equals("user"))
        msg = "유저가 존재하지 않습니다.";
    else msg = "페이지가 존재하지 않습니다.";

    /*
    System.out.println(request.getRequestURL().toString());
    if (request.getRequestURL().toString().endsWith("404.jsp")) {
        msg = "존재하지 않는 페이지를 표시하기 위한 페이지입니다. 과연 지금 페이지는 존재하는 것일까요?";
    }
    */

    request.setAttribute("msg", msg);
%>
<t:layout pageName="404" fillBlank="false">
    <jsp:attribute name="head">
        <style>
            .container {
                flex-grow: 1;
                display: flex;
                justify-content: center;
                align-items: center;
                text-align: center;
            }
            .container > p {
                font-size: 1.4rem;
                font-weight: bold;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <div class="container">
            <p>${msg}</p>
        </div>
    </jsp:body>
</t:layout>