function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function moveto(url) {
    window.location.href = url;
}

function escapeHTML(text, lineBreak=false) {
    let newText = text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
    if (lineBreak) {
        newText = newText.replace(/(\r\n|\r|\n)/g, "<br>");
    }
    return newText;
}

function limitTextLength(text, maxSize) {
    if (text.length <= maxSize) return text;
    return text.substring(0, maxSize-3) + "...";
}

function decodeUserFlag(flag) {
    if (flag & (1 << 2)) {
        return "blocked";
    } else if (flag & (1 << 0)) {
        return "admin";
    } else if (flag & (1 << 1)) {
        return "verified";
    }
}

async function encrypt(text) {
    const encoder = new TextEncoder();
    const pwEncode = encoder.encode(text);
    return await crypto.subtle
        .digest("SHA-256", pwEncode)
        .then((hashBuffer) => {
            const hashArray = Array.from(new Uint8Array(hashBuffer)); // convert buffer to byte array
            return hashArray
                .map((b) => b.toString(16).padStart(2, "0"))
                .join("");
        });
}
