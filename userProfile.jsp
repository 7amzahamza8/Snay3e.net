<%@ include file="db_config.jsp" %>
<%
    String id = request.getParameter("id");

    if (id == null) {
        out.println("<div class='error-message'>❌ No user ID provided.</div>");
        return;
    }

    String email = "", phone = "", whatsapp = "", description = "";

    try {

Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        PreparedStatement stmt = conn.prepareStatement(
            "SELECT c.email, c.phone, c.whatsapp, p.description FROM Contact c JOIN Profile p ON p.Contact_ID = c.id WHERE c.id = ?"
        );
        stmt.setInt(1, Integer.parseInt(id));

        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            email = rs.getString("email");
            phone = rs.getString("phone");
            whatsapp = rs.getString("whatsapp");
            description = rs.getString("description");
        } else {
            out.println("<div class='error-message'>User is not available</div>");
            return;
        }

        conn.close();
    } catch (Exception e) {
        out.println("<div class='error-message'>⚠️ Error: " + e.getMessage() + "</div>");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>User Profile</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Consistent styling with home page */
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

        .profile-card h2 {
            color: #2d3436;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid #eee;
        }

        .profile-detail {
            margin: 1.2rem 0;
            color: #555;
            font-size: 1.1rem;
        }

        .profile-detail strong {
            color: #2d3436;
            min-width: 120px;
            display: inline-block;
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

        .error-message {
            background: #ffe3e3;
            color: #dc3545;
            padding: 1rem;
            border-radius: 8px;
            margin: 2rem;
            border: 1px solid #ffc9c9;
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
            
            .profile-detail {
                font-size: 1rem;
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
        <a class="profile-link" href="profile.jsp">My Profile</a>
        <a class="profile-link" href="home_user.jsp">Logout</a>
    </div>
</div>

<div class="profile-container">
    <div class="profile-card">
        <h2>User Profile</h2>
        
        <div class="profile-detail">
            <strong>Email:</strong> <%= email.isEmpty() ? "Not provided" : email %>
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
            <strong>Description:</strong> <%= description.isEmpty() ? "No description available" : description %>
        </div>

        <a href="home.jsp" class="back-link">Back to Home</a>
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