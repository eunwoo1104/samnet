package dao;

import util.ConnectionPool;

import javax.naming.NamingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class FeedDAO {
    public FeedObj get(String fno) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM feed WHERE idx=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, fno);

            rs = stmt.executeQuery();
            if (!rs.next()) return null;

            return new FeedObj(
                    rs.getString("idx"),
                    rs.getString("user"),
                    rs.getString("content"),
                    rs.getString("images"),
                    rs.getString("reply_of"),
                    rs.getString("created_at")
            );

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public ArrayList<FeedObj> getList() throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM feed";
            stmt = conn.prepareStatement(sql);

            rs = stmt.executeQuery();
            ArrayList<FeedObj> feeds = new ArrayList<>();
            while (rs.next()) {
                feeds.add(new FeedObj(
                        rs.getString("idx"),
                        rs.getString("user"),
                        rs.getString("content"),
                        rs.getString("images"),
                        rs.getString("reply_of"),
                        rs.getString("created_at")
                ));
            }

            return feeds;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public String insert(String uid, String content, String images) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "INSERT INTO feed(user, content, images) VALUES(?, ?, ?)";
            stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);

            stmt.setString(1, uid);
            stmt.setString(2, content);
            stmt.setString(3, images);

            stmt.executeUpdate();
            ResultSet rs = stmt.getGeneratedKeys();
            return rs.next() ? rs.getString(1) : null;

        } finally {
            if(stmt != null) stmt.close();
            if(conn != null) conn.close();
        }
    }

    public boolean updateContent(String idx, String uid, String content) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "UPDATE feed SET content=? WHERE idx=? AND user=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, content);
            stmt.setString(2, idx);
            stmt.setString(3, uid);

            int count = stmt.executeUpdate();
            return count == 1;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    // TODO: add updates for future columns

    public boolean delete(String idx, String uid) throws NamingException, SQLException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "DELETE FROM feed WHERE idx=? AND user=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, idx);
            stmt.setString(1, uid);

            int count = stmt.executeUpdate();
            return count == 1;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }
}
