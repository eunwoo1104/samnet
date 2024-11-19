package util;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;

public class ResponseFormat {
    public final static String OK = "OK";

    public final static String RESOURCE_EXISTS = "RESOURCE_EXISTS";
    public final static String UNKNOWN_ERROR = "UNKNOWN_ERROR";
    public final static String INVALID_DATA = "INVALID_DATA";
    public final static String MISSING_DATA = "MISSING_DATA";
    public final static String CREDENTIAL_ERROR = "CREDENTIAL_ERROR";
    public final static String NO_SESSION = "NO_SESSION";
    public final static String INVALID_SESSION = "INVALID_SESSION";
    public final static String USER_BLOCKED = "USER_BLOCKED";

    public static String response(int status, String code) {
        JSONObject obj = new JSONObject();
        obj.put("status", status);
        obj.put("code", code);

        return obj.toJSONString();
    }

    public static String response(int status, String code, JSONObject data) {
        JSONObject obj = new JSONObject();
        obj.put("status", status);
        obj.put("code", code);
        obj.put("data", data);

        return obj.toJSONString();
    }

    public static String response(int status, String code, JSONArray data) {
        JSONObject obj = new JSONObject();
        obj.put("status", status);
        obj.put("code", code);
        obj.put("data", data);

        return obj.toJSONString();
    }

    public static String messageResponse(int status, String code, String message) {
        JSONObject data = new JSONObject();
        data.put("message", message);
        return response(status, code, data);
    }

    public static void sendJSONResponse(HttpServletResponse response, int status, String body) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=utf-8");
        response.setStatus(status);
        response.getWriter().println(body);
    }
}
