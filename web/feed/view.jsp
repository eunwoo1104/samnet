<%@ page import="dao.FeedObj" %>
<%@ page import="dao.FeedDAO" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dao.UserObj" %>
<%@ page import="util.Utils" %>
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

    request.setAttribute("feed", Utils.doubleSlash(feed.toJSON().toJSONString()));
    request.setAttribute("author", Utils.doubleSlash(author.toJSON().toJSONString()));
%>
<t:layout pageName="피드 보기">
    <jsp:attribute name="head">
        <%--
        <script type="module" src="https://md-block.verou.me/md-block.js"></script>
        --%>
        <script>
            // TODO: consider safer method
            const feed = JSON.parse('${feed}');
            const author = JSON.parse('${author}');

            window.onload = () => {
                const mainFeedArea = document.getElementById("main-feed");
                mainFeedArea.appendChild(
                    feedComponent(author, feed.content, feed.images, "${pageContext.request.contextPath}")
                );
            };
        </script>
        <style>
            .buttons-layout {
                justify-content: center;
                align-items: center;
                text-align: center;
                gap: 4px
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <div class="mt-lg"></div>
        <div id="main-feed"></div>
        <div class="flex-row mt-mid" style="gap: 10px">
            <div class="flex-row buttons-layout clickable" id="like">
                <%-- color: red, favorite --%>
                <span class="material-icons">favorite_border</span>
                <p>0개</p>
            </div>
            <div class="flex-row buttons-layout clickable" id="reply">
                    <%-- color: red, favorite --%>
                <span class="material-icons">reply</span>
                <p>답장하기</p>
            </div>
        </div>
    </jsp:body>
</t:layout>