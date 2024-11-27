package servlet;

import dao.UserDAO;
import util.ResponseFormat;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/api/user/restore")
public class SessionRestoreServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");

        String sessionKey = request.getHeader("Authorization");

        try {
            UserDAO userDAO = new UserDAO();
            String maybeId = userDAO.getUIDFromSession(sessionKey);
            if (maybeId == null) {
                ResponseFormat.sendJSONResponse(
                        response, 403, ResponseFormat.messageResponse(
                                403, ResponseFormat.INVALID_SESSION, "No available session found"
                        )
                );
                return;
            }
            request.getSession().setAttribute("id", maybeId);
            request.getSession().setAttribute("key", sessionKey);
            userDAO.postLogin(maybeId, sessionKey);

            ResponseFormat.sendJSONResponse(
                    response, 200, ResponseFormat.response(
                            200, ResponseFormat.OK
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
}
