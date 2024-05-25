import os
from django.core.mail import send_mail

EMAIL = os.environ.get('EMAIL_HOST_USER')
EMAIL_PASS = os.environ.get('EMAIL_HOST_PASSWORD')



def welcome_email(user):
    send_mail(
        "Welcome To Login App",
        f"Hello {user.username} it's nice to have you on my dope app :)",
        EMAIL, [user.email],
        fail_silently=False,
    )