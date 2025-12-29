from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status
import logging
import traceback

logger = logging.getLogger(__name__)


def custom_exception_handler(exc, context):
    """
    Global DRF exception handler
    """
    response = exception_handler(exc, context)

    if response is not None:
        return Response(
            {
                "success": False,
                "error": {
                    "type": exc.__class__.__name__,
                    "details": response.data
                }
            },
            status=response.status_code
        )

    # Log the full exception for debugging (critical for production debugging)
    logger.error(
        f"Unhandled exception: {exc.__class__.__name__}: {str(exc)}\n"
        f"Traceback:\n{traceback.format_exc()}"
    )
    
    # In production (DEBUG=False), return generic message
    # But log the actual error for debugging in Render logs
    from django.conf import settings
    error_details = "Something went wrong. Please try again later."
    
    # In development, show the actual error message
    if settings.DEBUG:
        error_details = str(exc)
    
    # Fallback for unhandled errors
    return Response(
        {
            "success": False,
            "error": {
                "type": exc.__class__.__name__,
                "details": error_details
            }
        },
        status=status.HTTP_500_INTERNAL_SERVER_ERROR
    )
