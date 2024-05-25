from huey.contrib.djhuey import task
from core.emails import welcome_email

@task()
def send_welcome_email_task(user):
    welcome_email(user)

