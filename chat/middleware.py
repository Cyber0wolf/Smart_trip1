from urllib.parse import parse_qs
from jwt import decode as jwt_decode
from django.conf import settings
from django.contrib.auth import get_user_model
from channels.middleware import BaseMiddleware
from channels.db import database_sync_to_async
from rest_framework_simplejwt.exceptions import InvalidToken

User = get_user_model()

@database_sync_to_async
def get_user(user_id):
    return User.objects.get(id=user_id)

class JWTAuthMiddleware(BaseMiddleware):
    async def __call__(self, scope, receive, send):
        query_string = parse_qs(scope["query_string"].decode())
        token = query_string.get("token")

        if token:
            try:
                payload = jwt_decode(
                    token[0],
                    settings.SECRET_KEY,
                    algorithms=["HS256"],
                )
                scope["user"] = await get_user(payload["user_id"])
            except Exception:
                scope["user"] = None
        else:
            scope["user"] = None

        return await super().__call__(scope, receive, send)
