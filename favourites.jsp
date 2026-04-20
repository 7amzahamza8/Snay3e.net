<%@ include file="db_config.jsp" %>
<%
    // Pagination parameters
    int recordsPerPage = 6;
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        currentPage = Integer.parseInt(pageParam);
    }
    int offset = (currentPage - 1) * recordsPerPage;

    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection conn = null;
    ResultSet rs = null;
    ResultSet countRs = null;
    
    int totalRecords = 0;
    int totalPages = 1;

    try {
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // Base query for favorites
        StringBuilder query = new StringBuilder(
            "SELECT c.id, c.Name, con.email, con.phone, p.Description, l.area AS location, cat.name AS category " +
            "FROM Craftsman c " +
            "JOIN Profile p ON p.id = c.Profile_id " +
            "JOIN Contact con ON p.Contact_ID = con.id " +
            "JOIN Location l ON c.Location_id = l.id " +
            "JOIN Category cat ON c.Category_id = cat.id " +
            "JOIN Favorites f ON f.craftsman_id = c.id " +
            "WHERE f.user_email = ?"
        );

        // Count query
        StringBuilder countQuery = new StringBuilder("SELECT COUNT(*) AS total FROM (" + query.toString() + ") AS subquery");

        // Add pagination to main query
        query.append(" LIMIT ? OFFSET ?");

        // Prepare main statement
        PreparedStatement stmt = conn.prepareStatement(query.toString(), ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        stmt.setString(1, userEmail);
        stmt.setInt(2, recordsPerPage);
        stmt.setInt(3, offset);
        
        rs = stmt.executeQuery();

        // Prepare count statement
        PreparedStatement countStmt = conn.prepareStatement(countQuery.toString());
        countStmt.setString(1, userEmail);
        
        countRs = countStmt.executeQuery();
        if (countRs.next()) {
            totalRecords = countRs.getInt("total");
            totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
        }

    } catch (Exception e) {
        out.println("⚠️ Error in connection: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>My Favorites</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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

        .logo-icon:hover {
            transform: rotate(-5deg) scale(1.05);
        }

        .profile-links {
            display: flex;
            gap: 1.5rem;
        }

        .profile-link {
            color: #333;
            text-decoration: none;
            padding: 0.8rem 1.5rem;
            border-radius: 30px;
            font-weight: 500;
            transition: all 0.3s ease;
            background: linear-gradient(45deg, #ff8a00, #ffaa00);
            color: white;
            box-shadow: 0 4px 15px rgba(255, 138, 0, 0.2);
        }

        .profile-link:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 138, 0, 0.3);
        }

        .hero-section {
            margin-top: 120px;
            padding: 2rem 5%;
            text-align: center;
        }

        h2 {
            font-size: 2.5rem;
            color: #2d3436;
            margin-bottom: 1.5rem;
            animation: fadeInUp 0.8s ease;
        }

        .card-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 2rem;
            padding: 2rem 5%;
            animation: fadeIn 0.8s ease;
        }

        .card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 1.5rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.05);
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .card:hover {
            transform: translateY(-10px) scale(1.02);
            box-shadow: 0 15px 45px rgba(255, 138, 0, 0.15);
        }

        .card-content p {
            margin: 0.8rem 0;
            color: #555;
            font-size: 0.95rem;
            line-height: 1.6;
        }

        .card-content p strong {
            color: #2d3436;
            font-weight: 600;
        }

        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            padding: 20px 0;
            margin: 20px 0;
        }

        .page-item {
            padding: 8px 16px;
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.95);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }

        .page-item a {
            color: #2d3436;
            text-decoration: none;
            font-weight: 500;
        }

        .page-item.active {
            background: linear-gradient(45deg, #ff8a00, #ffaa00);
        }

        .page-item.active a {
            color: white;
        }

        .page-item:hover:not(.active) {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255, 138, 0, 0.15);
        }

        /* Favorite Heart Styles */
        .favorite-btn {
            position: absolute;
            top: 1.5rem;
            right: 1.5rem;
            z-index: 10;
            font-size: 1.5rem;
            color: #ff4757;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .favorite-btn:not(.active) {
            color: #ccc;
        }

        .favorite-btn:hover {
            transform: scale(1.3);
        }

        .view_profile-link {
            display: inline-block;
            margin-top: 1rem;
            padding: 0.8rem 1.5rem;
            background: linear-gradient(45deg, #ff8a00, #ffaa00);
            color: white;
            text-decoration: none;
            border-radius: 12px;
            font-weight: 500;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            text-align: center;
        }

        .empty-state {
            text-align: center;
            padding: 3rem;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            margin: 2rem auto;
            max-width: 600px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.05);
        }

        .empty-state h3 {
            color: #2d3436;
            margin-bottom: 1rem;
            font-size: 1.5rem;
        }

        .empty-state p {
            color: #666;
            margin-bottom: 1.5rem;
        }

        .empty-state a {
            display: inline-block;
            padding: 0.8rem 1.5rem;
            background: linear-gradient(45deg, #ff8a00, #ffaa00);
            color: white;
            text-decoration: none;
            border-radius: 12px;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .empty-state a:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 138, 0, 0.3);
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
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
            .card-container {
                grid-template-columns: 1fr;
            }
            
            .navbar {
                padding: 1rem;
            }
            
            .logo-icon {
                height: 60px;
            }
            
            .pagination {
                flex-wrap: wrap;
            }
        }
    </style>
</head>
<body>

<div class="navbar">
    <img src="Logo-removebg-preview.png" alt="Logo" class="logo-icon">
    <div class="profile-links">
        <a class="profile-link" href="home_user.jsp">Home</a>
        <a class="profile-link" href="userLogin.jsp">Log out</a>
    </div>
</div>

<div class="hero-section">
    <h2>My Favorite Craftsmen</h2>
</div>

<div class="card-container">
    <% 
    if (rs != null) {
        try {
            if (!rs.next()) { 
    %>
        <div class="empty-state">
            <h3>No Favorites Yet</h3>
            <p>You haven't added any craftsmen to your favorites yet.</p>
            <a href="home_user.jsp">Browse Craftsmen</a>
        </div>
    <%
            } else {
                rs.beforeFirst();
                while (rs.next()) { 
    %>
        <div class="card" onclick="window.location.href='userProfile_for_user.jsp?id=<%= rs.getInt("id") %>'" style="cursor: pointer;">
            <i class="fas fa-heart favorite-btn active" 
               onclick="toggleFavorite(event, <%= rs.getInt("id") %>)"></i>
            <div class="card-content">
                <p><strong>Name:</strong> <%= rs.getString("Name") %></p>
                <p><strong>Email:</strong> <%= rs.getString("email") %></p>
                <p><strong>Phone:</strong> <%= rs.getString("phone") %></p>
                <p><strong>Description:</strong> <%= rs.getString("Description") %></p>
                <p><strong>Location:</strong> <%= rs.getString("location") %></p>
                <p><strong>Category:</strong> <%= rs.getString("category") %></p>
                <div class="view_profile-link">View Profile →</div>
            </div>
        </div>
    <%
                }
            }
        } catch (SQLException e) {
            out.println("⚠️ Error displaying results: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                out.println("⚠️ Error closing resources: " + e.getMessage());
            }
        }
    }
    %>
</div>

<% if (totalPages > 1) { %>
<div class="pagination">
    <% if (currentPage > 1) { %>
        <div class="page-item">
            <a href="favourites.jsp?page=<%= currentPage-1 %>">Previous</a>
        </div>
    <% } %>

    <% for (int i=1; i<=totalPages; i++) { %>
        <div class="page-item <%= currentPage == i ? "active" : "" %>">
            <a href="favourites.jsp?page=<%= i %>"><%= i %></a>
        </div>
    <% } %>

    <% if (currentPage < totalPages) { %>
        <div class="page-item">
            <a href="favourites.jsp?page=<%= currentPage+1 %>">Next</a>
        </div>
    <% } %>
</div>
<% } %>

<script>
function toggleFavorite(event, craftsmanId) {
    event.stopPropagation(); // Prevent card click
    const btn = event.currentTarget;
    const card = btn.closest('.card');
    
    fetch('toggle_favorite.jsp?craftsmanId=' + craftsmanId)
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                if (data.action === 'added') {
                    btn.classList.add('active', 'fas');
                    btn.classList.remove('far');
                } else {
                    btn.classList.remove('active', 'fas');
                    btn.classList.add('far');
                    // In favourites page, we remove the card if unfavorited
                    card.style.opacity = '0';
                    setTimeout(() => {
                        card.remove();
                        if (document.querySelectorAll('.card').length === 0) {
                            location.reload(); // Show empty state
                        }
                    }, 300);
                }
            } else {
                alert('Error: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('An error occurred. Please try again.');
        });
}
</script>
</body>
</html>