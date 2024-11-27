package servlet;

import dao.FeedDAO;
import dao.FeedObj;
import dao.ImageDAO;
import dao.UserObj;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import util.ImageHandler;
import util.RequestHandler;
import util.ResponseFormat;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/api/feed/edit")
public class FeedEditServlet extends HttpServlet {
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
        String newContent = null;
        String feedId = null;
        boolean imgChanged = false;
        ArrayList<String> files = new ArrayList<>();
        try {
            List<FileItem> items = sfu.parseRequest(request);
            for (FileItem item: items) {
                if (item.isFormField()) {
                    String name = item.getFieldName();
                    if (name.equals("content")) {
                        newContent = item.getString("UTF-8").trim();
                    } else if (name.equals("id")) {
                        feedId = item.getString("UTF-8").trim();
                    } else if (name.equals("imgChanged")) {
                        String imgChangedField = item.getString("UTF-8").trim();
                        imgChanged = imgChangedField.equals("true");
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

        if (feedId == null || feedId.isBlank()) {
            ResponseFormat.sendJSONResponse(
                    response, 404, ResponseFormat.messageResponse(
                            404, ResponseFormat.INVALID_DATA, "Feed ID missing"
                    )
            );
            return;
        }

        try {
            FeedDAO feedDAO = new FeedDAO();
            FeedObj tgtFeed = feedDAO.get(feedId);

            if (tgtFeed == null) {
                ResponseFormat.sendJSONResponse(
                        response, 404, ResponseFormat.messageResponse(
                                404, ResponseFormat.MISSING_DATA, "Unknown feed"
                        )
                );
                return;
            }

            if (!(tgtFeed.getUser().equals(user.getId()) || user.isAdmin())) {
                ResponseFormat.sendJSONResponse(
                        response, 403, ResponseFormat.messageResponse(
                                403, ResponseFormat.NO_PERMISSION, "Not user's feed"
                        )
                );
                return;
            }

            String newImages;
            if (imgChanged) {
                StringBuilder imageList = new StringBuilder();
                ImageDAO imageDAO = new ImageDAO();
                for (String file: files) {
                    imageList.append(imageDAO.insert(user.getId(), file)).append(",");
                }

                if (imageList.isEmpty()) {
                    newImages = null;
                } else {
                    newImages = imageList.toString();
                }

                String oldImages = tgtFeed.getImages();
                if (oldImages != null) {
                    for (String img: oldImages.split(",")) {
                        if (img.isBlank()) continue;

                        String dir = imageDAO.get(img);
                        if (dir != null) {
                            ImageHandler.deleteImage(dir);
                        }
                        imageDAO.delete(img);
                    }
                }
            } else {
                newImages = tgtFeed.getImages();
            }

            boolean res = feedDAO.update(feedId, newContent, newImages);

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
