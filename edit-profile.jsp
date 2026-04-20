<%@ page import="java.util.Base64, java.io.*, jakarta.servlet.http.Part" %>
<%@ include file="db_config.jsp" %>
<%
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Initialize variables
    String phone = "";
    String whatsapp = "";
    String description = "";
    String profileImageBase64 = "";
    String errorMessage = "";
    String successMessage = "";

    // Load current profile data
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String sql = "SELECT c.Phone, c.whatsapp, p.Description, p.Personal_Image " +
                    "FROM Contact c " +
                    "JOIN Profile p ON p.Contact_ID = c.id " +
                    "WHERE c.email = ?";
        
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, userEmail);
        rs = stmt.executeQuery();

        if (rs.next()) {
            phone = rs.getString("Phone") != null ? rs.getString("Phone") : "";
            whatsapp = rs.getString("whatsapp") != null ? rs.getString("whatsapp") : "";
            description = rs.getString("Description") != null ? rs.getString("Description") : "";
            byte[] imageBytes = rs.getBytes("Personal_Image");
            if (imageBytes != null && imageBytes.length > 0) {
                profileImageBase64 = Base64.getEncoder().encodeToString(imageBytes);
            }
        }
    } catch (Exception e) {
        errorMessage = "Error loading profile: " + e.getMessage();
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) {}
        try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }

    // Handle form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Read parameters (Tomcat populates these once <multipart-config> is active)
        request.setCharacterEncoding("UTF-8");
        String newPhone = request.getParameter("phone");
        String newWhatsapp = request.getParameter("whatsapp");
        String newDescription = request.getParameter("description");


        Connection updateConn = null;
        PreparedStatement updateStmt = null;
        InputStream fileContent = null;
        
        try {
            updateConn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            updateConn.setAutoCommit(false);

            // Update Contact table
            String updateSql = "UPDATE Contact SET Phone = ?, whatsapp = ? WHERE email = ?";
            updateStmt = updateConn.prepareStatement(updateSql);
            updateStmt.setString(1, newPhone);
            updateStmt.setString(2, newWhatsapp);
            updateStmt.setString(3, userEmail);
            updateStmt.executeUpdate();

            // Update Profile table
            updateSql = "UPDATE Profile SET Description = ? WHERE Contact_ID IN " +
                       "(SELECT id FROM Contact WHERE email = ?)";
            updateStmt = updateConn.prepareStatement(updateSql);
            updateStmt.setString(1, newDescription);
            updateStmt.setString(2, userEmail);
            updateStmt.executeUpdate();

            // Handle image upload
            Part filePart = request.getPart("profileImage");
            if (filePart != null && filePart.getSize() > 0) {
                fileContent = filePart.getInputStream();
                updateSql = "UPDATE Profile SET Personal_Image = ? WHERE Contact_ID IN " +
                           "(SELECT id FROM Contact WHERE email = ?)";
                updateStmt = updateConn.prepareStatement(updateSql);
                updateStmt.setBinaryStream(1, fileContent);
                updateStmt.setString(2, userEmail);
                updateStmt.executeUpdate();
            }

            updateConn.commit();
            response.sendRedirect("profile.jsp?refresh=" + System.currentTimeMillis());
            return;

        } catch (Exception e) {
            if (updateConn != null) try { updateConn.rollback(); } catch (SQLException ex) {}
            errorMessage = "Error updating profile: " + e.getMessage();
        } finally {
            try { if (updateStmt != null) updateStmt.close(); } catch (SQLException e) {}
            try { if (updateConn != null) updateConn.close(); } catch (SQLException e) {}
            try { if (fileContent != null) fileContent.close(); } catch (IOException e) {}
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Edit Profile</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Consistent styling with profile page */
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
            padding: 0.8rem 1.5rem;
            border-radius: 30px;
            background: linear-gradient(45deg, #ff8a00, #ffaa00);
            color: white;
            text-decoration: none;
            box-shadow: 0 4px 15px rgba(255, 138, 0, 0.2);
            transition: all 0.3s ease;
        }

        .profile-link:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 138, 0, 0.3);
        }

        .profile-container {
            margin-top: 140px;
            padding: 2rem 5%;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
        }

        .profile-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.05);
            animation: fadeInUp 0.8s ease;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        label {
            display: block;
            margin-bottom: 0.5rem;
            color: #2d3436;
            font-weight: 500;
        }

        input, textarea {
            width: 100%;
            padding: 0.8rem;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        input:focus, textarea:focus {
            outline: none;
            border-color: #ffaa00;
            box-shadow: 0 0 0 3px rgba(255, 170, 0, 0.1);
        }

        .profile-image-container {
            text-align: center;
            margin-bottom: 2rem;
        }

        .profile-image {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #ffaa00;
            box-shadow: 0 8px 24px rgba(255, 138, 0, 0.15);
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .profile-image:hover {
            transform: scale(1.05);
        }

        .btn {
            padding: 0.8rem 1.5rem;
            border: none;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: linear-gradient(45deg, #ff8a00, #ffaa00);
            color: white;
            box-shadow: 0 4px 15px rgba(255, 138, 0, 0.2);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 138, 0, 0.3);
        }

        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
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
            .profile-container {
                padding: 1rem;
                margin-top: 120px;
            }
            
            .profile-card {
                padding: 1.5rem;
            }
            
            .navbar {
                padding: 1rem;
            }
            
            .logo-icon {
                height: 60px;
            }
        }
    </style>
</head>
<body>

<div class="navbar">
    <img src="Logo-removebg-preview.png" alt="Logo" class="logo-icon">
    <div class="profile-links">
        <a class="profile-link" href="profile.jsp">Profile</a>
        <a class="profile-link" href="logout.jsp">Logout</a>
    </div>
</div>

<div class="profile-container">
    <div class="profile-card">
        <% if (!errorMessage.isEmpty()) { %>
            <div class="alert alert-error"><%= errorMessage %></div>
        <% } %>
        <% if (!successMessage.isEmpty()) { %>
            <div class="alert alert-success"><%= successMessage %></div>
        <% } %>

        <h2 style="margin-bottom: 2rem; color: #2d3436;">Edit Profile</h2>
        
        <form method="POST" action="edit-profile.jsp" enctype="multipart/form-data">
            <div class="profile-image-container">
                <label for="profileImage">
                    <% if (!profileImageBase64.isEmpty()) { %>
                        <img src="data:image/jpeg;base64,<%= profileImageBase64 %>" 
                             class="profile-image" 
                             alt="Profile Picture">
                    <% } else { %>
                        <div class="profile-image" style="background: #eee; display: flex; align-items: center; justify-content: center;">
                            <span style="color: #888;">Click to upload image</span>
                        </div>
                    <% } %>
                </label>
                <input type="file" id="profileImage" name="profileImage" accept="image/*" style="display: none;">
            </div>

            <div class="form-group">
                <label>Email</label>
                <input type="email" value="<%= userEmail %>" disabled>
            </div>

            <div class="form-group">
                <label>Phone Number</label>
                <input type="tel" name="phone" value="<%= phone %>">
            </div>

            <div class="form-group">
                <label>WhatsApp Number</label>
                <input type="tel" name="whatsapp" value="<%= whatsapp %>">
            </div>

            <div class="form-group">
                <label>Description</label>
                <textarea name="description" rows="4"><%= description %></textarea>
            </div>

            <button type="submit" class="btn btn-primary">Save Changes</button>
        </form>
    </div>
</div>

</body>
</html>