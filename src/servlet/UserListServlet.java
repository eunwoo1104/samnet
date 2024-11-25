package servlet;

import dao.UserDAO;
import dao.UserObj;
import org.json.simple.JSONArray;
import util.ResponseFormat;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/api/user/list")
public class UserListServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        /*
        String keyFromSession = (String) request.getSession().getAttribute("key");
        if (keyFromSession == null) {
            ResponseFormat.sendJSONResponse(
                    response, 403, ResponseFormat.messageResponse(
                            403, ResponseFormat.NO_SESSION, "Login first"
                    )
            );
            return;
        }

        String keyFromClient = request.getHeader("Authorization");
        if (keyFromClient == null || !keyFromClient.equals(keyFromSession)) {
            ResponseFormat.sendJSONResponse(
                    response, 403, ResponseFormat.messageResponse(
                            403, ResponseFormat.INVALID_SESSION, "Session not match"
                    )
            );
            return;
        }
        */

        UserDAO userDAO = new UserDAO();
        String query = request.getParameter("query");
        String pageParam = request.getParameter("page");
        if (query == null) {
            query = "";
        }
        int page = Integer.parseInt(pageParam == null ? "1" : pageParam);

        try {
            List<UserObj> users = userDAO.getList(query, page);
            JSONArray userArr = new JSONArray();
            for (UserObj userObj : users) {
                userArr.add(userObj.toJSON());
            }

            ResponseFormat.sendJSONResponse(
                    response, 200, ResponseFormat.response(
                            200, ResponseFormat.OK, userArr
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
