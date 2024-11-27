package dao;

import util.ConnectionPool;

import javax.naming.NamingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ImageDAO {
    public String insert(String user, String fdir) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "INSERT INTO image(user, dir) VALUES(?, ?)";
            stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);

            stmt.setString(1, user);
            stmt.setString(2, fdir);

            stmt.executeUpdate();
            ResultSet rs = stmt.getGeneratedKeys();
            return rs.next() ? rs.getString(1) : null;

        } finally {
            if(stmt != null) stmt.close();
            if(conn != null) conn.close();
        }
    }

    public String get(String idx) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT dir FROM image WHERE idx=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, idx);

            rs = stmt.executeQuery();
            if (!rs.next()) {
                return null;
            }

            return rs.getString("dir");

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public boolean delete(String idx) throws SQLException, NamingException {
        Connection conn = ConnectionPool.get();
        PreparedStatement stmt = null;
        try {
            String sql = "DELETE FROM image WHERE idx=?";
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, idx);

            int count = stmt.executeUpdate();
            return count == 1;

        } finally {
            if(stmt != null) stmt.close();
            if(conn != null) conn.close();
        }
    }
}
