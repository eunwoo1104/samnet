package dao;

import util.ConnectionPool;

import javax.naming.NamingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

    public ArrayList<UserObj> getList() throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM user";
            stmt = conn.prepareStatement(sql);

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

    public boolean update(String id, String email, String username, String nickname, String bio) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "UPDATE user SET email=?, username=?, nickname=?, bio=? WHERE id=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, email);
            stmt.setString(2, username);
            stmt.setString(3, nickname);
            stmt.setString(4, bio);
            stmt.setString(5, id);

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
