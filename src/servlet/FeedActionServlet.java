package servlet;
import dao.FeedDAO;
import dao.UserDAO;
import dao.UserObj;
import org.json.simple.JSONObject;
import util.RequestHandler;
import util.ResponseFormat;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/api/feed/action")
public class FeedActionServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");

        UserObj user = RequestHandler.checkUserLoggedIn(request, response);
        if (user == null) {
            return;
        }

        if (user.isBlocked()) {
            ResponseFormat.sendJSONResponse(
                    response, 403, ResponseFormat.messageResponse(
                            403, ResponseFormat.USER_BLOCKED, "Blocked user"
                    )
            );
            return;
        }

        // actions to perform related to feed
        String targetFeed = request.getParameter("feed");
        String paramHeart = request.getParameter("heart");

        if (targetFeed == null || paramHeart == null) {
            ResponseFormat.sendJSONResponse(
                    response, 400, ResponseFormat.messageResponse(
                            400, ResponseFormat.INVALID_DATA, "Missing required data"
                    )
            );
            return;
        }

        boolean toggleHeart = paramHeart.trim().equals("true");

        try {
            FeedDAO feedDAO = new FeedDAO();
            if (!feedDAO.exists(targetFeed)) {
                ResponseFormat.sendJSONResponse(
                        response, 404, ResponseFormat.messageResponse(
                                404, ResponseFormat.MISSING_DATA, "Feed not found"
                        )
                );
                return;
            }

            JSONObject res = new JSONObject();
            if (toggleHeart) {
                int[] heartResult = feedDAO.toggleHeart(targetFeed, user.getId());
                res.put("heart", heartResult[0]);
                res.put("heartCount", heartResult[1]);
            }

            ResponseFormat.sendJSONResponse(
                    response, 200, ResponseFormat.response(
                            200, ResponseFormat.OK, res
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
