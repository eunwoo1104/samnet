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
        String type = request.getParameter("type");
        if (type == null || type.isBlank()) {
            ResponseFormat.sendJSONResponse(
                    response, 400, ResponseFormat.messageResponse(
                            400, ResponseFormat.MISSING_DATA, "Type not provided"
                    )
            );
            return;
        }
        if (type.equals("search")) {
            if (query == null) {
                query = "";
            }
            if (query.length() < 2) {
                ResponseFormat.sendJSONResponse(
                        response, 400, ResponseFormat.messageResponse(
                                400, ResponseFormat.INVALID_DATA, "Query too short"
                        )
                );
                return;
            }
            if (!query.isBlank() && !query.contains(" ")) {
                query += "*";
            }
        } else if (!(type.equals("followings") || type.equals("followers") || type.equals("random"))) {
            ResponseFormat.sendJSONResponse(
                    response, 404, ResponseFormat.messageResponse(
                            404, ResponseFormat.UNSUPPORTED_OPERATION, "Type must be search, followings, followers, or random"
                    )
            );
            return;
        } else if (!type.equals("random") && (query == null || query.isBlank())) {
            ResponseFormat.sendJSONResponse(
                    response, 400, ResponseFormat.messageResponse(
                            400, ResponseFormat.INVALID_DATA, "No user provided"
                    )
            );
            return;
        }
        int page = Integer.parseInt(pageParam == null ? "1" : pageParam);

        try {
            List<UserObj> users = null;
            if (type.equals("search")) {
                users = userDAO.getList(query, page);
            } else if (type.equals("followings")) {
                users = userDAO.getFollowingList(query, page);
            } else if (type.equals("followers")) {
                users = userDAO.getFollowerList(query, page);
            } else if (type.equals("random")) {
                users = userDAO.getRandomList(user.getId(), 5);
            } else {
                return;
            }
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
