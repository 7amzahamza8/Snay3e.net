<%@ include file="db_config.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String msg = "";
    boolean accountCreated = false;
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String name = request.getParameter("name");
        String locationIdStr = request.getParameter("location");
        String categoryIdStr = request.getParameter("category");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String whatsapp = request.getParameter("whatsapp");
        String description = request.getParameter("description");
        String password = request.getParameter("password");

        try {
            int locationId = Integer.parseInt(locationIdStr);
            int categoryId = Integer.parseInt(categoryIdStr);


Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            PreparedStatement insertContact = conn.prepareStatement(
                "INSERT INTO Contact (Phone, email, whatsapp) VALUES (?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            insertContact.setString(1, phone);
            insertContact.setString(2, email);
            insertContact.setString(3, whatsapp);
            insertContact.executeUpdate();

            ResultSet contactKeys = insertContact.getGeneratedKeys();
            int contactId = 0;
            if (contactKeys.next()) {
                contactId = contactKeys.getInt(1);
            }

            PreparedStatement insertProfile = conn.prepareStatement(
                "INSERT INTO Profile (Description, Personal_Image, Contact_ID, Password) VALUES (?, NULL, ?, ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            insertProfile.setString(1, description);
            insertProfile.setInt(2, contactId);
            insertProfile.setString(3, password);
            insertProfile.executeUpdate();

            ResultSet profileKeys = insertProfile.getGeneratedKeys();
            int profileId = 0;
            if (profileKeys.next()) {
                profileId = profileKeys.getInt(1);
            }

            PreparedStatement insertCraftsman = conn.prepareStatement(
                "INSERT INTO Craftsman ( Name, Location_id, Category_id, Profile_id) VALUES ( ?, ?, ?, ?)"
            );
            // insertCraftsman.setInt(1, contactId);
            insertCraftsman.setString(1, name);
            insertCraftsman.setInt(2, locationId);
            insertCraftsman.setInt(3, categoryId);
            insertCraftsman.setInt(4, profileId);
            insertCraftsman.executeUpdate();

            accountCreated = true;
            msg = "Account created successfully! Redirecting to login...";
            conn.close();

        } catch (Exception e) {
            msg = "⚠️ Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Craftsman Account</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary: #FF8C00;
            --secondary: #FFF4E6;
            --accent: #FFD8A8;
            --dark: #2D3436;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, var(--secondary) 0%, var(--accent) 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: var(--dark);
            overflow-x: hidden;
        }

        .container {
            background: rgba(255, 255, 255, 0.95);
            width: 100%;
            max-width: 800px;
            padding: 2.5rem;
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
            transform: scale(0.95);
            animation: scaleUp 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
        }

        @keyframes scaleUp {
            to { transform: scale(1); }
        }

        .form-column {
            width:14rem;
            position: relative;
        }

        .form-column:first-child::after {
            content: '';
            position: absolute;
            right: -1rem;
            top: 50%;
            transform: translateY(-50%);
            height: 80%;
            width: 2px;
            background: var(--accent);
        }

        h2 {
            text-align: center;
            font-size: 2rem;
            margin-bottom: 1.5rem;
            color: var(--primary);
            grid-column: 1 / -1;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.8rem;
        }

        h2 i {
            animation: bounce 2s infinite;
        }

        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .form-group {
            position: relative;
            margin: 1.2rem 0;
        }

        input, select {
            width: 100%;
            padding: 1rem 1rem 1rem 3rem;
            border: 2px solid var(--accent);
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: white;
        }

        input:focus, select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 15px rgba(255, 140, 0, 0.2);
        }

        .input-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--primary);
        }

        select {
            appearance: none;
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23FF8C00'%3e%3cpath d='M7 10l5 5 5-5z'/%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 1rem center;
            background-size: 1em;
        }

        button {
            width: 100%;
            padding: 1rem;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            grid-column: 1 / -1;
            position: relative;
            overflow: hidden;
        }

        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 140, 0, 0.3);
        }

        button::after {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: rgba(255, 255, 255, 0.1);
            transform: rotate(45deg);
            transition: all 0.5s ease;
        }

        button:hover::after {
            left: 120%;
        }

        .msg {
            text-align: center;
            padding: 1rem;
            border-radius: 8px;
            margin: 1rem 0;
            grid-column: 1 / -1;
            animation: slideDown 0.4s ease-out;
        }

        @keyframes slideDown {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        @media (max-width: 768px) {
            .container {
                grid-template-columns: 1fr;
                padding: 1.5rem;
            }
            
            .form-column:first-child::after {
                display: none;
            }
            
            h2 {
                font-size: 1.75rem;
            }
        }
        
        .container {
    max-width: 700px; /* Reduced container width */
    padding: 1.5rem;  /* Reduced padding */
    gap: 1.5rem;      /* Reduced gap between columns */
}

.form-group {
    margin: 0.8rem 0; /* Reduced margin between fields */
}

input, select {
    padding: 0.8rem 0.8rem 0.8rem 2.5rem; /* Smaller padding */
    font-size: 0.9rem; /* Smaller font size */
}

.input-icon {
    left: 0.8rem;     /* Adjusted icon position */
    font-size: 0.9rem; /* Smaller icons */
}

button {
    padding: 0.8rem;  /* Smaller button */
    font-size: 1rem;
}

.login-link {
    text-align: center;
    margin-top: 1rem;
    grid-column: 1 / -1;
}

.login-link a {
    color: var(--primary);
    text-decoration: none;
    font-weight: 500;
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
}

.login-link a:hover {
    color: #e67e00;
    transform: translateY(-1px);
}

.login-link a i {
    transition: transform 0.3s ease;
}

.login-link a:hover i {
    transform: translateX(3px);}
    .image-uploader {
    margin: 2rem auto;
    max-width: 600px;
    padding: 1rem;
}

.upload-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 250px;
    background: rgba(255, 255, 255, 0.95);
    border: 2px dashed #ffd8a8;
    border-radius: 20px;
    padding: 2rem;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
}

.upload-container:hover {
    border-color: #ffaa00;
    transform: translateY(-2px);
    box-shadow: 0 8px 32px rgba(255, 138, 0, 0.1);
}

.upload-content {
    text-align: center;
    z-index: 2;
}

.upload-icon {
    width: 64px;
    height: 64px;
    color: #ffaa00;
    margin-bottom: 1rem;
    transition: transform 0.3s ease;
}

.upload-text {
    color: #2d3436;
    font-weight: 600;
    margin-bottom: 0.5rem;
}

.upload-subtext {
    color: #6c757d;
    font-size: 0.9rem;
}

.image-preview {
    width: 100%;
    height: 200px;
    margin-top: 1.5rem;
    border-radius: 15px;
    overflow: hidden;
    position: relative;
    background: #f8f9fa;
    display: none;
}

.image-preview img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 15px;
}

/* Drag Over State */
.upload-container.dragover {
    border-color: #ff8a00;
    background: rgba(255, 138, 0, 0.05);
}

/* Error Message */
.upload-error {
    color: #dc3545;
    margin-top: 1rem;
    font-size: 0.9rem;
    display: none;
}

/* Responsive Design */
@media (max-width: 768px) {
    .upload-container {
        padding: 1.5rem;
        min-height: 200px;
    }
    
    .upload-icon {
        width: 48px;
        height: 48px;
    }
}
    </style>

</head>

<body>
<form method="post" accept-charset="UTF-8" onsubmit="return validateForm()">
<div class="container">

    <h2><i class="fas fa-tools"></i>Craftsman Registration</h2>
    
    <div class="form-column">
        <div class="form-group">
            <i class="fas fa-user input-icon"></i>
            <input type="text" name="name" id="name" placeholder="Full Name" required>
        </div>
<%-- <div class="image-uploader">
    <input type="file" id="imageInput" accept="image/*" hidden>
    <label for="imageInput" class="upload-container">
        <div class="upload-content">
            <svg class="upload-icon" viewBox="0 0 24 24">
                <path fill="currentColor" d="M14,13V17H10V13H7L12,8L17,13H14M19.35,10.03C18.67,6.59 15.64,4 12,4C9.11,4 6.6,5.64 5.35,8.03C2.34,8.36 0,10.9 0,14A6,6 0 0,0 6,20H19A5,5 0 0,0 24,15C24,12.36 21.95,10.22 19.35,10.03Z"/>
            </svg>
            <p class="upload-text">Drag & drop or click to upload</p>
            <p class="upload-subtext">PNG, JPG up to 5MB</p>
        </div>
        <div class="image-preview" id="imagePreview"></div>
    </label>
</div> --%>
        <div class="form-group">
        
            <i class="fas fa-map-marker-alt input-icon"></i>
            <select name="location" id="location" required>
                <option value="">Choose Governorate</option>
                <option value="1">Cairo</option>
                <option value="2">Giza</option>
                <option value="3">Alexandria</option>
                <option value="4">Dakahlia</option>
                <option value="5">Beheira</option>
                <option value="6">Sharqia</option>
                <option value="7">Qalyubia</option>
                <option value="8">Monufia</option>
                <option value="9">Gharbia</option>
                <option value="10">Fayoum</option>
                <option value="11">Kafr El Sheikh</option>
                <option value="12">Beni Suef</option>
                <option value="13">Minya</option>
                <option value="14">Assiut</option>
                <option value="15">Sohag</option>
                <option value="16">Qena</option>
                <option value="17">Luxor</option>
                <option value="18">Aswan</option>
                <option value="19">Matrouh</option>
                <option value="20">North Sinai</option>
                <option value="21">South Sinai</option>
                <option value="22">Red Sea</option>
                <option value="23">Suez</option>
                <option value="24">Ismailia</option>
                <option value="25">Port Said</option>
                <option value="26">Damietta</option>
                <option value="27">New Valley</option>
            </select>
        </div>

        <div class="form-group">
            <i class="fas fa-briefcase input-icon"></i>
            <select name="category" id="category" required>
                <option value="">Choose Craft Type</option>
                <option value="1">Plumber</option>
                <option value="2">Painter</option>
                <option value="3">Carpenter</option>
                <option value="4">Blacksmith</option>
                <option value="5">Electrician</option>
                <option value="6">Plasterer</option>
                <option value="7">Ceramic Worker</option>
                <option value="8">Maintenance Worker</option>
            </select>
        </div>

        <div class="form-group">
            <i class="fas fa-envelope input-icon"></i>
            <input type="email" name="email" id="email" placeholder="Email Address" required>
        </div>
    </div>

    <div class="form-column">
        <div class="form-group">
            <i class="fas fa-phone input-icon"></i>
            <input type="text" name="phone" id="phone" placeholder="Phone Number" required maxlength="11" oninput="this.value = this.value.replace(/[^0-9]/g, '')">
        </div>

        <div class="form-group">
            <i class="fab fa-whatsapp input-icon"></i>
            <input type="text" name="whatsapp" id="whatsapp" placeholder="WhatsApp (Optional)">
        </div>

        <div class="form-group">
            <i class="fas fa-file-alt input-icon"></i>
            <input type="text" name="description" id="description" placeholder="About & Experience" required>
        </div>

        <div class="form-group">
            <i class="fas fa-lock input-icon"></i>
            <input type="password" name="password" id="password" placeholder="Password" required>
        

        </div>
    </div>

    <% if (!msg.isEmpty()) { %>
        <div class="msg <%= accountCreated ? "success" : "error" %>"><%= msg %></div>
        <% if (accountCreated) { %>
            <script>
                setTimeout(() => {
                    window.location.href = "login.jsp";
                }, 3000);
            </script>
        <% } %>
    <% } %>

    <button type="submit">Create Account <i class="fas fa-arrow-right"></i></button>
    <div class="login-link">
    <a href="login.jsp">
        Already have an account? Login here
        <i class="fas fa-arrow-right"></i>
    </a>
</div>
</div>
</form>
</body>

<script>
    function validateForm() {
        // Validate Full Name (must be non-empty)
        const name = document.getElementById("name").value;
        if (name.trim() === "") {
            alert("Full Name is required.");
            return false;
        }

        // Validate Email (must be a valid email format and not only numbers)
        const email = document.getElementById("email").value;
        const emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
        if (!emailPattern.test(email)) {
            alert("Please enter a valid email address.");
            return false;
        }

        // Validate Phone Number (must be exactly 11 digits)
        const phone = document.getElementById("phone").value;
        if (phone.length !== 11 || isNaN(phone)) {
            alert("Phone number must be exactly 11 digits.");
            return false;
        }

        const phones = document.getElementById("whatsapp").value;
        if (phones.length !== 11 || isNaN(phones)) {
            alert("Whats App number must be exactly 11 digits.");
            return false;
        }
        // Validate Description (must not be empty)
        const description = document.getElementById("description").value;
        if (description.trim() === "") {
            alert("Description is required.");
            return false;
        }

        // Validate Password (must be strong)
        //const password = document.getElementById("password").value;
      //  const passwordPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
        //if (!passwordPattern.test(password)) {
          //  alert("Password must be at least 8 characters long and contain a combination of uppercase letters, lowercase letters, numbers, and special characters.");
      //      return false;
       // }

        // If all validations pass, return true
        return true;
    }
    document.addEventListener('DOMContentLoaded', () => {
    const uploadContainer = document.querySelector('.upload-container');
    const imageInput = document.getElementById('imageInput');
    const imagePreview = document.getElementById('imagePreview');
    const errorMessage = document.createElement('div');
    errorMessage.className = 'upload-error';
    uploadContainer.parentNode.insertBefore(errorMessage, uploadContainer.nextSibling);

    // Handle file selection
    imageInput.addEventListener('change', handleFileSelect);
    
    // Drag and drop handlers
    uploadContainer.addEventListener('dragover', (e) => {
        e.preventDefault();
        uploadContainer.classList.add('dragover');
    });

    uploadContainer.addEventListener('dragleave', () => {
        uploadContainer.classList.remove('dragover');
    });

    uploadContainer.addEventListener('drop', (e) => {
        e.preventDefault();
        uploadContainer.classList.remove('dragover');
        const files = e.dataTransfer.files;
        if(files.length > 0) {
            imageInput.files = files;
            handleFileSelect();
        }
    });

    function handleFileSelect() {
        errorMessage.style.display = 'none';
        const file = imageInput.files[0];
        
        if(file && file.type.startsWith('image/')) {
            const reader = new FileReader();
            
            reader.onload = (e) => {
                imagePreview.innerHTML = `<img src="${e.target.result}" alt="Preview">`;
                imagePreview.style.display = 'block';
            };
            
            reader.readAsDataURL(file);
        } else {
            errorMessage.textContent = '⚠️ Please select a valid image file (PNG, JPG)';
            errorMessage.style.display = 'block';
            imagePreview.style.display = 'none';
        }
    }
});
</script>

</html>