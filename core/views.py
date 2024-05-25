from django.shortcuts import render, HttpResponseRedirect
from django.contrib.auth import authenticate, login, logout, get_user_model
from django.contrib.auth.decorators import login_required
from core.tasks import send_welcome_email_task

User = get_user_model()

# list user
def index(request):
    users = User.objects.all()
    return render(request, "index.html", { "users": users })


# login
def signin(request):
    if request.method == "POST":
        username = request.POST.get("username", None)
        password = request.POST.get("password", None)
        if password and username:
            user = authenticate(request, username=username, password=password)
            if user is not None:
                login(request, user)
                return HttpResponseRedirect("/")
    return render(request, "signin.html")

# registration
def signup(request):
    if request.method == "POST":
        try:
            username = request.POST.get("username", None)
            password = request.POST.get("password", None)
            email = request.POST.get("email", None)

            if password and username and email:
                user = User.objects.create_user(username=username, email=email)
                user.set_password(password)
                user.save()
                if user is not None:
                    login(request, user)
                    send_welcome_email_task(user)
                    return HttpResponseRedirect("/")
        except Exception as e:
            print(e)
                
    return render(request, "signup.html")

# logout
@login_required(login_url="signin/")
def signout(request):
    logout(request)
    return render(request, "signout.html")
