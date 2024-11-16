package util;

public class Utils {
    public static String doubleSlash(String str) {
        str = str.replace("\\", "\\\\");

        return str;
    }

    public static String escapeHTML(String str) {
        str = str.replace("&", "&amp;");
        str = str.replace("<", "&lt;");
        str = str.replace(">", "&gt;");
        str = str.replace("\"", "&quot;");
        str = str.replace("'", "&#039;");

        return str;
    }
}
