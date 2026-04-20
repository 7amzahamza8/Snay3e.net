<%@ page import="java.util.Base64, java.io.*" %>
<%@ include file="db_config.jsp" %>
<%
    String email = (String) session.getAttribute("userEmail");
    if (email == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String phone = "";
    String whatsapp = "";
    String description = "";
    String profileImageBase64 = null;

    try {
        Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        PreparedStatement stmt = conn.prepareStatement(
            "SELECT c.Phone, c.whatsapp, p.Description, p.Personal_Image FROM Contact c " +
            "JOIN Profile p ON p.Contact_ID = c.id WHERE c.email = ?"
        );
        stmt.setString(1, email);

        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            phone = rs.getString("Phone");
            whatsapp = rs.getString("whatsapp");
            description = rs.getString("Description");
            byte[] imageBytes = rs.getBytes("Personal_Image");
            if (imageBytes != null) {
                profileImageBase64 = Base64.getEncoder().encodeToString(imageBytes);
            }
        }

        conn.close();
    } catch (Exception e) {
        out.println("<div class='error-message'>⚠️ Error: " + e.getMessage() + "</div>");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>My Profile</title>
    <!-- Font Awesome for the copy icon -->
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
    padding: 0.5rem 5%;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1);
    position: fixed;
    width: 100%;
    top: 0;
    z-index: 1000;
    height: 60px;
}

.logo-icon {
    height: 50px;
    transition: transform 0.3s ease;
}

.profile-links {
    display: flex;
    gap: 1rem;
}

.profile-link {
    padding: 0.5rem 1.2rem;
    border-radius: 20px;
    background: linear-gradient(45deg, #ff8a00, #ffaa00);
    color: white;
    text-decoration: none;
    font-size: 0.9rem;
    box-shadow: 0 4px 15px rgba(255, 138, 0, 0.2);
    transition: all 0.3s ease;
}

.profile-container {
    margin-top: 80px;
    padding: 1rem 5%;
    max-width: 700px;
    margin-left: auto;
    margin-right: auto;
}

.profile-card {
    background: rgba(255, 255, 255, 0.95);
    border-radius: 15px;
    padding: 1.5rem;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.05);
    animation: fadeInUp 0.8s ease;
}

.profile-header {
    text-align: center;
    margin-bottom: 1rem;
}

.profile-image {
    margin-left:12rem ;
    width: 150px;
    height: 150px;
    border-radius: 50%;
    object-fit: cover;
    margin-bottom: 1rem;
    border: 2px solid #ffaa00;
    box-shadow: 0 4px 15px rgba(255, 138, 0, 0.15);
}

.no-image {
    width: 100px;
    height: 100px;
    border-radius: 50%;
    background: #f5f5f5;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 1rem;
    border: 2px dashed #ddd;
    color: #888;
    font-size: 0.8rem;
}

.profile-detail {
    margin: 0.8rem 0;
    color: #555;
    font-size: 0.9rem;
    padding: 0.8rem;
    border-radius: 10px;
    background: rgba(245, 245, 245, 0.5);
    line-height: 1.4;
}

.profile-detail strong {
    color: #2d3436;
    display: inline-block;
    min-width: 100px;
    font-weight: 600;
}

.action-buttons {
    margin-top: 1.5rem;
    display: flex;
    gap: 0.8rem;
    flex-wrap: wrap;
    justify-content: center;
}

.btn {
    padding: 0.6rem 1.2rem;
    border-radius: 8px;
    text-decoration: none;
    transition: all 0.3s ease;
    font-size: 0.9rem;
    font-weight: 500;
}

.btn-primary {
    background: linear-gradient(45deg, #ff8a00, #ffaa00);
    color: white;
    box-shadow: 0 4px 15px rgba(255, 138, 0, 0.2);
}

.btn-secondary {
    background: linear-gradient(45deg, #6c757d, #5a6268);
    color: white;
    box-shadow: 0 4px 15px rgba(108, 117, 125, 0.2);
}

.btn:hover {
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
    .profile-container {
        margin-top: 70px;
        padding: 1rem;
    }
    
    .profile-card {
        padding: 1rem;
    }
    
    .profile-image,
    .no-image {
        width: 80px;
        height: 80px;
    }
    
    .profile-detail {
        font-size: 0.85rem;
        padding: 0.6rem;
    }
    
    .profile-detail strong {
        min-width: 90px;
    }
    
    .navbar {
        padding: 0.5rem;
    }
    
    .profile-link {
        padding: 0.4rem 1rem;
        font-size: 0.85rem;
    }
    
    .btn {
        padding: 0.5rem 1rem;
        font-size: 0.85rem;
    }
}
</style>
</head>
<body>

<div class="navbar">
    <img src="Logo-removebg-preview.png" alt="Logo" class="logo-icon">
    <div class="profile-links">
        <a class="profile-link" href="home.jsp">Home</a>
        <a class="profile-link" href="home_user.jsp">Logout</a>
    </div>
</div>

<div class="profile-container">
    <div class="profile-card">
        <div class="profile-header">
            <% if (profileImageBase64 != null) { %>
                <img src="data:image/jpeg;base64,<%= profileImageBase64 %>" 
                     class="profile-image" 
                     alt="Profile Picture">
            <% } else { %>
                <div class="profile-image" style="background: #eee; display: flex; align-items: center; justify-content: center;">
                    
                    <span style="color: #888;">No Image</span>
                </div>
            <% } %>
            <h2> My Profile</h2>
        </div>

        <div class="profile-detail">
            <strong>Email:</strong> <%= email %>
        </div>
        
        <div class="profile-detail">
            <strong>Phone:</strong> 
            <% if (!phone.isEmpty()) { %>
                <span id="phoneNumber"><%= phone %></span>
                <i class="fas fa-copy" onclick="copyPhoneNumber()" style="cursor: pointer; margin-left: 10px; color: #666;" title="Copy phone number"></i>
            <% } else { %>
                Not provided
            <% } %>
        </div>
        
        <div class="profile-detail">
            <strong>WhatsApp:</strong> 
            <% if (whatsapp != null && !whatsapp.isEmpty()) { %>
                <a href="https://wa.me/<%= whatsapp %>" target="_blank" style="color: #25D366; text-decoration: none;">
                    <%= whatsapp %> <i class="fab fa-whatsapp"></i>
                </a>
            <% } else { %>
                Not provided
            <% } %>
        </div>
        
        <div class="profile-detail">
            <strong>Description:</strong> <%= !description.isEmpty() ? description : "No description available" %>
        </div>

        <div class="action-buttons">
            <a href="edit-profile.jsp" class="btn btn-primary">Edit Profile</a>
            <a href="home.jsp" class="btn btn-secondary">Back to Home</a>
        </div>
    </div>
</div>

</body>
<script>
function copyPhoneNumber() {
    const phoneNumber = document.getElementById('phoneNumber').textContent;
    navigator.clipboard.writeText(phoneNumber).then(() => {
        const copyIcon = document.querySelector('.fa-copy');
        copyIcon.style.color = '#25D366';
        setTimeout(() => {
            copyIcon.style.color = '#666';
        }, 1000);
    });
}
</script>
</html>