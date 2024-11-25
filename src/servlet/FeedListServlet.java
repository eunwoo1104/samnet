package servlet;

import dao.FeedDAO;
import dao.FeedObj;
import dao.UserDAO;
import dao.UserObj;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import util.RequestHandler;
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

        UserObj user = RequestHandler.checkUserLoggedIn(request, response);
        if (user == null) {
            return;
        }

        String userId = (String) request.getSession().getAttribute("id");
        FeedDAO feedDAO = new FeedDAO();
        UserDAO userDAO = new UserDAO();
        JSONArray feedArr = new JSONArray();
        HashMap<String, UserObj> userCache = new HashMap<>();
        String pageParam = request.getParameter("page");
        String targetUser = request.getParameter("user");
        int page = Integer.parseInt(pageParam == null ? "1" : pageParam);

        try {
            List<FeedObj> feeds;
            if (targetUser != null) {
                feeds = feedDAO.getList(targetUser, page);
            } else {
                feeds = feedDAO.getFollowedList(userId, page);
            }
            for (FeedObj feed : feeds) {
                JSONObject feedObj = feed.toJSON();
                String author = feed.getUser();
                if (!userCache.containsKey(author)) {
                    UserObj userObj = userDAO.get(author);
                    userCache.put(author, userObj);
                }
                feedObj.put("author", userCache.get(author).toJSON());
                // todo: add replyAuthor field
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
