package servlet;

import dao.UserDAO;
import dao.UserObj;
import org.json.simple.JSONObject;
import util.ResponseFormat;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.UUID;

@WebServlet("/api/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || password == null) {
            ResponseFormat.sendJSONResponse(
                    response, 400, ResponseFormat.messageResponse(
                            400, ResponseFormat.INVALID_DATA, "Missing required data"
                    )
            );
            return;
        }

        try {
            UserDAO userDAO = new UserDAO();

            String[] data = userDAO.preLogin(email);
            if (data == null || data[0] == null) {
                ResponseFormat.sendJSONResponse(
                        response, 404, ResponseFormat.messageResponse(
                                404, ResponseFormat.MISSING_DATA, "Email not found"
                        )
                );
                return;
            } else if (!data[0].equals(password)) {
                ResponseFormat.sendJSONResponse(
                        response, 403, ResponseFormat.messageResponse(
                                403, ResponseFormat.INVALID_DATA, "Invalid password"
                        )
                );
                return;
            }

            UserObj user = userDAO.get(data[1]);
            String sessionKey = UUID.randomUUID().toString();
            request.getSession().setAttribute("id", user.getId());
            request.getSession().setAttribute("key", sessionKey);
            JSONObject body = new JSONObject();
            body.put("session", sessionKey);

            ResponseFormat.sendJSONResponse(
                    response, 200, ResponseFormat.response(
                            200, ResponseFormat.OK, body
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
