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

            let targetUser = api("${pageContext.request.contextPath}", ${requireLogin}, false)
                .user.get(targetId ? targetId : null, null, (xhr, status, error) => {
                    // TODO: different actions per error codes
                    alert("오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
                });

            const onFollow = e => {
                if (!sessionKey) {
                    alert("로그인이 필요합니다.");
                    return;
                }

                const requestData = {user: targetUser.id, follow: true};
                api("${pageContext.request.contextPath}", true, true)
                    .user.action(requestData, res => {
                        const followButton = document.getElementById("follow-button");
                        if (res.follow) {
                            followButton.textContent = "팔로우 취소";
                        } else {
                            followButton.textContent = "팔로우";
                        }
                    }, (xhr, status, error) => {
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
                    });
            };

            function onFollowsClick(followType) {
                let tgtUrl = "${pageContext.request.contextPath}/user/follows.jsp?";
                tgtUrl += "id=" + targetUser.id;
                tgtUrl += "&type=" + followType;
                moveto(tgtUrl);
            }

            window.onload = () => {
                if (!targetUser) return;
                const renderArea = document.getElementById("render-area");

                const profileContainer = profileComponent(targetUser, "${pageContext.request.contextPath}");
                renderArea.appendChild(profileContainer)

                // badges
                let badgeIcon = null;
                let badgeColor = null;
                let badgeDesc = null;
                const userFlag = decodeUserFlag(targetUser.flag);
                switch (userFlag) {
                    case "admin":
                        badgeIcon = "handyman";
                        badgeColor = "#3366FF";
                        badgeDesc = "SamNet의 관리자입니다."
                        break;
                    case "verified":
                        badgeIcon = "verified";
                        badgeColor = "green";
                        badgeDesc = "인증된 유저입니다."
                        break;
                    case "early_tester":
                        badgeIcon = "key";
                        badgeColor = "lightblue";
                        badgeDesc = "얼리 테스터입니다."
                        break
                }

                if (badgeIcon) {
                    // TODO: multiple icon rendering
                    const badgeContainer = document.createElement("div");
                    badgeContainer.className = "badge-container mt-sm";

                    const badge = document.createElement("span");
                    badge.className = "material-icons";
                    badge.textContent = badgeIcon;
                    badge.style.color = badgeColor;
                    badgeContainer.appendChild(badge);

                    const badgeContext = document.createElement("p");
                    badgeContext.textContent = badgeDesc;
                    badgeContext.style.marginLeft = "0.3rem";
                    badgeContext.style.color = badgeColor;
                    badgeContainer.appendChild(badgeContext);

                    renderArea.appendChild(badgeContainer);
                }

                if (userFlag === "blocked") {
                    const messageContainer = document.createElement("div");
                    messageContainer.className = "mt-mid error-box";
                    const msgContent = document.createElement("p");
                    msgContent.textContent = "관리자에 의해 차단된 사용자입니다.";
                    messageContainer.appendChild(msgContent);

                    renderArea.appendChild(messageContainer);
                    return;
                }

                // follows
                const followContainer = document.createElement("div");
                followContainer.className = "mt-lg mb-lg";
                const followings = document.createElement("p");
                followings.className = "clickable";
                followings.innerHTML = "팔로우 <span style='font-weight: 500;'>" + targetUser.followingCount + "</span>명";
                followings.addEventListener("click", () => onFollowsClick("followings"));
                followContainer.appendChild(followings);

                const spacer = document.createElement("div");
                spacer.className = "follow-spacer";
                followContainer.appendChild(spacer);

                const followers = document.createElement("p");
                followers.className = "clickable";
                followers.innerHTML = "팔로워 <span style='font-weight: 500;'>" + targetUser.followsCount + "</span>명";
                followers.addEventListener("click", () => onFollowsClick("followers"))
                followContainer.appendChild(followers);
                renderArea.appendChild(followContainer);

                // buttons
                const buttonContainer = document.createElement("div");
                buttonContainer.className = "button-container mt-lg mb-mid"

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
                    bio.innerHTML = escapeHTML(targetUser.bio, true);
                    renderArea.appendChild(bio);
                }
            }
        </script>
        <style>
            .badge-container {
                display: flex;
                flex-direction: row;
                justify-content: start;
                align-items: center;
            }

            .button-container {

            }

            .pf-bio {
                padding: 0.3rem;
            }

            .follow-spacer {
                display: inline-block;
                width: 1rem;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <div class="mt-xl" id="render-area"></div>
    </jsp:body>
</t:layout>