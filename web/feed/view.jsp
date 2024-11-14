<%@ page import="dao.FeedObj" %>
<%@ page import="dao.FeedDAO" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dao.UserObj" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%
    request.setCharacterEncoding("UTF-8");
    String feedId = request.getParameter("id");
    if (feedId == null) {
        pageContext.forward("/404.jsp?type=feed");
        return;
    }

    FeedDAO feedDAO = new FeedDAO();
    FeedObj feed = feedDAO.get(feedId);
    if (feed == null) {
        pageContext.forward("/404.jsp?type=feed");
        return;
    }

    UserDAO userDAO = new UserDAO();
    UserObj author = userDAO.get(feed.getUser());

    request.setAttribute("feed", feed);
    request.setAttribute("author", author);
%>
<t:layout pageName="피드 보기">
    <jsp:attribute name="head">
        <%--
        <script type="module" src="https://md-block.verou.me/md-block.js"></script>
        --%>
        <script>
            window.onload = () => {
                const nickname = document.getElementById("nickname");
                // const username = document.getElementById("username");
                nickname.textContent = limitTextLength(nickname.textContent, 20);
                // username.textContent = limitTextLength(username.textContent, 20);
            };
        </script>
        <style>
            .container {
                border-style: solid;
                outline: none;
                border-width: 1px 0;
                border-color: dimgrey;
                padding: 0.7rem 0;
            }

            /*
            use on desktop
            {
                border-radius: 0.25rem;
                border-style: solid;
                outline: none;
                border-width: 1px;
                border-color: dimgrey;
            }
            */

            .author {
                color: white;
                font-size: 1.3rem;
            }

            .author > #username {
                opacity: 80%;
            }

            .context {
                font-weight: 450;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <div class="container mt-lg">
            <div class="flex-row clickable">
                <span class="material-icons" style="margin-right: 4px">account_circle</span>
                <%-- TODO: avatar image --%>
                <p class="author bold mb-xs">
                    <span id="nickname">${author.safeNickname}</span>
                </p>
            </div>
            <%-- <span id="username">@${author.username}</span> --%>
            <p class="context">
                ${feed.safeContent}
            </p>
        </div>
    </jsp:body>
</t:layout>