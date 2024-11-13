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
}
