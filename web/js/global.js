function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function moveto(url) {
    window.location.href = url;
}

const AJAX = {
    call: (url, body, ok, err) => {
        $.ajax(
            {

            }
        )
    }
}
