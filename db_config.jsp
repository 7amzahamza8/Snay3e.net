<%@ page import="java.sql.*" %>
<%
    // Database Configuration for Railway MySQL
    String dbUrl = "jdbc:mysql://nozomi.proxy.rlwy.net:49587/railway?useSSL=false&connectTimeout=10000";
    String dbUser = "root";
    String dbPass = "spvYtcSpuNegjPseVctVNOcQyHDYWKte";
    
    // Load the driver
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
        out.println("⚠️ Driver not found: " + e.getMessage());
    }
%>
