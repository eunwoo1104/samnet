package servlet;
import dao.UserDAO;
import dao.UserObj;
import org.json.simple.JSONObject;
import util.ResponseFormat;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/api/user")
public class UserServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String keyFromSession = (String) request.getSession().getAttribute("key");
        String keyFromClient = request.getHeader("Authorization");
        String targetUser = request.getParameter("user");
        String currentUser = (String) request.getSession().getAttribute("id");
        if (targetUser == null && keyFromSession == null) {
            ResponseFormat.sendJSONResponse(
                    response, 403, ResponseFormat.messageResponse(
                            403, ResponseFormat.NO_SESSION, "Login first"
                    )
            );
            return;
        }
        if (targetUser == null && (keyFromClient == null || !keyFromClient.equals(keyFromSession))) {
            ResponseFormat.sendJSONResponse(
                    response, 403, ResponseFormat.messageResponse(
                            403, ResponseFormat.INVALID_SESSION, "Session not match"
                    )
            );
            return;
        }

        try {
            UserDAO userDAO = new UserDAO();
            String target;
            if (targetUser != null) {
                target = targetUser;
            } else {
                target = currentUser;
            }
            UserObj user = userDAO.get(target);
            JSONObject resp = user.toJSON();
            if (currentUser != null && !currentUser.equals(target)) {
                resp.put("follows", userDAO.getUserFollows(currentUser, targetUser));
            }

            ResponseFormat.sendJSONResponse(
                    response, 200, ResponseFormat.response(
                            200, ResponseFormat.OK, resp
                    )
            );

        } catch (Exception e) {
            e.printStackTrace();

            ResponseFormat.sendJSONResponse(
                    response, 500, ResponseFormat.messageResponse(
                            500, ResponseFormat.UNKNOWN_ERROR, "SQL Error"
                    )
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}
