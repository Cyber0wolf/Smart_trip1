# Smart Trip Planner

Smart Trip Planner is a full-stack application built using **Flutter** for the frontend and **Django (REST Framework)** for the backend.  
The project demonstrates real-world application development with authentication, trip management, and CI pipelines.

---

## Features

### Backend (Django + DRF)
- User authentication (JWT-based)
- Trip creation and management
- Shared trips with collaborators
- Polls and voting system
- Real-time chat support
- REST APIs with structured endpoints
- Backend CI using GitHub Actions

### Frontend (Flutter)
- Flutter-based mobile UI
- State management using BLoC
- Authentication screens
- Trip listing and trip details
- Poll and chat interface
- Frontend CI using GitHub Actions

---

## Tech Stack

- **Frontend:** Flutter, Dart
- **Backend:** Django, Django REST Framework
- **Database:** SQLite (development)
- **CI/CD:** GitHub Actions

---

## Project Structure

.github/workflows/ # CI pipelines
frontend/ # Flutter app
chat/ # Django chat app
trips/ # Django trips app
users/ # Django users app
smart_trip/ # Django project settings
manage.py
requirements.txt


## Setup

### Backend
```bash
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
Frontend
bash
Copy code
cd frontend
flutter pub get
flutter run
CI Status
Frontend CI: Enabled via GitHub Actions

Backend CI: Enabled via GitHub Actions

Both pipelines run automatically on push.

Purpose
This project was developed as a technical assignment to demonstrate:

Full-stack development skills

Frontend–backend integration

CI pipeline setup and debugging

Professional project structuring

Author
Yash Vishwakarma
GitHub: https://github.com/Cyber0wolf




If you want, next I can give you:
- a **1-minute interview explanation**
- or a **final submission checklist**
