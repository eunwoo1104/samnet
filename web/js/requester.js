const api = (baseURL, keyRequired = true, runAsync = true) => {
    let result = null;
    const baseOptions = (callback, onError) => {
        return {
            dataType: "json",
            async: runAsync,
            beforeSend: xhr => {
                if (keyRequired)
                    xhr.setRequestHeader("Authorization", localStorage.getItem("session"));
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
            list: (page, searchQuery, callback = null, onError = null) => {
                let urlQuery = "?page=" + page;
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
            }
        }
    };
}