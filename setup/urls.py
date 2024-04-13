from django.contrib import admin
from django.urls import path
from core import views

urlpatterns = [
    path("", views.index, name="home"),
    path("signin/", views.signin, name="signin"),    
    path("signup/", views.signup, name="signup"),
    path("signout/", views.signout, name="signout"),

    path('admin/', admin.site.urls),
]