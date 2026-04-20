<%@ page import="java.time.*" %>
<%@ include file="db_config.jsp" %>
<%
    String CRAFTSMAN_ID_PARAM = "craftsman_id";
    String USER_ID_PARAM = "user_id";
    request.setCharacterEncoding("UTF-8");
    String msg = "";
    boolean ratingInserted = false;

    // Get parameters from URL or set defaults
    String craftsmanIdStr = request.getParameter(CRAFTSMAN_ID_PARAM);
    String userIdStr = request.getParameter(USER_ID_PARAM);
    
    // If no parameters, set defaults (you should replace these with actual values)
    if (craftsmanIdStr == null || craftsmanIdStr.isEmpty()) {
        craftsmanIdStr = "1"; // This should be dynamic - get from session or URL
    }
    if (userIdStr == null || userIdStr.isEmpty()) {
        userIdStr = "2"; // This should be dynamic - get from user session
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");
        // Use the craftsmanIdStr and userIdStr variables that are already declared above

        try {
            if (ratingStr == null || ratingStr.isEmpty()) {
                throw new Exception("Please select a rating.");
            }

            int stars = Integer.parseInt(ratingStr);
            int craftsmanId = Integer.parseInt(craftsmanIdStr);
            int userId = Integer.parseInt(userIdStr);

            if (stars < 1 || stars > 5) throw new Exception("Stars must be between 1 and 5.");

            Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            PreparedStatement insertRating = conn.prepareStatement(
                "INSERT INTO rating (craftsman_id, user_id, stars, comment) VALUES (?, ?, ?, ?)"
            );
            insertRating.setInt(1, craftsmanId);
            insertRating.setInt(2, userId);
            insertRating.setInt(3, stars);
            insertRating.setString(4, comment);
            insertRating.executeUpdate();

            conn.close();
            ratingInserted = true;
            msg = "Rating submitted successfully! You will be redirected to home page shortly.";

        } catch (Exception e) {
            msg = "Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Rate Craftsman</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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

        .rating-container {
            margin-top: 140px;
            padding: 2rem 5%;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }

        .rating-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 2.5rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.05);
            animation: fadeInUp 0.8s ease;
        }

        .rating-card h2 {
            color: #2d3436;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid #eee;
            text-align: center;
        }

        .stars-container {
            display: flex;
            justify-content: center;
            margin: 2rem 0;
            gap: 0.5rem;
        }

        .star {
            font-size: 2.5rem;
            color: #ddd;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .star.selected {
            color: #ffaa00;
            transform: scale(1.1);
        }

        .star:hover {
            color: #ffaa00;
            transform: scale(1.1);
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: #555;
            font-weight: 500;
        }

        textarea {
            width: 100%;
            height: 120px;
            border-radius: 12px;
            border: 1px solid #ddd;
            padding: 1rem;
            font-size: 1rem;
            resize: vertical;
            transition: all 0.3s ease;
        }

        textarea:focus {
            outline: none;
            border-color: #ffaa00;
            box-shadow: 0 0 0 2px rgba(255, 170, 0, 0.2);
        }

        .submit-btn {
            display: block;
            width: 100%;
            padding: 1rem;
            background: linear-gradient(45deg, #ff8a00, #ffaa00);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(255, 138, 0, 0.2);
        }

        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 138, 0, 0.3);
        }

        .message {
            margin-top: 1.5rem;
            padding: 1rem;
            border-radius: 12px;
            text-align: center;
            font-weight: 500;
        }

        .message.success {
            background: #e8f5e9;
            color: #2e7d32;
            border: 1px solid #c8e6c9;
        }

        .message.error {
            background: #ffebee;
            color: #c62828;
            border: 1px solid #ffcdd2;
        }

        .back-link {
            display: inline-block;
            margin-top: 2rem;
            padding: 0.8rem 1.5rem;
            background: transparent;
            color: #666;
            text-decoration: none;
            border-radius: 12px;
            border: 1px solid #ddd;
            transition: all 0.3s ease;
        }

        .back-link:hover {
            background: #f5f5f5;
            transform: translateY(-2px);
        }

        .message-icon {
            margin-right: 8px;
        }

        .success-animation {
            animation: bounceIn 0.6s ease;
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

        @keyframes bounceIn {
            0% {
                opacity: 0;
                transform: scale(0.3);
            }
            50% {
                opacity: 1;
                transform: scale(1.05);
            }
            70% {
                transform: scale(0.9);
            }
            100% {
                opacity: 1;
                transform: scale(1);
            }
        }

        @media (max-width: 768px) {
            .rating-container {
                padding: 1rem;
                margin-top: 120px;
            }
            
            .rating-card {
                padding: 1.5rem;
            }
            
            .navbar {
                padding: 1rem;
            }
            
            .logo-icon {
                height: 60px;
            }
            
            .star {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>

<div class="navbar">
    <img src="Logo-removebg-preview.png" alt="Logo" class="logo-icon">
    <a href="home_user.jsp" class="profile-link">Back to Home</a>
</div>

<div class="rating-container">
    <div class="rating-card">
        <h2>Rate the Craftsman</h2>
        
        <% if (!ratingInserted) { %>
            <form method="post">
                <div class="stars-container">
                    <i class="fas fa-star star" data-value="1"></i>
                    <i class="fas fa-star star" data-value="2"></i>
                    <i class="fas fa-star star" data-value="3"></i>
                    <i class="fas fa-star star" data-value="4"></i>
                    <i class="fas fa-star star" data-value="5"></i>
                </div>

                <!-- Use dynamic values instead of hardcoded ones -->
                <input type="hidden" name="rating" id="ratingValue">
                <input type="hidden" name="craftsman_id" value="<%= craftsmanIdStr %>">
                <input type="hidden" name="user_id" value="<%= userIdStr %>">

                <div class="form-group">
                    <label for="comment">Your Comment (Optional)</label>
                    <textarea name="comment" id="comment" placeholder="Share your experience with this craftsman..."></textarea>
                </div>
                
                <button type="submit" class="submit-btn">Submit Rating</button>
            </form>
        <% } %>

        <% if (!msg.isEmpty()) { %>
            <div class="message <%= ratingInserted ? "success success-animation" : "error" %>">
                <% if (ratingInserted) { %>
                    <i class="fas fa-check-circle message-icon"></i>
                <% } else { %>
                    <i class="fas fa-exclamation-triangle message-icon"></i>
                <% } %>
                <%= msg %>
            </div>
            
            <% if (ratingInserted) { %>
                <div style="text-align: center; margin-top: 1rem; color: #666;">
                    <i class="fas fa-sync-alt fa-spin"></i> Redirecting to home page...
                </div>
                <script>
                    // Redirect to home page after 3 seconds
                    setTimeout(function() {
                        window.location.href = 'home_user.jsp';
                    }, 3000);
                </script>
            <% } %>
        <% } %>
        
        <a href="home_user.jsp" class="back-link">Back to Home</a>
    </div>
</div>

<script>
    const stars = document.querySelectorAll('.star');
    const ratingValue = document.getElementById('ratingValue');

    stars.forEach((star, index) => {
        star.addEventListener('click', () => {
            ratingValue.value = star.dataset.value;
            stars.forEach(s => s.classList.remove('selected'));
            for (let i = 0; i <= index; i++) {
                stars[i].classList.add('selected');
            }
        });
    });
</script>

</body>
</html>