from urllib.parse import parse_qs
from django.contrib.auth.models import AnonymousUser
from rest_framework_simplejwt.authentication import JWTAuthentication
from channels.db import database_sync_to_async

class JWTAuthMiddleware:
    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        query_string = scope.get("query_string", b"").decode()
        params = parse_qs(query_string)

        token_list = params.get("token")

        if not token_list:
            scope["user"] = AnonymousUser()
            return await self.app(scope, receive, send)

        token = token_list[0]

        jwt_auth = JWTAuthentication()

        try:
            validated_token = jwt_auth.get_validated_token(token)
            user = jwt_auth.get_user(validated_token)
            scope["user"] = user
        except Exception as e:
            print("❌ WS JWT ERROR:", e)
            scope["user"] = AnonymousUser()

        return await self.app(scope, receive, send)

import time
import logging

logger = logging.getLogger(__name__)

class APILoggingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        start_time = time.time()

        response = self.get_response(request)

        duration = round(time.time() - start_time, 3)
        user = request.user if hasattr(request, "user") and request.user.is_authenticated else "Anonymous"

        logger.info(
            f"{request.method} {request.path} | Status: {response.status_code} | User: {user} | Time: {duration}s"
        )

        return response
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import AccessToken
from urllib.parse import parse_qs

User = get_user_model()

@database_sync_to_async
def get_user(user_id):
    return User.objects.get(id=user_id)

class JWTAuthMiddleware:
    def __init__(self, inner):
        self.inner = inner

    async def __call__(self, scope, receive, send):
        query_string = scope["query_string"].decode()
        params = parse_qs(query_string)

        token = params.get("token")

        if not token:
            scope["user"] = None
            return await self.inner(scope, receive, send)

        try:
            access = AccessToken(token[0])
            user = await get_user(access["user_id"])
            scope["user"] = user
        except Exception as e:
            print("❌ WS JWT ERROR:", e)
            scope["user"] = None

        return await self.inner(scope, receive, send)
