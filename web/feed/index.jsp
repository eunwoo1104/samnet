<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%
    request.setCharacterEncoding("UTF-8");
    String targetUser = request.getParameter("user");
    request.setAttribute("targetUser", targetUser == null ? "null" : "\"" + targetUser + "\"");
    String loggedInUser = (String) session.getAttribute("id");
    request.setAttribute("loggedInUser", loggedInUser == null ? "null" : "\"" + loggedInUser + "\"");
%>
<t:layout pageName="피드 목록" requireLogin="true">
    <jsp:attribute name="head">
        <script>
            const targetUser = ${targetUser};
            const loggedInUser = ${loggedInUser};
            let currentPage = 1;

            function getFeeds(page=1, runAsync=true, callback=null) {
                let feedList = null;
                let urlQuery = "?";
                if (page > 0) {
                    urlQuery += "page=" + page;
                }
                if (targetUser) {
                    urlQuery += "&user=" + targetUser;
                }
                $.ajax(
                    {
                        url: "${pageContext.request.contextPath}/api/feed/list" + urlQuery,
                        type: "GET",
                        dataType: "json",
                        async: runAsync,
                        beforeSend: xhr => {
                            xhr.setRequestHeader("Authorization", localStorage.getItem("session"));
                        },
                        success: data => {
                            feedList = data.data;
                            if (callback) {
                                callback(feedList);
                            }
                        },
                        error: (xhr, status, error) => {
                            // TODO: different actions per error codes
                            alert("오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
                        }
                    }
                );
                return feedList;
            }

            function loadFeeds() {
                const feedListArea = document.getElementById("feed-list");
                const loadButton = document.getElementById("load-feed");
                loadButton.disabled = "disabled"
                loadButton.textContent = "로드중..."
                getFeeds(++currentPage, true, feeds => {
                    if (feeds.length === 0) {
                        loadButton.textContent = "더이상 피드가 없어요.";
                        return;
                    }
                    feeds.forEach((feed, index) => {
                        const renderedFeed = feedComponent(
                            feed,
                            feed.author,
                            "${pageContext.request.contextPath}",
                            index+1 !== feedList.length,
                            true
                        );
                        feedListArea.appendChild(renderedFeed);
                    });
                    loadButton.disabled = null;
                });
            }

            let feedList = getFeeds(1, false);

            window.onload = () => {
                const feedListArea = document.getElementById("feed-list");
                if (feedList.length === 0) {
                    const noFeed = document.createElement("h2");
                    noFeed.textContent = "볼 수 있는 피드가 없어요.";
                    feedListArea.appendChild(noFeed);
                    if (!targetUser) {
                        const followButton = document.getElementById("search-user");
                        const followMsg = document.createElement("p");
                        followMsg.textContent = "새로운 친구를 팔로우해서 피드를 확인하세요.";
                        followMsg.style.textAlign = "center";
                        feedListArea.appendChild(followMsg);
                        followButton.style.display = "block";
                    } else if (targetUser === loggedInUser) {
                        const addButton = document.getElementById("add-feed");
                        const addMsg = document.createElement("p");
                        addMsg.textContent = "새로운 피드를 추가해보세요.";
                        addMsg.style.textAlign = "center";
                        feedListArea.appendChild(addMsg);
                        addButton.style.display = "block";
                    }
                    return;
                }
                const loadButton = document.getElementById("load-feed");
                const title = document.createElement("h2");
                title.textContent = "피드 목록";
                feedListArea.appendChild(title);
                feedList.forEach((feed, index) => {
                    const renderedFeed = feedComponent(
                        feed,
                        feed.author,
                        "${pageContext.request.contextPath}",
                        index+1 !== feedList.length,
                        true
                    );
                    feedListArea.appendChild(renderedFeed);
                });
                loadButton.style.display = "block";
            }
        </script>
        <style>
            #feed-list {
                display: flex;
                flex-direction: column;
                justify-content: center;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <div class="mt-mid" id="feed-list"></div>
        <button class="custom-button mt-mid" style="display: none" onclick="loadFeeds()" id="load-feed">
            더 불러오기
        </button>
        <button class="custom-button mt-mid" style="display: none" onclick="moveto('${pageContext.request.contextPath}/user/list.jsp')" id="search-user">
            새 친구 팔로우하기
        </button>
        <button class="custom-button mt-mid" style="display: none" onclick="moveto('add.jsp')" id="add-feed">
            새 피드 작성하기
        </button>
    </jsp:body>
</t:layout>