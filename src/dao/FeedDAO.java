package dao;

import util.ConnectionPool;

import javax.naming.NamingException;
import java.sql.*;
import java.util.ArrayList;

public class FeedDAO {
    public FeedObj get(String idx) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM feed WHERE idx=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, idx);

            rs = stmt.executeQuery();
            if (!rs.next()) return null;

            return new FeedObj(
                    rs.getString("idx"),
                    rs.getString("user"),
                    rs.getString("content"),
                    rs.getString("images"),
                    rs.getString("reply_of"),
                    rs.getString("created_at"),
                    rs.getString("edited_at")
            );

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public ArrayList<FeedObj> getList(String uid, int page) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM feed WHERE user=? ORDER BY created_at DESC LIMIT 10 OFFSET ?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, uid);
            stmt.setInt(2, 10 * (page > 0 ? page - 1 : 0));

            rs = stmt.executeQuery();
            ArrayList<FeedObj> feeds = new ArrayList<>();
            while (rs.next()) {
                feeds.add(new FeedObj(
                        rs.getString("idx"),
                        rs.getString("user"),
                        rs.getString("content"),
                        rs.getString("images"),
                        rs.getString("reply_of"),
                        rs.getString("created_at"),
                        rs.getString("edited_at")
                ));
            }

            return feeds;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public ArrayList<FeedObj> getFollowedList(String uid, int page) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM feed WHERE feed.user IN (SELECT target FROM follow WHERE follow.user=?) ORDER BY created_at DESC LIMIT 10 OFFSET ?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, uid);
            stmt.setInt(2, 10 * (page > 0 ? page - 1 : 0));

            rs = stmt.executeQuery();
            ArrayList<FeedObj> feeds = new ArrayList<>();
            while (rs.next()) {
                feeds.add(new FeedObj(
                        rs.getString("idx"),
                        rs.getString("user"),
                        rs.getString("content"),
                        rs.getString("images"),
                        rs.getString("reply_of"),
                        rs.getString("created_at"),
                        rs.getString("edited_at")
                ));
            }

            return feeds;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean exists(String idx) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT idx FROM feed WHERE idx=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, idx);

            rs = stmt.executeQuery();
            return rs.next();

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public String insert(String uid, String content, String images, String replyOf) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "INSERT INTO feed(user, content, images, reply_of) VALUES(?, ?, ?, ?)";
            stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);

            stmt.setString(1, uid);
            stmt.setString(2, content);
            stmt.setString(3, images);
            stmt.setString(4, replyOf);

            stmt.executeUpdate();
            ResultSet rs = stmt.getGeneratedKeys();
            return rs.next() ? rs.getString(1) : null;

        } finally {
            if(stmt != null) stmt.close();
            if(conn != null) conn.close();
        }
    }

    public boolean update(String idx, String content, String images) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "UPDATE feed SET content=?, images=?, edited_at=NOW() WHERE idx=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, content);
            stmt.setString(2, images);
            stmt.setString(3, idx);

            int count = stmt.executeUpdate();
            return count == 1;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    // TODO: add updates for future columns

    public int[] toggleHeart(String idx, String uid) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        CallableStatement stmt = null;
        try {
            String sql = "CALL toggleHeart(?, ?, ?, ?)";
            stmt = conn.prepareCall(sql);

            stmt.setString(1, uid);
            stmt.setString(2, idx);
            stmt.registerOutParameter(3, Types.BOOLEAN);
            stmt.registerOutParameter(4, Types.INTEGER);

            stmt.execute();
            return new int[]{stmt.getBoolean(3) ? 1 : 0, stmt.getInt(4)};
        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public int getHeartCount(String idx) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT COUNT(*) as count FROM heart WHERE feed=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, idx);

            rs = stmt.executeQuery();
            if (!rs.next()) return 0;

            return rs.getInt("count");
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean delete(String idx) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "DELETE FROM feed WHERE idx=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, idx);

            int count = stmt.executeUpdate();
            return count == 1;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }
}
