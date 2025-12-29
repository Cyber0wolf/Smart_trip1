#!/usr/bin/env python
"""
Quick script to verify the profile route is registered correctly.
Run this to check if the route exists before restarting the server.
"""
import os
import sys
import django

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'smart_trip.settings')
django.setup()

from django.urls import get_resolver
from django.urls.resolvers import URLPattern, URLResolver

def find_url_patterns(urlpatterns, prefix='', depth=0):
    """Recursively find all URL patterns"""
    patterns = []
    for pattern in urlpatterns:
        if isinstance(pattern, URLResolver):
            # Recursive call for included URLs
            patterns.extend(find_url_patterns(
                pattern.url_patterns,
                prefix + str(pattern.pattern),
                depth + 1
            ))
        elif isinstance(pattern, URLPattern):
            full_path = prefix + str(pattern.pattern)
            patterns.append((full_path, pattern.callback))
    return patterns

def main():
    resolver = get_resolver()
    all_patterns = find_url_patterns(resolver.url_patterns)
    
    print("Checking for /auth/profile/ route...")
    print("-" * 50)
    
    profile_found = False
    auth_routes = []
    
    for path, callback in all_patterns:
        if 'profile' in path.lower():
            print(f"✓ Found: {path} -> {callback}")
            profile_found = True
        if 'auth' in path.lower():
            auth_routes.append((path, callback))
    
    if profile_found:
        print("\n✓ Profile route is registered!")
        print("\nIf you're still getting 404 errors:")
        print("1. Make sure Django server is running")
        print("2. Restart the Django server (Ctrl+C then python manage.py runserver)")
        print("3. Check that the server is on port 8000")
    else:
        print("\n✗ Profile route NOT found!")
        print("\nAll auth routes found:")
        for path, callback in auth_routes:
            print(f"  - {path} -> {callback}")
        print("\nPlease check:")
        print("1. users/urls.py has path('profile/', UserProfileView.as_view())")
        print("2. smart_trip/urls.py includes users.urls")
        print("3. UserProfileView is imported correctly in users/views.py")

if __name__ == '__main__':
    main()








