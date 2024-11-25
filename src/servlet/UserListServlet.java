package servlet;

import dao.UserDAO;
import dao.UserObj;
import org.json.simple.JSONArray;
import util.RequestHandler;
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

        UserObj user = RequestHandler.checkUserLoggedIn(request, response);
        if (user == null) {
            return;
        }

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
