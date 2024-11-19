function feedComponent(feedIdx, author, content, images, baseURL, replyOf=null, noBottomOutline=false, linkToView=false) {
    // i want to use typescript and react
    if (author.avatar === undefined || author.username === undefined || author.nickname === undefined) {
        const errorElement = document.createElement("p");
        errorElement.innerText = "컨텐츠 생성에 문제가 발생했습니다.";
        return errorElement;
    }

    const container = document.createElement("div");
    container.className = "feed-container";
    if (noBottomOutline) {
        container.style.borderBottomWidth = "0";
    }

    const feedHeader = document.createElement("div");
    feedHeader.className = "feed-header";

    const authorContainer = document.createElement("div");
    authorContainer.className = "feed-author-container clickable mb-sm";
    authorContainer.onclick = e => moveto(baseURL + "/user?id=" + author.id);

    if (author.avatar) {
        const avatarImg = document.createElement("img");
        avatarImg.src = author.avatar;
        avatarImg.alt = author.username;
        // TODO: avatar image style
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
        const viewButton = document.createElement("div");
        viewButton.className = "clickable";
        viewButton.addEventListener("click", e => {
            moveto(baseURL + "/feed/view.jsp?id=" + feedIdx);
        });
        const viewIcon = document.createElement("span");
        viewIcon.className = "material-icons";
        viewIcon.textContent = "chevron_right";
        viewButton.appendChild(viewIcon);
        feedHeader.appendChild(viewButton);
    }

    container.appendChild(feedHeader);

    const context = document.createElement("p");
    context.className = "feed-context";
    context.innerText = escapeHTML(content);
    container.appendChild(context);

    const imageContainer = document.createElement("div");
    imageContainer.className = "feed-image-container mt-xs";
    let imgIncluded = false;
    images.trim().split(",").forEach(img => {
        if (!img) return;
        const imgURL = `${baseURL}/resource/image?id=` + img;
        const imgChild = document.createElement("img");
        imgChild.setAttribute("src", imgURL);
        imgChild.setAttribute("alt", img);
        imgChild.className = "feed-image";
        imageContainer.appendChild(imgChild);
        imgIncluded = true;
    });
    if (!imgIncluded) {
        imageContainer.style.display = "none";
    }

    container.appendChild(imageContainer);

    return container;
}