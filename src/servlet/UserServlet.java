package servlet;
import dao.ImageDAO;
import dao.UserDAO;
import dao.UserObj;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.json.simple.JSONObject;
import util.ImageHandler;
import util.RequestHandler;
import util.ResponseFormat;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/api/user")
public class UserServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String keyFromSession = (String) request.getSession().getAttribute("key");
        String keyFromClient = request.getHeader("Authorization");
        String targetUser = request.getParameter("user");
        String currentUser = (String) request.getSession().getAttribute("id");
        if (targetUser == null && keyFromSession == null) {
            ResponseFormat.sendJSONResponse(
                    response, 403, ResponseFormat.messageResponse(
                            403, ResponseFormat.NO_SESSION, "Login first"
                    )
            );
            return;
        }
        if (targetUser == null && (keyFromClient == null || !keyFromClient.equals(keyFromSession))) {
            ResponseFormat.sendJSONResponse(
                    response, 403, ResponseFormat.messageResponse(
                            403, ResponseFormat.INVALID_SESSION, "Session not match"
                    )
            );
            return;
        }

        try {
            UserDAO userDAO = new UserDAO();
            String target;
            if (targetUser != null) {
                target = targetUser;
            } else {
                target = currentUser;
            }
            UserObj user = userDAO.get(target);
            JSONObject resp = user.toJSON();
            if (currentUser != null && !currentUser.equals(target)) {
                resp.put("follows", userDAO.getUserFollows(currentUser, targetUser));
            }

            ResponseFormat.sendJSONResponse(
                    response, 200, ResponseFormat.response(
                            200, ResponseFormat.OK, resp
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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: change to put or patch
        request.setCharacterEncoding("UTF-8");

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

        boolean isMultipart = ServletFileUpload.isMultipartContent(request);
        if (!isMultipart) {
            ResponseFormat.sendJSONResponse(
                    response, 400, ResponseFormat.messageResponse(
                            400, ResponseFormat.INVALID_DATA, "Form data incorrect"
                    )
            );
            return;
        }

        // TODO: more graceful way to handle this
        String newEmail = null;
        String newNickname = null;
        String newUsername = null;
        String newBio = null;
        String newAvatarURL = null;
        boolean setDefaultAvatar = false;

        ServletFileUpload sfu = new ServletFileUpload(new DiskFileItemFactory());

        try {
            List<FileItem> items = sfu.parseRequest(request);
            for (FileItem item: items) {
                if (item.isFormField()) {
                    String name = item.getFieldName();
                    if (name.equals("email")) {
                        newEmail = item.getString("UTF-8").trim();
                    } else if (name.equals("nickname")) {
                        newNickname = item.getString("UTF-8").trim();
                    } else if (name.equals("newUsername")) {
                        newUsername = item.getString("UTF-8").trim();
                    } else if (name.equals("newBio")) {
                        newBio = item.getString("UTF-8").trim();
                    } else if (name.equals("defaultAvatar")) {
                        String defaultAvatar = item.getString("UTF-8").trim();
                        setDefaultAvatar = defaultAvatar.equals("true");
                    }
                }
                else {
                    newAvatarURL = ImageHandler.saveImage(item);
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

        if (newEmail == null) {
            newEmail = user.getEmail();
        }
        if (newNickname == null) {
            newNickname = user.getNickname();
        }
        if (newUsername == null) {
            newUsername = user.getUsername();
        }
        if (newBio == null) {
            newBio = user.getBio();
        }

        try {
            String newAvatar = null;
            if (newAvatarURL != null) {
                ImageDAO imageDAO = new ImageDAO();
                newAvatar = imageDAO.insert(user.getId(), newAvatarURL);
            } else if (!setDefaultAvatar) {
                newAvatar = user.getAvatar();
            }

            UserDAO userDAO = new UserDAO();
            userDAO.update(user.getId(), newEmail, newUsername, newNickname, newBio, newAvatar);

            ResponseFormat.sendJSONResponse(
                    response, 200, ResponseFormat.response(
                            200, ResponseFormat.OK
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

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

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

        try {
            UserDAO userDAO = new UserDAO();
            ImageDAO imageDAO = new ImageDAO();

            String avatar = user.getAvatar();
            if (avatar != null) {
                String dir = imageDAO.get(avatar);
                if (dir != null) {
                    ImageHandler.deleteImage(dir);
                }
                imageDAO.delete(avatar);
            }

            userDAO.delete(user.getId());

            ResponseFormat.sendJSONResponse(
                    response, 200, ResponseFormat.response(
                            200, ResponseFormat.OK
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
