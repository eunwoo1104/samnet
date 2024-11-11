package util;

import org.json.simple.JSONObject;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;

public class ResponseFormat {
    public static String OK = "OK";

    public static String RESOURCE_EXISTS = "RESOURCE_EXISTS";
    public static String UNKNOWN_ERROR = "UNKNOWN_ERROR";
    public static String INVALID_DATA = "INVALID_DATA";
    public static String MISSING_DATA = "MISSING_DATA";
    public static String CREDENTIAL_ERROR = "CREDENTIAL_ERROR";

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
