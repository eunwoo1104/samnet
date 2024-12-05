function feedComponent(
    feed, author, baseURL, noBottomOutline=false, linkToView=false
) {
    // i want to use typescript and react
    /*
    if (author.avatar === undefined || author.username === undefined || author.nickname === undefined) {
        const errorElement = document.createElement("p");
        errorElement.innerText = "컨텐츠 생성에 문제가 발생했습니다.";
        return errorElement;
    }
    */

    const container = document.createElement("div");
    container.className = "feed-container";
    if (noBottomOutline) {
        container.style.borderBottomWidth = "0";
    }

    if (feed.replyOf && feed.replyAuthor) {
        const replyContainer = document.createElement("div");
        replyContainer.className = "feed-reply-container mb-sm clickable"
        const replyIcon = document.createElement("span");
        replyIcon.className = "material-icons";
        replyIcon.textContent = "reply";
        replyContainer.appendChild(replyIcon);
        const replyText = document.createElement("p");
        const replyAuthorName = feed.replyAuthor.username;
        replyText.textContent = "@" + escapeHTML(replyAuthorName) +"님의 피드 답장";
        replyContainer.appendChild(replyText);
        replyContainer.addEventListener(
            "click",
            () => moveto(baseURL + "/feed/view.jsp?id=" + feed.replyOf + "&fwd=" + feed.idx)
        );
        container.appendChild(replyContainer);
    }

    const feedHeader = document.createElement("div");
    feedHeader.className = "feed-header";

    const authorContainer = document.createElement("div");
    authorContainer.className = "feed-author-container mb-sm";
    authorContainer.onclick = e => moveto(baseURL + "/user?id=" + author.id);

    if (author.avatar) {
        const avatarSrc = `${baseURL}/resource/image?id=` + author.avatar;
        const avatarImg = avatarImage(avatarSrc, author.username, "feed-author-avatar");
        authorContainer.appendChild(avatarImg);
    } else {
        const defaultAvatar = document.createElement("span");
        defaultAvatar.className = "material-icons";
        defaultAvatar.innerText = "account_circle";
        authorContainer.appendChild(defaultAvatar);
    }

    const nickname = document.createElement("p");
    nickname.className = "feed-author bold";
    nickname.style.marginLeft = "4px";
    nickname.innerText = limitTextLength(escapeHTML(author.nickname).trim(), 20);
    authorContainer.appendChild(nickname);

    feedHeader.appendChild(authorContainer);

    const spacer = document.createElement("div");
    spacer.style.flexGrow = "1";
    feedHeader.appendChild(spacer);

    if (linkToView) {
        /*
        const viewButton = document.createElement("div");
        viewButton.className = "clickable";
        viewButton.addEventListener("click", e => {
            moveto(baseURL + "/feed/view.jsp?id=" + feed.idx);
        });
        const viewIcon = document.createElement("span");
        viewIcon.className = "material-icons";
        viewIcon.textContent = "chevron_right";
        viewButton.appendChild(viewIcon);
        feedHeader.appendChild(viewButton);
        */
        container.className += " mobile-clickable"
        container.addEventListener("click", e => {
            moveto(baseURL + "/feed/view.jsp?id=" + feed.idx);
        });
    } else {
        authorContainer.className += " clickable"
    }

    container.appendChild(feedHeader);

    const context = document.createElement("p");
    context.className = "feed-context";
    let textContent = escapeHTML(feed.content, true);
    if (!linkToView) {
        textContent = urlToLink(textContent);
    }
    context.innerHTML = textContent;
    container.appendChild(context);

    const imageContainer = document.createElement("div");
    imageContainer.className = "feed-image-container mt-xs";
    let imgIncluded = false;
    if (feed.images) {
        feed.images.trim().split(",").forEach(img => {
            if (!img) return;
            const imgURL = `${baseURL}/resource/image?id=` + img;
            const imgChild = document.createElement("img");
            imgChild.setAttribute("src", imgURL);
            imgChild.setAttribute("alt", img);
            imgChild.className = "feed-image";
            imageContainer.appendChild(imgChild);
            imgIncluded = true;
        });
    }
    if (!imgIncluded) {
        imageContainer.style.display = "none";
    }

    container.appendChild(imageContainer);

    const feedTime = document.createElement("p");
    feedTime.className = "mt-xs feed-time";
    feedTime.innerText = feed.createdAt;
    if (feed.editedAt) {
        feedTime.innerText += " (수정됨)";
    }

    container.appendChild(feedTime);

    return container;
}

function avatarImage(src, alt, containerId) {
    const imgContainer = document.createElement("div");
    imgContainer.className = "avatar-image-container";
    imgContainer.id = containerId;

    const imgElement = document.createElement("img");
    imgElement.className = "avatar-image";
    imgElement.src = src;
    imgElement.alt = alt;

    imgContainer.appendChild(imgElement);
    return imgContainer
}

function profileComponent(user, baseURL, outline=false, noBottomOutline=false) {
    const profileContainer = document.createElement("div");
    profileContainer.className = "profile-container";
    if (outline) {
        profileContainer.style.outline = "none";
        profileContainer.style.borderStyle = "solid";
        profileContainer.style.borderWidth = "1px 0";
        profileContainer.style.borderColor = "dimgrey";
        profileContainer.style.padding = "0.4rem 0"
    }

    if (noBottomOutline) {
        profileContainer.style.borderBottomWidth = "0";
    }

    if (user.avatar) {
        const imgSrc = `${baseURL}/resource/image?id=` + user.avatar;
        const avatarImg = avatarImage(imgSrc, user.username, "pf-avatar");
        profileContainer.appendChild(avatarImg);
    } else {
        const defaultAvatar = document.createElement("span");
        defaultAvatar.className = "material-icons";
        defaultAvatar.id = "pf-avatar";
        defaultAvatar.innerText = "account_circle";
        profileContainer.appendChild(defaultAvatar);
    }

    const nameContainer = document.createElement("div");
    nameContainer.className = "name-container";

    const nickname = document.createElement("h3")
    nickname.textContent = escapeHTML(user.nickname);
    nameContainer.appendChild(nickname);

    const username = document.createElement("p");
    username.className = "pf-username"
    username.textContent = "@" + escapeHTML(user.username);
    nameContainer.appendChild(username);

    profileContainer.appendChild(nameContainer);

    return profileContainer;
}