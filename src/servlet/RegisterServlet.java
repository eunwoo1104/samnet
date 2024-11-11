package servlet;

import dao.UserDAO;
import util.ResponseFormat;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/api/register")
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String nickname = request.getParameter("nickname");
        String username = request.getParameter("username");

        if (email == null || password == null || nickname == null || username == null) {
            ResponseFormat.sendJSONResponse(
                    response, 400, ResponseFormat.messageResponse(
                            400, ResponseFormat.INVALID_DATA, "Missing required data"
                    )
            );
            return;
        }

        try {
            UserDAO userDAO = new UserDAO();

            boolean exists = userDAO.exists(email);
            if (exists) {
                ResponseFormat.sendJSONResponse(
                        response, 400, ResponseFormat.messageResponse(
                                400, ResponseFormat.RESOURCE_EXISTS, "Existing email"
                        )
                );
                return;
            }

            boolean res = userDAO.insert(email, password, nickname, username);
            int status = res ? 200 : 400;

            ResponseFormat.sendJSONResponse(
                    response, status, ResponseFormat.messageResponse(
                            status,
                            res ? ResponseFormat.OK : ResponseFormat.UNKNOWN_ERROR,
                            res ? "Account created" : "Unknown error"
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
