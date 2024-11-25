package util;

import dao.UserDAO;
import dao.UserObj;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class RequestHandler {
    public static UserObj checkUserLoggedIn(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String keyFromSession = (String) request.getSession().getAttribute("key");
        if (keyFromSession == null) {
            ResponseFormat.sendJSONResponse(
                    response, 403, ResponseFormat.messageResponse(
                            403, ResponseFormat.NO_SESSION, "Login first"
                    )
            );
            return null;
        }

        String keyFromClient = request.getHeader("Authorization");
        if (keyFromClient == null || !keyFromClient.equals(keyFromSession)) {
            ResponseFormat.sendJSONResponse(
                    response, 403, ResponseFormat.messageResponse(
                            403, ResponseFormat.INVALID_SESSION, "Session not match"
                    )
            );
            return null;
        }

        UserObj user;
        try {
            UserDAO userDAO = new UserDAO();
            user = userDAO.get((String) request.getSession().getAttribute("id"));

        } catch (Exception e) {
            e.printStackTrace();

            ResponseFormat.sendJSONResponse(
                    response, 500, ResponseFormat.messageResponse(
                            500, ResponseFormat.UNKNOWN_ERROR, "Error while fetching user"
                    )
            );
            return null;
        }

        return user;
    }
}
