<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%
    request.setCharacterEncoding("UTF-8");
    String targetUser = request.getParameter("user");
    request.setAttribute("targetUser", targetUser == null ? "null" : "\"" + targetUser + "\"");
%>
<t:layout pageName="피드 목록" requireLogin="true">
    <jsp:attribute name="head">
        <script>
            const targetUser = ${targetUser};

            function getFeeds(page=1, runAsync=true) {
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
                        },
                        error: (xhr, status, error) => {
                            // TODO: different actions per error codes
                            alert("오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
                        }
                    }
                );
                return feedList;
            }

            let feedList = getFeeds(1, false);

            window.onload = () => {
                const feedListArea = document.getElementById("feed-list");
                if (feedList.length === 0) {
                    const noFeed = document.createElement("h2");
                    noFeed.textContent = "볼 수 있는 피드가 없어요.";
                    feedListArea.appendChild(noFeed);
                    if (!targetUser) {
                        const followMsg = document.createElement("p");
                        followMsg.textContent = "새로운 친구를 팔로우해서 피드를 확인하세요.";
                        followMsg.style.textAlign = "center";
                        feedListArea.appendChild(followMsg);
                    }
                    return;
                }
                const title = document.createElement("h2");
                title.textContent = "피드 목록";
                feedListArea.appendChild(title);
                feedList.forEach((feed, index) => {
                    const renderedFeed = feedComponent(
                        feed.idx,
                        feed.author,
                        feed.content,
                        feed.images,
                        "${pageContext.request.contextPath}",
                        null,
                        index+1 !== feedList.length,
                        true
                    );
                    feedListArea.appendChild(renderedFeed);
                })
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
    </jsp:body>
</t:layout>