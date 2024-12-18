package util;

import org.apache.commons.fileupload.FileItem;

import java.io.File;

public class ImageHandler {
    // TODO: allow changing save location via setting file
    public static final String SAVE_LOCATION = System.getProperty("user.home") + "/samnet/images/";

    public static String saveImage(FileItem file) throws Exception {
        String fname = file.getName();
        String extension = fname.substring(fname.lastIndexOf("."));
        fname = System.currentTimeMillis() + extension;

        File saveFile = new File(SAVE_LOCATION + fname);
        file.write(saveFile);

        return fname;
    }

    public static File getImage(String fname) {
        File savedFile = new File(SAVE_LOCATION + fname);
        if (!savedFile.exists()) {
            return null;
        }
        return savedFile;
    }

    public static boolean deleteImage(String fname) {
        File image = getImage(fname);
        if (image == null) {
            return false;
        }
        return image.delete();
    }
}
