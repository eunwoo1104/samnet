function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function moveto(url) {
    window.location.href = url;
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

const AJAX = {
    call: (url, body, ok, err) => {
        $.ajax(
            {}
        )
    }
}
