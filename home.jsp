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
    String locationFilter = request.getParameter("location");
    String categoryFilter = request.getParameter("category");
    String craftsmanName = "";
    
    int totalRecords = 0;
    int totalPages = 1;

    try {
         conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // Get craftsman name from session
        craftsmanName = (String) session.getAttribute("name");
        if (craftsmanName == null || craftsmanName.isEmpty()) {
            PreparedStatement nameStmt = conn.prepareStatement(
                "SELECT c.Name FROM Craftsman c " +
                "JOIN Profile p ON p.id = c.Profile_id " +
                "JOIN Contact con ON p.Contact_ID = con.id " +
                "WHERE con.email = ?"
            );
            nameStmt.setString(1, userEmail);
            ResultSet nameRs = nameStmt.executeQuery();
            if (nameRs.next()) {
                craftsmanName = nameRs.getString("Name");
                session.setAttribute("name", craftsmanName); // Cache it
            }
            nameRs.close();
            nameStmt.close();
        }


        // Base query
        StringBuilder query = new StringBuilder(
            "SELECT c.id, c.Name, con.email, con.phone, p.Description, l.area AS location, cat.name AS category " +
            "FROM Craftsman c " +
            "JOIN Profile p ON p.id = c.Profile_id " +
            "JOIN Contact con ON p.Contact_ID = con.id " +
            "JOIN Location l ON c.Location_id = l.id " +
            "JOIN Category cat ON c.Category_id = cat.id"
        );

        // Count query
        StringBuilder countQuery = new StringBuilder("SELECT COUNT(*) AS total FROM (" + query.toString() + ") AS subquery");

        // Add WHERE clauses
        boolean hasWhereClause = false;
        if (locationFilter != null && !locationFilter.isEmpty()) {
            query.append(" WHERE l.id = ?");
            countQuery.append(" WHERE l.id = ?");
            hasWhereClause = true;
        }
        if (categoryFilter != null && !categoryFilter.isEmpty()) {
            if (hasWhereClause) {
                query.append(" AND cat.id = ?");
                countQuery.append(" AND cat.id = ?");
            } else {
                query.append(" WHERE cat.id = ?");
                countQuery.append(" WHERE cat.id = ?");
            }
        }

        // Add pagination to main query
        query.append(" LIMIT ? OFFSET ?");

        // Prepare main statement
        PreparedStatement stmt = conn.prepareStatement(query.toString());
        
        int paramIndex = 1;
        if (locationFilter != null && !locationFilter.isEmpty()) {
            stmt.setInt(paramIndex++, Integer.parseInt(locationFilter));
        }
        if (categoryFilter != null && !categoryFilter.isEmpty()) {
            stmt.setInt(paramIndex++, Integer.parseInt(categoryFilter));
        }
        stmt.setInt(paramIndex++, recordsPerPage);
        stmt.setInt(paramIndex++, offset);
        
        rs = stmt.executeQuery();

        // Prepare count statement
        PreparedStatement countStmt = conn.prepareStatement(countQuery.toString());
        paramIndex = 1;
        if (locationFilter != null && !locationFilter.isEmpty()) {
            countStmt.setInt(paramIndex++, Integer.parseInt(locationFilter));
        }
        if (categoryFilter != null && !categoryFilter.isEmpty()) {
            countStmt.setInt(paramIndex++, Integer.parseInt(categoryFilter));
        }
        
        countRs = countStmt.executeQuery();
        if (countRs.next()) {
            totalRecords = countRs.getInt("total");
            totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
        }

    } catch (Exception e) {
        out.println("⚠️ Error: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Home</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
   /* Existing styles remain unchanged */
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

.filter-form {
    display: flex;
    flex-direction: row;
    flex-wrap: nowrap;
    justify-content: center;
    align-items: center;
    background: rgba(255, 255, 255, 0.9);
    padding: 2rem;
    border-radius: 20px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
    margin: 2rem auto;
    max-width: 800px;
    animation: slideIn 0.6s ease;
}

.filter-form .filter-group {
    display: flex;
    align-items: center;
    margin: 0 0.5rem;
}

.filter-form select, .filter-form input[type="submit"] {
    padding: 0.8rem 1.5rem;
    border: none;
    border-radius: 12px;
    font-size: 1rem;
    margin: 0 0.5rem;
    transition: all 0.3s ease;
    background: white;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.filter-form select:focus {
    outline: none;
    box-shadow: 0 0 0 3px rgba(255, 138, 0, 0.3);
}

.filter-form input[type="submit"] {
    background: linear-gradient(45deg, #ff8a00, #ffaa00);
    color: white;
    cursor: pointer;
    font-weight: 500;
}

.filter-form input[type="submit"]:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(255, 138, 0, 0.3);
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

.card::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: linear-gradient(45deg, transparent, rgba(255, 138, 0, 0.1), transparent);
    transform: rotate(45deg);
    transition: all 0.6s ease;
}

.card:hover::before {
    animation: shine 1.5s;
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

.card a {
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
}

.card a:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(255, 138, 0, 0.3);
}

/* Pagination Styles */
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

@keyframes slideIn {
    from {
        opacity: 0;
        transform: translateY(-30px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes shine {
    0% { transform: rotate(45deg) translate(-50%, -50%); }
    100% { transform: rotate(45deg) translate(100%, 100%); }
}

@media (max-width: 768px) {
    .card-container {
        grid-template-columns: 1fr;
    }
    
    .filter-form {
        padding: 1.5rem;
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
/* Filter Form Container */
.filter-form {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap; /* عشان لو الشاشه صغرت ينزلوا تحت بعض */
    gap: 1rem;
    align-items: center;
    background: rgba(255, 255, 255, 0.9);
    padding: 1.5rem;
    border-radius: 20px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
    margin: 2rem auto;
    max-width: 800px;
    animation: slideIn 0.6s ease;
}

/* Select Inputs */
.filter-form select {
    flex: 1 1 200px; /* يخليه يكبر ويتقلص حسب المساحة */
    min-width: 200px;
    padding: 0.8rem 2.5rem 0.8rem 1.5rem;
    border: 2px solid #ffd8a8;
    border-radius: 12px;
    background: white;
    appearance: none;
    background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23FF8C00'%3e%3cpath d='M7 10l5 5 5-5z'/%3e%3c/svg%3e");
    background-repeat: no-repeat;
    background-position: right 1rem center;
    background-size: 1.2em;
    transition: all 0.3s ease;
    font-size: 1rem;
    color: #2d3436;
    cursor: pointer;
}

/* Search Button */
.filter-form input[type="submit"] {
    flex: 0 1 150px; /* حجمه أصغر شوية */
    padding: 0.8rem 1.5rem;
    border-radius: 12px;
    background-color: #ff8a00;
    color: white;
    font-weight: bold;
    border: none;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

.filter-form input[type="submit"]:hover {
    background-color: #ffaa00;
}

/* Mobile Responsiveness */
@media (max-width: 768px) {
    .filter-form {
        flex-direction: column;
    }
    
    .filter-form select,
    .filter-form input[type="submit"] {
        width: 100%;
        min-width: auto;
    }
}

.view-profile-link {
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

    </style>
</head>
<body>

<div class="navbar">
    <img src="Logo-removebg-preview.png" alt="Logo" class="logo-icon">
    <div class="profile-links">
        <a class="profile-link" href="profile.jsp">My Profile</a>
        <a class="profile-link" href="login.jsp">Logout</a>
    </div>
</div>

<div class="hero-section">
    <h2>Welcome Back, <%= craftsmanName %></h2>
    
       
    <div class="filter-form">
        <form class="filter-form" method="GET" action="home.jsp">
            <div class="filter-group location-filter">
                <select name="location">
                    <optgroup label="Northern Region">
                        <option value="1" <%= "1".equals(locationFilter) ? "selected" : "" %>>Cairo</option>
                        <option value="2" <%= "2".equals(locationFilter) ? "selected" : "" %>>Giza</option>
                        <option value="3" <%= "3".equals(locationFilter) ? "selected" : "" %>>Alexandria</option>
                        <option value="4" <%= "4".equals(locationFilter) ? "selected" : "" %>>Dakahlia</option>
                        <option value="5" <%= "5".equals(locationFilter) ? "selected" : "" %>>Beheira</option>
                    </optgroup>
                    <optgroup label="Delta Region">
                        <option value="6" <%= "6".equals(locationFilter) ? "selected" : "" %>>Sharqia</option>
                        <option value="7" <%= "7".equals(locationFilter) ? "selected" : "" %>>Qalyubia</option>
                        <option value="8" <%= "8".equals(locationFilter) ? "selected" : "" %>>Monufia</option>
                        <option value="9" <%= "9".equals(locationFilter) ? "selected" : "" %>>Gharbia</option>
                    </optgroup>
                    <optgroup label="Upper Egypt">
                        <option value="10" <%= "10".equals(locationFilter) ? "selected" : "" %>>Fayoum</option>
                        <option value="11" <%= "11".equals(locationFilter) ? "selected" : "" %>>Kafr El Sheikh</option>
                        <option value="12" <%= "12".equals(locationFilter) ? "selected" : "" %>>Beni Suef</option>
                        <option value="13" <%= "13".equals(locationFilter) ? "selected" : "" %>>Minya</option>
                        <option value="14" <%= "14".equals(locationFilter) ? "selected" : "" %>>Assiut</option>
                        <option value="15" <%= "15".equals(locationFilter) ? "selected" : "" %>>Sohag</option>
                        <option value="16" <%= "16".equals(locationFilter) ? "selected" : "" %>>Qena</option>
                        <option value="17" <%= "17".equals(locationFilter) ? "selected" : "" %>>Luxor</option>
                        <option value="18" <%= "18".equals(locationFilter) ? "selected" : "" %>>Aswan</option>
                    </optgroup>
                    <optgroup label="Frontier Areas">
                        <option value="19" <%= "19".equals(locationFilter) ? "selected" : "" %>>Matrouh</option>
                        <option value="20" <%= "20".equals(locationFilter) ? "selected" : "" %>>North Sinai</option>
                        <option value="21" <%= "21".equals(locationFilter) ? "selected" : "" %>>South Sinai</option>
                        <option value="22" <%= "22".equals(locationFilter) ? "selected" : "" %>>Red Sea</option>
                        <option value="23" <%= "23".equals(locationFilter) ? "selected" : "" %>>Suez</option>
                        <option value="24" <%= "24".equals(locationFilter) ? "selected" : "" %>>Ismailia</option>
                        <option value="25" <%= "25".equals(locationFilter) ? "selected" : "" %>>Port Said</option>
                        <option value="26" <%= "26".equals(locationFilter) ? "selected" : "" %>>Damietta</option>
                        <option value="27" <%= "27".equals(locationFilter) ? "selected" : "" %>>New Valley</option>
                    </optgroup>
                </select>
            </div>
    
            <!-- Category Filter -->
            <div class="filter-group category-filter">
                <select name="category">
                    <optgroup label="Construction">
                        <option value="1" <%= "1".equals(categoryFilter) ? "selected" : "" %>>Plumber</option>
                        <option value="2" <%= "2".equals(categoryFilter) ? "selected" : "" %>>Painter</option>
                        <option value="3" <%= "3".equals(categoryFilter) ? "selected" : "" %>>Carpenter</option>
                        <option value="6" <%= "6".equals(categoryFilter) ? "selected" : "" %>>Plasterer</option>
                    </optgroup>
                    <optgroup label="Specialized Crafts">
                        <option value="4" <%= "4".equals(categoryFilter) ? "selected" : "" %>>Blacksmith</option>
                        <option value="5" <%= "5".equals(categoryFilter) ? "selected" : "" %>>Electrician</option>
                        <option value="7" <%= "7".equals(categoryFilter) ? "selected" : "" %>>Ceramic Worker</option>
                        <option value="8" <%= "8".equals(categoryFilter) ? "selected" : "" %>>Maintenance Worker</option>
                    </optgroup>
                </select>
            </div>
    
            <!-- Search Button -->
            <input type="submit" value="Search Craftsmen" class="search-btn">
        </form>
    </div>
</div>

<div class="card-container">
    <% 
    if (rs != null) {
        try {
            while (rs.next()) { 
    %>
        <div class="card" onclick="window.location.href='userProfile.jsp?id=<%= rs.getInt("id") %>'" style="cursor: pointer;">
            <div class="card-content">
                <p><strong>Name:</strong> <%= rs.getString("Name") %></p>
                <p><strong>Email:</strong> <%= rs.getString("email") %></p>
                <p><strong>Phone:</strong> <%= rs.getString("phone") %></p>
                <p><strong>Description:</strong> <%= rs.getString("Description") %></p>
                <p><strong>Location:</strong> <%= rs.getString("location") %></p>
                <p><strong>Category:</strong> <%= rs.getString("category") %></p>
                <div class="view-profile-link">View Profile →</div>
            </div>
        </div>
    <%
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
            <a href="home.jsp?page=<%= currentPage-1 %><%= locationFilter != null ? "&location="+locationFilter : "" %><%= categoryFilter != null ? "&category="+categoryFilter : "" %>">Previous</a>
        </div>
    <% } %>

    <% for (int i=1; i<=totalPages; i++) { %>
        <div class="page-item <%= currentPage == i ? "active" : "" %>">
            <a href="home.jsp?page=<%= i %><%= locationFilter != null ? "&location="+locationFilter : "" %><%= categoryFilter != null ? "&category="+categoryFilter : "" %>"><%= i %></a>
        </div>
    <% } %>

    <% if (currentPage < totalPages) { %>
        <div class="page-item">
            <a href="home.jsp?page=<%= currentPage+1 %><%= locationFilter != null ? "&location="+locationFilter : "" %><%= categoryFilter != null ? "&category="+categoryFilter : "" %>">Next</a>
        </div>
    <% } %>
</div>
<% } %>

</body>
</html>