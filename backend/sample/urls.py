from django.conf.urls import url
from . import views
from django.urls import path
urlpatterns = [
    path(r"url", views.UrlInfo.as_view()),
    path(r'<str:calculated_prefix>', views.UrlRedirect.as_view()),

]
