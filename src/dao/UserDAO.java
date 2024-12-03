package dao;

import util.ConnectionPool;

import javax.naming.NamingException;
import java.io.Console;
import java.sql.*;
import java.util.ArrayList;

public class UserDAO {
    public String[] preLogin(String email) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT password, id FROM user WHERE email=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, email);

            rs = stmt.executeQuery();
            if (!rs.next()) {
                return null;
            }

            return new String[]{rs.getString("password"), rs.getString("id")};

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean postLogin(String id, String key) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "UPDATE user SET session=?, last_login=NOW() WHERE id=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, key);
            stmt.setString(2, id);

            int count = stmt.executeUpdate();
            return count == 1;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean invalidateSession(String id) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "UPDATE user SET session=NULL WHERE id=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, id);

            int count = stmt.executeUpdate();
            return count == 1;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean exists(String email) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT id FROM user WHERE email=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, email);

            rs = stmt.executeQuery();
            return rs.next();

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean idExists(String id) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT id FROM user WHERE id=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, id);

            rs = stmt.executeQuery();
            return rs.next();

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public UserObj get(String id) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM user WHERE id=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, id);

            rs = stmt.executeQuery();
            if (!rs.next()) return null;

            return new UserObj(
                    rs.getString("id"),
                    rs.getString("email"),
                    rs.getString("nickname"),
                    rs.getString("username"),
                    rs.getString("bio"),
                    rs.getString("avatar"),
                    rs.getString("created_at"),
                    rs.getInt("flag")
            );

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public int[] getFollowCount(String id) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT (SELECT COUNT(*) FROM follow WHERE user=?), (SELECT COUNT(*) FROM follow WHERE target=?)";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, id);
            stmt.setString(2, id);

            rs = stmt.executeQuery();
            if (!rs.next()) return new int[]{-1, -1};

            return new int[]{rs.getInt(1), rs.getInt(2)};

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public String getUIDFromSession(String session) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT id FROM user WHERE session=? AND TIMESTAMPDIFF(DAY, last_login, NOW()) <= 5";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, session);

            rs = stmt.executeQuery();
            if (!rs.next()) return null;

            return rs.getString("id");

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public ArrayList<UserObj> getList(String query, int page) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT *, MATCH(email, nickname, username, bio) AGAINST(? in boolean mode) as relevance FROM user WHERE MATCH(email, nickname, username, bio) AGAINST(? in boolean mode) ORDER BY relevance DESC LIMIT 10 OFFSET ?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, query);
            stmt.setString(2, query);
            stmt.setInt(3, 10 * (page > 0 ? page - 1 : 0));

            rs = stmt.executeQuery();
            ArrayList<UserObj> users = new ArrayList<>();
            while (rs.next()) {
                users.add(new UserObj(
                        rs.getString("id"),
                        rs.getString("email"),
                        rs.getString("nickname"),
                        rs.getString("username"),
                        rs.getString("bio"),
                        rs.getString("avatar"),
                        rs.getString("created_at"),
                        rs.getInt("flag")
                ));
            }

            return users;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public ArrayList<UserObj> getFollowingList(String id, int page) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM user WHERE id in (SELECT follow.target FROM follow WHERE user=?) ORDER BY id DESC LIMIT 10 OFFSET ?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, id);
            stmt.setInt(2, 10 * (page > 0 ? page - 1 : 0));

            rs = stmt.executeQuery();
            ArrayList<UserObj> users = new ArrayList<>();
            while (rs.next()) {
                users.add(new UserObj(
                        rs.getString("id"),
                        rs.getString("email"),
                        rs.getString("nickname"),
                        rs.getString("username"),
                        rs.getString("bio"),
                        rs.getString("avatar"),
                        rs.getString("created_at"),
                        rs.getInt("flag")
                ));
            }

            return users;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public ArrayList<UserObj> getFollowerList(String id, int page) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM user WHERE id in (SELECT follow.user FROM follow WHERE target=?) ORDER BY id DESC LIMIT 10 OFFSET ?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, id);
            stmt.setInt(2, 10 * (page > 0 ? page - 1 : 0));

            rs = stmt.executeQuery();
            ArrayList<UserObj> users = new ArrayList<>();
            while (rs.next()) {
                users.add(new UserObj(
                        rs.getString("id"),
                        rs.getString("email"),
                        rs.getString("nickname"),
                        rs.getString("username"),
                        rs.getString("bio"),
                        rs.getString("avatar"),
                        rs.getString("created_at"),
                        rs.getInt("flag")
                ));
            }

            return users;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean getUserFollows(String id, String target) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM follow WHERE user=? AND target=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, id);
            stmt.setString(2, target);

            rs = stmt.executeQuery();
            return rs.next();

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public UserObj getAuthor(String feedId) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM user WHERE id=(SELECT user FROM feed WHERE idx=?)";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, feedId);

            rs = stmt.executeQuery();
            if (!rs.next()) return null;

            return new UserObj(
                    rs.getString("id"),
                    rs.getString("email"),
                    rs.getString("nickname"),
                    rs.getString("username"),
                    rs.getString("bio"),
                    rs.getString("avatar"),
                    rs.getString("created_at"),
                    rs.getInt("flag")
            );

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean insert(String email, String password, String nickname, String username) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "INSERT INTO user(email, password, nickname, username) VALUES(?, ?, ?, ?)";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, email);
            stmt.setString(2, password);
            stmt.setString(3, nickname);
            stmt.setString(4, username);

            int count = stmt.executeUpdate();
            return count == 1;

        } finally {
            if(stmt != null) stmt.close();
            if(conn != null) conn.close();
        }
    }

    public boolean update(String id, String email, String username, String nickname, String bio, String avatar) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "UPDATE user SET email=?, username=?, nickname=?, bio=?, avatar=? WHERE id=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, email);
            stmt.setString(2, username);
            stmt.setString(3, nickname);
            stmt.setString(4, bio);
            stmt.setString(5, avatar);
            stmt.setString(6, id);

            int count = stmt.executeUpdate();
            return count == 1;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean updatePassword(String id, String password) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "UPDATE user SET password=? WHERE id=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, password);
            stmt.setString(2, id);

            int count = stmt.executeUpdate();
            return count == 1;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean likedToFeed(String uid, String idx) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT feed FROM heart WHERE feed=? AND user=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, idx);
            stmt.setString(2, uid);

            rs = stmt.executeQuery();
            return rs.next();

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean follow(String uid, String target) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        CallableStatement stmt = null;
        try {
            String sql = "CALL toggleFollow(?, ?, ?)";
            stmt = conn.prepareCall(sql);

            stmt.setString(1, uid);
            stmt.setString(2, target);
            stmt.registerOutParameter(3, Types.BOOLEAN);

            stmt.execute();
            return stmt.getBoolean(3);

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean delete(String uid) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "DELETE FROM user WHERE id=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, uid);

            int count = stmt.executeUpdate();
            return count == 1;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }
}
