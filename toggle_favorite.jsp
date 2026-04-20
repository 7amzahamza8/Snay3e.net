<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="db_config.jsp" %>
<%
    String userEmail = (String) session.getAttribute("userEmail");
    String craftsmanIdStr = request.getParameter("craftsmanId");
    
    if (userEmail == null) {
        out.print("{\"status\": \"error\", \"message\": \"User not logged in\"}");
        return;
    }
    
    if (craftsmanIdStr == null || craftsmanIdStr.isEmpty()) {
        out.print("{\"status\": \"error\", \"message\": \"Missing craftsman ID\"}");
        return;
    }
    
    int fishermanId = 0;
    try {
        fishermanId = Integer.parseInt(craftsmanIdStr);
    } catch (NumberFormatException e) {
        out.print("{\"status\": \"error\", \"message\": \"Invalid ID format\"}");
        return;
    }
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        
        // Check if already favorited
        ps = conn.prepareStatement("SELECT id FROM Favorites WHERE user_email = ? AND craftsman_id = ?");
        ps.setString(1, userEmail);
        ps.setInt(2, fishermanId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            // Unfavorite
            ps.close();
            ps = conn.prepareStatement("DELETE FROM Favorites WHERE user_email = ? AND craftsman_id = ?");
            ps.setString(1, userEmail);
            ps.setInt(2, fishermanId);
            ps.executeUpdate();
            out.print("{\"status\": \"success\", \"action\": \"removed\"}");
        } else {
            // Favorite
            ps.close();
            ps = conn.prepareStatement("INSERT INTO Favorites (user_email, craftsman_id) VALUES (?, ?)");
            ps.setString(1, userEmail);
            ps.setInt(2, fishermanId);
            ps.executeUpdate();
            out.print("{\"status\": \"success\", \"action\": \"added\"}");
        }
    } catch (Exception e) {
        out.print("{\"status\": \"error\", \"message\": \"" + e.getMessage().replace("\"", "\\\"") + "\"}");
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
%>
