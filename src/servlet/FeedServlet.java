package servlet;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import dao.FeedDAO;
import dao.ImageDAO;
import dao.UserDAO;
import dao.UserObj;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.json.simple.JSONObject;
import util.ImageHandler;
import util.ResponseFormat;

@WebServlet("/api/feed")
public class FeedServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        UserObj user;
        try {
            UserDAO userDAO = new UserDAO();
            user = userDAO.get((String) request.getSession().getAttribute("id"));

        } catch (Exception e) {
            e.printStackTrace();

            ResponseFormat.sendJSONResponse(
                    response, 500, ResponseFormat.messageResponse(
                            500, ResponseFormat.UNKNOWN_ERROR, "Error while fetching user"
                    )
            );
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

        boolean isMultipart = ServletFileUpload.isMultipartContent(request);
        if (!isMultipart) {
            ResponseFormat.sendJSONResponse(
                    response, 400, ResponseFormat.messageResponse(
                            400, ResponseFormat.INVALID_DATA, "Form data incorrect"
                    )
            );
            return;
        }

        ServletFileUpload sfu = new ServletFileUpload(new DiskFileItemFactory());
        String content = null;
        ArrayList<String> files = new ArrayList<>();
        try {
            List<FileItem> items = sfu.parseRequest(request);
            for (FileItem item: items) {
                if (item.isFormField()) {
                    String name = item.getFieldName();
                    if (name.equals("content")) {
                        content = item.getString("UTF-8");
                    }
                }
                else {
                    files.add(ImageHandler.saveImage(item));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();

            ResponseFormat.sendJSONResponse(
                    response, 500, ResponseFormat.messageResponse(
                            500, ResponseFormat.UNKNOWN_ERROR, "Error while parsing"
                    )
            );
            return;
        }

        if (content == null || content.isBlank()) {
            ResponseFormat.sendJSONResponse(
                    response, 400, ResponseFormat.messageResponse(
                            400, ResponseFormat.INVALID_DATA, "Missing required data"
                    )
            );
            return;
        }

        try {
            StringBuilder imageList = new StringBuilder();
            ImageDAO imageDAO = new ImageDAO();
            for (String file: files) {
                imageList.append(imageDAO.insert(user.getId(), file)).append(",");
            }

            FeedDAO feedDAO = new FeedDAO();
            String feedId = feedDAO.insert(user.getId(), content.trim(), imageList.toString());
            if (feedId != null) {
                JSONObject body = new JSONObject();
                body.put("id", feedId);
                ResponseFormat.sendJSONResponse(
                        response, 200, ResponseFormat.response(
                                200, ResponseFormat.OK, body
                        )
                );
            } else {
                ResponseFormat.sendJSONResponse(
                        response, 500, ResponseFormat.messageResponse(
                                500, ResponseFormat.UNKNOWN_ERROR, "Unknown error while inserting"
                        )
                );
            }
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