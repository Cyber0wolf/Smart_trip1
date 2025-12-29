# Procfile for Render deployment
# Uses gunicorn to serve Django WSGI application
# Automatically detects the Django project folder (smart_trip)
web: gunicorn smart_trip.wsgi:application --bind 0.0.0.0:$PORT

