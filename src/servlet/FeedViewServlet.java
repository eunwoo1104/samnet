package servlet;

import dao.FeedDAO;
import dao.FeedObj;
import dao.UserDAO;
import dao.UserObj;
import org.json.simple.JSONObject;
import util.ResponseFormat;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/api/feed/view")
public class FeedViewServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");

        String feedId = request.getParameter("id");
        if (feedId == null || feedId.isBlank()) {
            ResponseFormat.sendJSONResponse(
                    response, 404, ResponseFormat.messageResponse(
                            404, ResponseFormat.INVALID_DATA, "Feed ID missing"
                    )
            );
            return;
        }

        String keyFromSession = (String) request.getSession().getAttribute("key");
        String keyFromClient = request.getHeader("Authorization");
        if (keyFromClient != null && !keyFromClient.equals(keyFromSession)) {
            ResponseFormat.sendJSONResponse(
                    response, 403, ResponseFormat.messageResponse(
                            403, ResponseFormat.INVALID_SESSION, "Session not match"
                    )
            );
            return;
        }

        try {
            FeedDAO feedDAO = new FeedDAO();
            FeedObj feed = feedDAO.get(feedId);
            if (feed == null) {
                ResponseFormat.sendJSONResponse(
                        response, 404, ResponseFormat.messageResponse(
                                404, ResponseFormat.MISSING_DATA, "Feed not found"
                        )
                );
                return;
            }
            int initHeartCount = feedDAO.getHeartCount(feedId);

            UserDAO userDAO = new UserDAO();
            UserObj author = userDAO.get(feed.getUser());
            String currentUser = (String) request.getSession().getAttribute("id");
            boolean voted = false;
            boolean ableToEdit = feed.getUser().equals(currentUser);
            if (currentUser != null && !currentUser.isBlank()) {
                voted = userDAO.likedToFeed(currentUser, feedId);
            }

            JSONObject feedData = feed.toJSON();
            feedData.put("initHeartCount", initHeartCount);
            feedData.put("author", author.toJSON());
            feedData.put("voted", voted);
            feedData.put("ableToEdit", ableToEdit);

            UserObj replyAuthor = null;
            if (feed.getReplyOf() != null) {
                replyAuthor = userDAO.getAuthor(feed.getReplyOf());
                feedData.put("replyAuthor", replyAuthor.toJSON());
            }

            ResponseFormat.sendJSONResponse(
                    response, 200, ResponseFormat.response(
                            200, ResponseFormat.OK, feedData
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
