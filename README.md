# NewVeg - Plant-Based Diet mHealth Application

NewVeg is a mobile-health (mHealth) platform designed to support individuals transitioning to and maintaining a plant-based diet. The project is organized into two main components: a lightweight, secure PHP backend with a web-based Admin CMS, and a Flutter-based mobile application.

---

## 📂 Project Structure

```
newveg/
├── app/                  # Flutter Mobile Application
│   ├── android/          # Android platform files
│   ├── lib/              # Dart source code (Features, UI, Services)
│   └── pubspec.yaml      # Flutter dependencies
│
└── web/                  # PHP RESTful API & Admin CMS
    ├── admin/            # Bootstrap 5 Admin Portal (CMS)
    ├── api/              # RESTful API Endpoints (Auth, Sync, Community, Content)
    ├── config/           # Database PDO & JWT configs
    ├── uploads/          # Directory for image uploads
    ├── schema.sql        # MySQL database schema & seed data
    └── setup_db.php      # CLI installer to initialize the database
```

---

## 🌐 Web Backend & Admin CMS Installation

The web backend is built with native **PHP 8.3** and **MySQL**, optimized to run efficiently with a minimal memory footprint on low-resource VPS environments.

### Requirements
- **PHP 8.3** (with `pdo_mysql` enabled)
- **MySQL** or **MariaDB**
- Web Server (Nginx, Apache, or Laragon local server)

### 1. Database Setup
1. Make sure your MySQL server is running.
2. Open your terminal, navigate to the `web` folder, and run the automatic installer script to create the database and import default seed tables:
   ```bash
   cd web
   php setup_db.php
   ```
   *Alternatively, you can manually import the `web/schema.sql` file into your MySQL client.*

### 2. Configuration (`.env`)
The database configuration defaults to `localhost`, username `root`, and empty password (standard for local Laragon/XAMPP). If you need to override these defaults, create a `.env` file inside the `web` directory:
```env
DB_HOST=127.0.0.1
DB_DATABASE=newveg
DB_USERNAME=root
DB_PASSWORD=yourpassword
GEMINI_API_KEY=your_gemini_api_key
```

### 3. Admin CMS Login Credentials
Access the Admin CMS at `http://localhost/newveg/web/admin` (or your local domain configured via Laragon):
- **Email/Username**: `admin@aa.com`
- **Password**: `admin123`

You can create more admin accounts from the terminal inside the `web/` folder using:
```bash
php create_admin.php <email> <password> "<full_name>"
```

---

## 📱 Mobile App (Flutter) Installation

The mobile application is built using the **Flutter SDK** and integrates localized SQLite databases for offline support, with sync mechanisms to sync data to the PHP server.

### Requirements
- **Flutter SDK** (Stable channel)
- **Android Studio** or **VS Code** with Flutter extensions
- Android Emulator or physical test device

### 1. Install Dependencies
Navigate into the `app` folder and fetch the package dependencies:
```bash
cd app
flutter pub get
```

### 2. Configure Server URL
Open the API/Sync config inside the Flutter codebase (e.g., in service configurations) and update the base URL to point to your hosted/local PHP REST API endpoint:
- Local emulator URL: `http://10.0.2.2/newveg/web/api/`

### 3. Run the App
Launch the app on your connected device:
```bash
flutter run
```

---

## 🔒 Security Practices
- **Upload Restrictions**: The `web/uploads/` folder is secured with `.htaccess` to block any direct execution of PHP scripts.
- **SQL Injection Guard**: All database integrations in the REST API and Admin portal strictly use PDO prepared statements.
