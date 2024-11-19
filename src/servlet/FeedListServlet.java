package servlet;

import dao.FeedDAO;
import dao.FeedObj;
import dao.UserDAO;
import dao.UserObj;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import util.ResponseFormat;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;

@WebServlet("/api/feed/list")
public class FeedListServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");

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

        String userId = (String) request.getSession().getAttribute("id");
        FeedDAO feedDAO = new FeedDAO();
        UserDAO userDAO = new UserDAO();
        JSONArray feedArr = new JSONArray();
        HashMap<String, UserObj> userCache = new HashMap<>();
        String pageParam = request.getParameter("page");
        int page = Integer.parseInt(pageParam == null ? "1" : pageParam);

        try {
            List<FeedObj> feeds = feedDAO.getFollowedList(userId, page);
            for (FeedObj feed : feeds) {
                JSONObject feedObj = feed.toJSON();
                String author = feed.getUser();
                if (!userCache.containsKey(author)) {
                    UserObj userObj = userDAO.get(author);
                    userCache.put(author, userObj);
                }
                feedObj.put("author", userCache.get(author).toJSON());
                feedArr.add(feedObj);
            }

            ResponseFormat.sendJSONResponse(
                    response, 200, ResponseFormat.response(
                            200, ResponseFormat.OK, feedArr
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
