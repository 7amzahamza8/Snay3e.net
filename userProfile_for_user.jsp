<%@ include file="db_config.jsp" %>
<%
 String id = request.getParameter("id");
if (id == null) {
    out.println("<div class='error-message'>❌ No user ID provided.</div>");
    return;
}

Integer sessionUserId = (Integer) session.getAttribute("userId");
String email = "", phone = "", whatsapp = "", description = "";
double rating = 0.0;
int ratingCount = 0;
int craftsmanId = -1;

try {
    Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

    // Get contact info and profile details by joining Craftsman, Profile, and Contact
    PreparedStatement stmt = conn.prepareStatement(
        "SELECT con.email, con.Phone, con.whatsapp, p.Description " +
        "FROM Craftsman c " +
        "JOIN Profile p ON c.Profile_id = p.id " +
        "JOIN Contact con ON p.Contact_ID = con.id " +
        "WHERE c.id = ?"
    );
    stmt.setInt(1, Integer.parseInt(id));
    ResultSet rs = stmt.executeQuery();

    if (rs.next()) {
        email = rs.getString("email");
        phone = rs.getString("Phone");
        whatsapp = rs.getString("whatsapp");
        description = rs.getString("Description");
        craftsmanId = Integer.parseInt(id); // Already have it from parameter
    } else {
        out.println("<div class='error-message'>❌ Craftsman not found.</div>");
        conn.close();
        return;
    }

    // Get rating stats
    PreparedStatement stmtRating = conn.prepareStatement(
        "SELECT AVG(stars) AS avg_rating, COUNT(*) AS total FROM rating WHERE craftsman_id = ?"
    );
    stmtRating.setInt(1, craftsmanId);
    ResultSet rsRating = stmtRating.executeQuery();

    if (rsRating.next()) {
        rating = rsRating.getDouble("avg_rating");
        ratingCount = rsRating.getInt("total");
    }

    conn.close();
} catch (Exception e) {
    out.println("<div class='error-message'>⚠️ Error: " + e.getMessage() + "</div>");
}

%>

<!DOCTYPE html>
<html>
<head>
    <title>Craftsman Profile</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
   
<form action="rating.jsp" method="get">
    <input type="hidden" name="craftsman_id" value="<%= craftsmanId %>">
    <input type="hidden" name="user_id" value="<%= sessionUserId != null ? sessionUserId : 2 %>"> 
    <button type="submit" style="
            display: inline-block;
            margin-top: 2rem;
            padding: 0.8rem 1.5rem;
            background: linear-gradient(45deg, #ff8a00, #ffaa00);
            color: white;
            text-decoration: none;
            border-radius: 12px;
            border: none;
            transition: all 0.3s ease;
            cursor: pointer;
    ">
        Add Review
    </button>
   </form>
   <form action="descriptions.jsp" method="get">
    <input type="hidden" name="craftsman_id" value="<%= craftsmanId %>">
    <button type="submit" style="
            display: inline-block;
            margin-top: 2rem;
            padding: 0.8rem 1.5rem;
            background: linear-gradient(45deg, #6c757d, #868e96);
            color: white;
            text-decoration: none;
            border-radius: 12px;
            border: none;
            transition: all 0.3s ease;
            cursor: pointer;
            margin-left: 10px;
    ">
        Show Descriptions
    </button>
</form>
</form>
</div>

<div class="profile-container">
    <div class="profile-card">
        <h2>Craftsman Profile</h2>
        
        <div class="profile-detail">
            <strong>Email:</strong> 
            <% if (email != null && !email.isEmpty()) { %>
                <%= email %>
            <% } else { %>
                Not provided
            <% } %>
        </div>
        
        <div class="profile-detail">
            <strong>Phone:</strong> 
            <% if (phone != null && !phone.isEmpty()) { %>
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
        
        <%-- <div class="profile-detail">
            <strong>Description:</strong> <%= description %>
        </div> --%>

        
        <%
    try {
        Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // Fetch average stars for the craftsman linked to this profile
        PreparedStatement stmtRating = conn.prepareStatement(
            "SELECT AVG(stars) AS avg_rating, COUNT(*) AS total FROM rating WHERE craftsman_id = ?"
        );
        stmtRating.setInt(1, Integer.parseInt(id));

        ResultSet rsRating = stmtRating.executeQuery();

        if (rsRating.next()) {
            rating = rsRating.getDouble("avg_rating");
            ratingCount = rsRating.getInt("total");
        }

        conn.close();
    } catch (Exception e) {
        out.println("<div class='error-message'>⚠️ Rating Error: " + e.getMessage() + "</div>");
    }
%>

<div class="profile-detail">
    <strong>Rating:</strong>
    <div class="star-rating">
        <%
            if (ratingCount == 0) {
        %>
            <span>No ratings yet</span>
        <%
            } else {
                int fullStars = (int) rating;
                boolean halfStar = (rating - fullStars) >= 0.5;

                for (int i = 0; i < fullStars; i++) { %>
                    <i class="fas fa-star"></i>
        <%      }
                if (halfStar) { %>
                    <i class="fas fa-star-half-alt"></i>
        <%      }
                for (int i = fullStars + (halfStar ? 1 : 0); i < 5; i++) { %>
                    <i class="far fa-star"></i>
        <%      } %>
            <span>(<%= String.format("%.1f", rating) %>/5 from <%= ratingCount %> reviews)</span>
        <%
            }
        %>
    </div>
</div> 

      
        <a href="home_user.jsp" class="back-link">Back to Home</a>
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