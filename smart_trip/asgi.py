import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "smart_trip.settings")

# 🔥 IMPORTANT: initialize Django FIRST
django_asgi_app = get_asgi_application()

# Now it's safe to import Django-dependent modules
import trips.routing
from smart_trip.middleware import JWTAuthMiddleware

application = ProtocolTypeRouter({
    "http": django_asgi_app,
    "websocket": JWTAuthMiddleware(
        URLRouter(trips.routing.websocket_urlpatterns)
    ),
})
