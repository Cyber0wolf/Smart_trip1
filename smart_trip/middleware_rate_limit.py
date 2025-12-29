import time
from django.core.cache import cache
from django.http import JsonResponse

class RateLimitMiddleware:
    RATE_LIMIT = 100       # requests
    TIME_WINDOW = 60       # seconds

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        ip = self.get_client_ip(request)
        key = f"rate_limit:{ip}"

        data = cache.get(key, {"count": 0, "start": time.time()})

        if time.time() - data["start"] > self.TIME_WINDOW:
            data = {"count": 0, "start": time.time()}

        data["count"] += 1
        cache.set(key, data, timeout=self.TIME_WINDOW)

        if data["count"] > self.RATE_LIMIT:
            return JsonResponse(
                {"detail": "Rate limit exceeded. Try again later."},
                status=429
            )

        return self.get_response(request)

    def get_client_ip(self, request):
        x_forwarded_for = request.META.get("HTTP_X_FORWARDED_FOR")
        if x_forwarded_for:
            return x_forwarded_for.split(",")[0]
        return request.META.get("REMOTE_ADDR")
