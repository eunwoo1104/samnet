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
    boolean exists = feedDAO.exists(feedId);
    if (!exists) {
        pageContext.forward("/404.jsp?type=feed");
        return;
    }

    request.setAttribute("feedId", feedId);
    request.setAttribute("fwdFrom" , fwdFrom == null ? "null" : "\"" + fwdFrom + "\"");
%>
<t:layout pageName="피드 보기">
    <jsp:attribute name="head">
        <%--
        <script type="module" src="https://md-block.verou.me/md-block.js"></script>
        --%>
        <script>
            function onError(xhr, status, error) {
                // TODO: different actions per error codes
                alert("오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
            }

            const viewData = api("${pageContext.request.contextPath}", true, false)
                .feed.view("${feedId}", null, onError);
            const author = viewData.author;
            const fwdFrom = ${fwdFrom};
            const ableToEdit = viewData.ableToEdit;

            window.onload = () => {
                const mainFeedArea = document.getElementById("main-feed");
                mainFeedArea.appendChild(
                    feedComponent(viewData, author, "${pageContext.request.contextPath}")
                );

                const heartIcon = document.getElementById("heart-icon");
                const heartCount = document.getElementById("heart-count");
                heartCount.textContent = viewData.initHeartCount + "개";
                if (viewData.voted) {
                    heartIcon.textContent = "favorite";
                    heartIcon.style.color = "red";
                }

                if (ableToEdit) {
                    const editButton = document.getElementById("edit-button");
                    editButton.style.display = "block";
                }

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

                    const requestData = {feed: viewData.idx, heart: true};
                    api("${pageContext.request.contextPath}", true, true)
                        .feed.action(requestData, res => {
                            heartIcon.textContent = res.heart ? "favorite" : "favorite_border";
                            if (res.heart) {
                                heartIcon.style.color = "red";
                            } else {
                                heartIcon.style.color = "inherit";
                            }
                            heartCount.textContent = res.heartCount + "개";
                        }, (xhr, status, error) => {
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
                        });
                });

                if (ableToEdit) {
                    const editButton = document.getElementById("edit-button");
                    editButton.addEventListener(
                        "click",
                        () => moveto("${pageContext.request.contextPath}/feed/edit.jsp?id=" + viewData.idx)
                    );
                }
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
                <span class="material-icons" id="heart-icon">favorite_border</span>
                <p id="heart-count">0개</p>
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
        <button class="custom-button mt-lg" style="display: none" id="edit-button">
            피드 수정하기
        </button>
    </jsp:body>
</t:layout>