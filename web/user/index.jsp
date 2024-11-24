<%@ page import="dao.UserDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%
    String targetId = request.getParameter("id");
    boolean userNotInParam = targetId == null || targetId.isBlank();

    UserDAO userDAO = new UserDAO();
    if (!userNotInParam && !userDAO.idExists(targetId.trim())) {
        pageContext.forward("/404.jsp?type=user");
        return;
    }

    String loggedInUser = (String) request.getSession().getAttribute("id");

    request.setAttribute("requireLogin", userNotInParam ? "true" : "false");
    request.setAttribute("targetId", userNotInParam ? "null" : "\"" + targetId.trim() + "\"");
    request.setAttribute("loggedInUser", loggedInUser == null ? "null" : "\"" + loggedInUser + "\"");
%>
<t:layout pageName="유저 정보" requireLogin="${requireLogin}">
    <jsp:attribute name="head">
        <script>
            const sessionKey = localStorage.getItem("session");
            const targetId = ${targetId};
            const loggedInUser = ${loggedInUser};
            const sameUser = !targetId || loggedInUser === targetId;
            const urlQuery = targetId ? "?user=" + targetId : ""
            let targetUser = null;

            $.ajax(
                {
                    url: "${pageContext.request.contextPath}/api/user" + urlQuery,
                    type: "GET",
                    dataType: "json",
                    async: false,
                    beforeSend: xhr => {
                        if (!targetId && sessionKey) {
                            xhr.setRequestHeader("Authorization", sessionKey);
                        }
                    },
                    success: data => {
                        targetUser = data.data;
                    },
                    error: (xhr, status, error) => {
                        // TODO: different actions per error codes
                        alert("오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
                    }
                }
            );

            const onFollow = e => {
                const sessionKey = localStorage.getItem("session");
                if (!sessionKey) {
                    alert("로그인이 필요합니다.");
                    return;
                }

                const requestData = {user: targetUser.id, follow: true};
                $.ajax(
                    {
                        url: "${pageContext.request.contextPath}/api/user/action",
                        type: "POST",
                        dataType: "json",
                        data: requestData,
                        beforeSend: xhr => {
                            xhr.setRequestHeader("Authorization", sessionKey);
                        },
                        success: data => {
                            const res = data.data;

                            const followButton = document.getElementById("follow-button");
                            if (res.follow) {
                                followButton.textContent = "팔로우 취소";
                            } else {
                                followButton.textContent = "팔로우";
                            }
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
                                    msg = "팔로우 권한이 없습니다.";
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
            };

            window.onload = () => {
                if (!targetUser) return;
                const renderArea = document.getElementById("render-area");

                const profileContainer = profileComponent(targetUser, "${pageContext.request.contextPath}");
                renderArea.appendChild(profileContainer)

                // badges
                let badgeIcon = null;
                let badgeColor = null;
                let badgeDesc = null;
                switch (decodeUserFlag(targetUser.flag)) {
                    case "admin":
                        badgeIcon = "handyman";
                        badgeColor = "#3366FF";
                        badgeDesc = "SamNet의 관리자입니다."
                        break;
                }

                if (badgeIcon) {
                    const badgeContainer = document.createElement("div");
                    badgeContainer.className = "badge-container mt-xs";
                    const badge = document.createElement("span");
                    badge.className = "material-icons";
                    badge.textContent = badgeIcon;
                    badge.style.color = badgeColor;
                    // TODO: icon tooltip
                    badgeContainer.appendChild(badge);
                    renderArea.appendChild(badgeContainer);
                }

                // buttons
                const buttonContainer = document.createElement("div");
                buttonContainer.className = "button-container mt-mid mb-mid"

                const followButton = document.createElement("button");
                followButton.className = "custom-button"
                followButton.id = "follow-button"
                if (targetUser.follows) {
                    followButton.textContent = "팔로우 취소"
                } else {
                    followButton.textContent = "팔로우"
                }
                followButton.disabled = sameUser ? "true" : null;
                followButton.addEventListener("click", onFollow);
                buttonContainer.appendChild(followButton);

                const feedListButton = document.createElement("button");
                feedListButton.className = "custom-button mt-sm"
                feedListButton.textContent = "피드 목록"
                feedListButton.addEventListener("click", () => {
                    moveto("${pageContext.request.contextPath}/feed?user=" + targetUser.id);
                });
                buttonContainer.appendChild(feedListButton);

                if (sameUser) {
                    const editButton = document.createElement("button");
                    editButton.className = "custom-button mt-sm"
                    editButton.textContent = "프로필 수정"
                    editButton.addEventListener("click", () => {
                        moveto("${pageContext.request.contextPath}/user/edit.jsp");
                    });
                    buttonContainer.appendChild(editButton);
                }

                renderArea.appendChild(buttonContainer);

                // bio
                if (targetUser.bio) {
                    const bio = document.createElement("p");
                    bio.className = "pf-bio"
                    bio.textContent = escapeHTML(targetUser.bio);
                    renderArea.appendChild(bio);
                }
            }
        </script>
        <style>
            .badge-container {
                display: flex;
                flex-direction: row;
                justify-content: center;
                align-items: center;
            }

            .button-container {

            }

            .pf-bio {
                padding: 0.3rem;
            }

            @media (min-width: 300px) {
                .badge-container {
                    justify-content: start;
                }
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <div class="mt-xl" id="render-area"></div>
    </jsp:body>
</t:layout>