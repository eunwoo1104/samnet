package servlet;

import dao.ImageDAO;
import org.apache.commons.io.IOUtils;
import util.ImageHandler;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

@WebServlet("/resource/image")
public class ImageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String imageId = request.getParameter("id");
        if (imageId == null || imageId.isBlank()) {
            response.setStatus(404);
            return;
        }

        File image;
        String imageType;
        try {
            ImageDAO imageDAO = new ImageDAO();
            String imageDir = imageDAO.get(imageId);
            if (imageDir == null) {
                response.setStatus(404);
                return;
            }

            image = ImageHandler.getImage(imageDir);
            if (image == null) {
                response.setStatus(410);
                return;
            }
            String[] tmp = imageDir.split("\\.");
            imageType = tmp[tmp.length - 1];

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            return;
        }

        response.setContentType("image/" + imageType);
        byte[] content = IOUtils.toByteArray(new FileInputStream(image));
        response.setContentLength(content.length);
        response.getOutputStream().write(content);
    }
}
