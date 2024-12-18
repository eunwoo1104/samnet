const api = (baseURL, keyRequired = true, runAsync = true) => {
    let result = null;
    const baseOptions = (callback, onError) => {
        return {
            dataType: "json",
            async: runAsync,
            xhr: () => {
                const xhr = new XMLHttpRequest();

                const progressEvt = evt => {
                    if (!evt.lengthComputable) return;
                    const percent = evt.loaded / evt.total;
                    setProgressBar(percent * 100);
                };
                xhr.addEventListener("progress", progressEvt);
                xhr.upload.addEventListener("progress", progressEvt);

                return xhr;
            },
            beforeSend: xhr => {
                const sessionKey = localStorage.getItem("session");
                if (keyRequired && sessionKey)
                    xhr.setRequestHeader("Authorization", sessionKey);
            },
            success: data => {
                result = data.data;
                if (callback)
                    callback(result);
            },
            error: (xhr, status, error) => {
                if (onError)
                    onError(xhr, status, error);
            }
        };
    };

    return {
        user: {
            get: (userId = null, callback = null, onError = null) => {
                let urlQuery = "?";
                if (userId)
                    urlQuery += "id=" + userId;
                $.ajax(
                    {
                        url: baseURL + "/api/user" + urlQuery,
                        type: "GET",
                        ...baseOptions(callback, onError)
                    }
                );
                return result;
            },
            delete: (callback = null, onError = null) => {
                $.ajax(
                    {
                        url: baseURL + "/api/user",
                        type: "DELETE",
                        ...baseOptions(callback, onError)
                    }
                );
                return result;
            },
            list: (page, listType, searchQuery, callback = null, onError = null) => {
                let urlQuery = "?page=" + page;
                urlQuery += "&type=" + listType;
                urlQuery += "&query=" + searchQuery;
                $.ajax(
                    {
                        url: baseURL + "/api/user/list" + urlQuery,
                        type: "GET",
                        ...baseOptions(callback, onError)
                    }
                );
                return result;
            },
            edit: (formData, callback = null, onError = null) => {
                $.ajax(
                    {
                        url: baseURL + "/api/user",
                        type: "POST",
                        data: formData,
                        processData: false,
                        contentType: false,
                        ...baseOptions(callback, onError)
                    }
                );
                return result;
            },
            action: (payload, callback = null, onError = null) => {
                $.ajax(
                    {
                        url: baseURL + "/api/user/action",
                        type: "POST",
                        data: payload,
                        ...baseOptions(callback, onError)
                    }
                );
                return result;
            }
        },
        feed: {
            get: (feedId, callback = null, onError = null) => {
                $.ajax(
                    {
                        url: baseURL + "/api/feed?id=" + feedId,
                        type: "GET",
                        ...baseOptions(callback, onError)
                    }
                );
                return result;
            },
            post: (formData, callback = null, onError = null) => {
                $.ajax(
                    {
                        url: baseURL + "/api/feed",
                        type: "POST",
                        data: formData,
                        processData: false,
                        contentType: false,
                        ...baseOptions(callback, onError)
                    }
                );
                return result;
            },
            delete: (feedId, callback = null, onError = null) => {
                $.ajax(
                    {
                        url: baseURL + "/api/feed?id=" + feedId,
                        type: "DELETE",
                        ...baseOptions(callback, onError)
                    }
                );
                return result;
            },
            list: (page, targetUser = null, callback = null, onError = null) => {
                let urlQuery = "?page=" + page;
                if (targetUser)
                    urlQuery += "&user=" + targetUser;
                $.ajax(
                    {
                        url: baseURL + "/api/feed/list" + urlQuery,
                        type: "GET",
                        ...baseOptions(callback, onError)
                    }
                );
                return result;
            },
            edit: (formData, callback = null, onError = null) => {
                $.ajax(
                    {
                        url: baseURL + "/api/feed/edit",
                        type: "POST",
                        data: formData,
                        processData: false,
                        contentType: false,
                        ...baseOptions(callback, onError)
                    }
                );
                return result;
            },
            action: (payload, callback = null, onError = null) => {
                $.ajax(
                    {
                        url: baseURL + "/api/feed/action",
                        type: "POST",
                        data: payload,
                        ...baseOptions(callback, onError)
                    }
                );
                return result;
            },
            view: (feedId, callback = null, onError = null) => {
                $.ajax(
                    {
                        url: baseURL + "/api/feed/view?id=" + feedId,
                        type: "GET",
                        ...baseOptions(callback, onError)
                    }
                );
                return result;
            }
        }
    };
}