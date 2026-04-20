<%@ include file="db_config.jsp" %>
<%
    Connection conn = null;
    Statement stmt = null;
    try {
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        stmt = conn.createStatement();
        
        String sql = "CREATE TABLE IF NOT EXISTS Favorites (" +
                     "id INT AUTO_INCREMENT PRIMARY KEY, " +
                     "user_email VARCHAR(255) NOT NULL, " +
                     "craftsman_id INT NOT NULL, " +
                     "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                     "UNIQUE KEY unique_fav (user_email, craftsman_id), " +
                     "FOREIGN KEY (craftsman_id) REFERENCES Craftsman(id) ON DELETE CASCADE" +
                     ") ENGINE=InnoDB;";
        
        stmt.executeUpdate(sql);
        out.println("✅ Favorites table created or already exists.");
    } catch (Exception e) {
        out.println("❌ Error creating table: " + e.getMessage());
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
