package util;

import org.apache.commons.validator.routines.EmailValidator;

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

    public static boolean userDataValid(String email, String password, String nickname, String username) {
        EmailValidator emailValidator = EmailValidator.getInstance();
        boolean emailMatch = emailValidator.isValid(email);
        boolean passwordMatch = password.length() == 64;
        boolean unameMatch = username.matches("^[a-zA-Z0-9]+$") && username.length() <= 32 && username.length() >= 2;
        boolean nnameMatch = nickname.length() >=2 && nickname.length() <= 32;
        return emailMatch && passwordMatch && unameMatch && nnameMatch;
    }

    public static boolean userEditDataValid(String email, String nickname, String username, String bio) {
        EmailValidator emailValidator = EmailValidator.getInstance();
        boolean emailMatch = emailValidator.isValid(email);
        boolean unameMatch = username.matches("^[a-zA-Z0-9]+$") && username.length() <= 32 && username.length() >= 2;
        boolean nnameMatch = nickname.length() >=2 && nickname.length() <= 32;
        boolean bioMatch = bio == null || bio.isBlank() || bio.length() <= 1024;
        return emailMatch && unameMatch && nnameMatch && bioMatch;
    }
}
