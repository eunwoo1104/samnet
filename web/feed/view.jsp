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
            // TODO: consider safer method
            const feed = JSON.parse('${feed.toJSON()}');
            const author = JSON.parse('${author.toJSON()}');

            window.onload = () => {
                const imageContainer = document.getElementById("image-container");
                const nickname = document.getElementById("nickname");
                // const username = document.getElementById("username");
                nickname.textContent = limitTextLength(nickname.textContent.trim(), 20);
                // username.textContent = limitTextLength(username.textContent, 20);
                let imgIncluded = false;
                feed.images.split(",").forEach(img => {
                    if (!img) return;
                    const imgURL = "${pageContext.request.contextPath}/resource/image?id=" + img;
                    const imgChild = document.createElement("img");
                    imgChild.setAttribute("src", imgURL);
                    imgChild.setAttribute("alt", img);
                    imgChild.className = "image";
                    imageContainer.appendChild(imgChild);
                    imgIncluded = true;
                });
                if (imgIncluded) {
                    imageContainer.style = null;
                }
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

            .author-container {
                display: inline-flex;
                flex-direction: row;
                justify-content: center;
                align-items: center;
                text-align: center;
            }

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

            .image-container {
                display: inline-flex;
                flex-wrap: nowrap;
                overflow-x: scroll;
                overflow-y: hidden;
                gap: 5px;
            }

            .image {
                display: inline-block;
                width: 100%;
                max-height: 20rem;
            }

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
        <div class="container">
            <div class="author-container clickable mb-sm">
                <span class="material-icons" style="margin-right: 4px">account_circle</span>
                <%-- TODO: avatar image --%>
                <p class="author bold" id="nickname">
                    ${author.safeNickname}
                </p>
            </div>
            <p class="context">
                ${feed.safeContent}
            </p>
            <div class="image-container mt-xs" style="display: none" id="image-container"></div>
        </div>
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