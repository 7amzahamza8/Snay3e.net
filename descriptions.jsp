<%@ page import="java.util.*" %>
<%@ include file="db_config.jsp" %>
<%
    String craftsmanIdStr = request.getParameter("craftsman_id");
    if (craftsmanIdStr == null || craftsmanIdStr.isEmpty()) {
        out.println("<div class='error-message'>❌ No craftsman ID provided.</div>");
        return;
    }

    List<Map<String, String>> ratings = new ArrayList<>();
    String craftsmanName = "";
    double averageRating = 0.0;
    int totalRatings = 0;

    try {

Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // Get craftsman name from contact info
        // Get craftsman email from contact info by joining tables
        PreparedStatement stmtCraftsman = conn.prepareStatement(
            "SELECT con.email FROM Craftsman c " +
            "JOIN Profile p ON c.Profile_id = p.id " +
            "JOIN Contact con ON p.Contact_ID = con.id " +
            "WHERE c.id = ?"
        );
        stmtCraftsman.setInt(1, Integer.parseInt(craftsmanIdStr));
        ResultSet rsCraftsman = stmtCraftsman.executeQuery();
        
        if (rsCraftsman.next()) {
            craftsmanName = rsCraftsman.getString("email");
        }

        // Get all ratings with user information - using schema names 'name' and 'rated_at'
        PreparedStatement stmtRatings = conn.prepareStatement(
            "SELECT r.stars, r.comment, r.rated_at, u.name " +
            "FROM rating r " +
            "LEFT JOIN users u ON r.user_id = u.id " +
            "WHERE r.craftsman_id = ? " +
            "ORDER BY r.rated_at DESC"
        );
        stmtRatings.setInt(1, Integer.parseInt(craftsmanIdStr));
        ResultSet rsRatings = stmtRatings.executeQuery();

        while (rsRatings.next()) {
            Map<String, String> rating = new HashMap<>();
            rating.put("stars", rsRatings.getString("stars"));
            rating.put("comment", rsRatings.getString("comment"));
            rating.put("rated_at", rsRatings.getString("rated_at"));
            rating.put("name", rsRatings.getString("name") != null ? 
                      rsRatings.getString("name") : "Anonymous User");
            ratings.add(rating);
        }

        // Get average rating and total count
        PreparedStatement stmtStats = conn.prepareStatement(
            "SELECT AVG(stars) AS avg_rating, COUNT(*) AS total " +
            "FROM rating WHERE craftsman_id = ?"
        );
        stmtStats.setInt(1, Integer.parseInt(craftsmanIdStr));
        ResultSet rsStats = stmtStats.executeQuery();
        
        if (rsStats.next()) {
            averageRating = rsStats.getDouble("avg_rating");
            totalRatings = rsStats.getInt("total");
        }

        conn.close();
    } catch (Exception e) {
        out.println("<div class='error-message'>⚠️ Error: " + e.getMessage() + "</div>");
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Rating Descriptions</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            min-height: 100vh;
        }

        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 5%;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1);
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
        }

        .logo-icon {
            height: 80px;
            transition: transform 0.3s ease;
        }

        .profile-link {
            padding: 0.8rem 1.5rem;
            border-radius: 30px;
            background: linear-gradient(45deg, #ff8a00, #ffaa00);
            color: white;
            text-decoration: none;
            box-shadow: 0 4px 15px rgba(255, 138, 0, 0.2);
            transition: all 0.3s ease;
        }

        .descriptions-container {
            margin-top: 140px;
            padding: 2rem 5%;
            max-width: 1000px;
            margin-left: auto;
            margin-right: auto;
        }

        .header-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.05);
            margin-bottom: 2rem;
            animation: fadeInUp 0.8s ease;
        }

        .header-card h1 {
            color: #2d3436;
            margin-bottom: 1rem;
        }

        .stats {
            display: flex;
            gap: 2rem;
            margin-top: 1rem;
        }

        .stat-item {
            text-align: center;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 600;
            color: #ff8a00;
        }

        .stat-label {
            color: #666;
            font-size: 0.9rem;
        }

        .rating-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.05);
            margin-bottom: 1.5rem;
            animation: fadeInUp 0.8s ease;
            border-left: 4px solid #ff8a00;
        }

        .rating-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 1rem;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            background: linear-gradient(45deg, #ff8a00, #ffaa00);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
        }

        .stars {
            display: flex;
            gap: 0.2rem;
        }

        .star {
            color: #ffaa00;
            font-size: 1.2rem;
        }

        .comment {
            color: #555;
            line-height: 1.6;
            margin: 1rem 0;
            padding: 1rem;
            background: #f8f9fa;
            border-radius: 10px;
            border-left: 3px solid #e9ecef;
        }

        .date {
            color: #888;
            font-size: 0.9rem;
            text-align: right;
        }

        .no-ratings {
            text-align: center;
            padding: 3rem;
            color: #666;
        }

        .no-ratings i {
            font-size: 3rem;
            margin-bottom: 1rem;
            color: #ddd;
        }

        .back-link {
            display: inline-block;
            margin-top: 2rem;
            padding: 0.8rem 1.5rem;
            background: linear-gradient(45deg, #ff8a00, #ffaa00);
            color: white;
            text-decoration: none;
            border-radius: 12px;
            transition: all 0.3s ease;
        }

        .back-link:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 138, 0, 0.3);
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @media (max-width: 768px) {
            .descriptions-container {
                padding: 1rem;
                margin-top: 120px;
            }
            
            .header-card, .rating-card {
                padding: 1.5rem;
            }
            
            .stats {
                flex-direction: column;
                gap: 1rem;
            }
            
            .rating-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
            }
        }
    </style>
</head>
<body>

<div class="navbar">
    <img src="Logo-removebg-preview.png" alt="Logo" class="logo-icon">
    <a href="javascript:history.back()" class="profile-link">Back to Profile</a>
</div>

<div class="descriptions-container">
    <div class="header-card">
        <h1>Rating Descriptions</h1>
        <p><strong>Craftsman:</strong> <%= craftsmanName %></p>
        
        <div class="stats">
            <div class="stat-item">
                <div class="stat-value"><%= String.format("%.1f", averageRating) %></div>
                <div class="stat-label">Average Rating</div>
            </div>
            <div class="stat-item">
                <div class="stat-value"><%= totalRatings %></div>
                <div class="stat-label">Total Reviews</div>
            </div>
        </div>
    </div>

    <% if (ratings.isEmpty()) { %>
        <div class="rating-card">
            <div class="no-ratings">
                <i class="far fa-comment-dots"></i>
                <h3>No Reviews Yet</h3>
                <p>This craftsman hasn't received any ratings yet.</p>
            </div>
        </div>
    <% } else { %>
        <% for (Map<String, String> rating : ratings) { %>
            <div class="rating-card">
                <div class="rating-header">
                    <div class="user-info">
                        <div class="user-avatar">
                            <%= rating.get("name").charAt(0) %>
                        </div>
                        <div>
                            <strong><%= rating.get("name") %></strong>
                            <div class="stars">
                                <% 
                                    int stars = Integer.parseInt(rating.get("stars"));
                                    for (int i = 1; i <= 5; i++) { 
                                %>
                                    <i class="fas fa-star <%= i <= stars ? "star" : "far fa-star" %>"></i>
                                <% } %>
                                <span style="margin-left: 10px; color: #666;"><%= stars %>/5</span>
                            </div>
                        </div>
                    </div>
                </div>
                
                <% if (rating.get("comment") != null && !rating.get("comment").trim().isEmpty()) { %>
                    <div class="comment">
                        "<%= rating.get("comment") %>"
                    </div>
                <% } else { %>
                    <div class="comment" style="color: #999; font-style: italic;">
                        No comment provided
                    </div>
                <% } %>
                
                <div class="date">
                    <% if (rating.get("rated_at") != null) { %>
                        Reviewed on: <%= rating.get("rated_at") %>
                    <% } else { %>
                        Date not available
                    <% } %>
                </div>
            </div>
        <% } %>
    <% } %>
    
    <a href="javascript:history.back()" class="back-link">Back to Profile</a>
</div>

</body>
</html>