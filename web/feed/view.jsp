<%@ page import="dao.FeedObj" %>
<%@ page import="dao.FeedDAO" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dao.UserObj" %>
<%@ page import="util.Utils" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%
    request.setCharacterEncoding("UTF-8");
    String feedId = request.getParameter("id");
    String fwdFrom = request.getParameter("fwd");
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
    int initHeartCount = feedDAO.getHeartCount(feedId);

    UserDAO userDAO = new UserDAO();
    UserObj author = userDAO.get(feed.getUser());
    String currentUser = (String) session.getAttribute("id");
    boolean voted = false;
    if (currentUser != null && !currentUser.isBlank()) {
        voted = userDAO.likedToFeed(currentUser, feedId);
    }
    JSONObject feedData = feed.toJSON();
    UserObj replyAuthor = null;
    if (feed.getReplyOf() != null) {
        replyAuthor = userDAO.getAuthor(feed.getReplyOf());
        feedData.put("replyAuthor", replyAuthor.toJSON());
    }

    request.setAttribute("feed", Utils.doubleSlash(feedData.toJSONString()));
    request.setAttribute("feedId", feedId);
    request.setAttribute("initHeartCount", initHeartCount);
    request.setAttribute("initHeartStyle", voted ? "color: red" : "");
    request.setAttribute("initHeartIcon", voted ? "favorite" : "favorite_border");
    request.setAttribute("author", Utils.doubleSlash(author.toJSON().toJSONString()));
    request.setAttribute("fwdFrom" , fwdFrom == null ? "null" : "\"" + fwdFrom + "\"");
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
            const fwdFrom = ${fwdFrom};

            window.onload = () => {
                const mainFeedArea = document.getElementById("main-feed");
                mainFeedArea.appendChild(
                    feedComponent(feed, author, "${pageContext.request.contextPath}")
                );

                if (fwdFrom) {
                    const fwdButton = document.getElementById("fwdButton");
                    fwdButton.style.display = "block";
                    fwdButton.addEventListener(
                        "click",
                        () => moveto("${pageContext.request.contextPath}/feed/view.jsp?id=" + fwdFrom)
                    );
                }

                const likeButton = document.getElementById("like");
                likeButton.addEventListener("click", e => {
                    const sessionKey = localStorage.getItem("session");
                    if (!sessionKey) {
                        alert("로그인이 필요합니다.");
                        return;
                    }

                    const requestData = {feed: feed.idx, heart: true};
                    $.ajax(
                        {
                            url: "${pageContext.request.contextPath}/api/feed/action",
                            type: "POST",
                            dataType: "json",
                            data: requestData,
                            beforeSend: xhr => {
                                xhr.setRequestHeader("Authorization", sessionKey);
                            },
                            success: data => {
                                while (likeButton.lastChild) {
                                    likeButton.removeChild(likeButton.lastChild);
                                }

                                const res = data.data;
                                const heartIcon = res.heart ? "favorite" : "favorite_border";
                                const heartSpan = document.createElement("span");
                                heartSpan.className = "material-icons";
                                heartSpan.textContent = heartIcon;
                                if (res.heart) {
                                    heartSpan.style.color = "red";
                                }
                                const heartCount = document.createElement("p");
                                heartCount.textContent = res.heartCount + "개";

                                likeButton.appendChild(heartSpan);
                                likeButton.appendChild(heartCount);
                            },
                            error: (xhr, status, error) => {
                                // console.log(xhr);
                                const data = xhr.responseJSON;
                                let msg = "";
                                switch (data.code) {
                                    case "NO_SESSION":
                                    case "INVALID_SESSION":
                                        msg = "로그인 정보에 오류가 있습니다. 다시 로그인해주세요.";
                                        break;
                                    case "USER_BLOCKED":
                                        msg = "좋아요 권한이 없습니다.";
                                        break;
                                    default:
                                        msg = "알 수 없는 오류가 발생하였습니다.";
                                        break;
                                }
                                // TODO: better handling
                                alert(msg);
                            }
                        }
                    );
                });
            };
        </script>
        <style>
            .buttons-layout {
                justify-content: center;
                align-items: center;
                text-align: center;
                gap: 4px;
                background-color: transparent;
                color: snow;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <div class="mt-lg"></div>
        <div id="main-feed"></div>
        <div class="flex-row mt-mid" style="gap: 10px">
            <button class="flex-row buttons-layout clickable" id="like">
                <span class="material-icons" style="${initHeartStyle}">${initHeartIcon}</span>
                <p>${initHeartCount}개</p>
            </button>
            <button class="flex-row buttons-layout clickable" id="reply" onclick="moveto('${pageContext.request.contextPath}/feed/add.jsp?reply=${feedId}')">
                <span class="material-icons">reply</span>
                <p>답장하기</p>
            </button>
        </div>
        <div class="clickable feed-reply-container mt-sm" style="display: none" id="fwdButton">
            <span class="material-icons">redo</span>
            <p>답장 피드로 돌아가기</p>
        </div>
    </jsp:body>
</t:layout>