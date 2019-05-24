"""crypto_picker URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf.urls.static import static
from django.conf import settings

from stockpicker.views import AppHealthCheckView, CeleryHealthCheckView, DatabaseHealthCheckView
from tickers.views import PickerPageView

urlpatterns = [
    path('admin/', admin.site.urls),

    path('', PickerPageView.as_view(), name='picker_page'),

    path('tickers/', include('tickers.urls', namespace='tickers')),

    path('health/app/', AppHealthCheckView.as_view(), name="health-check-app"),
    path('health/celery/', CeleryHealthCheckView.as_view(), name="health-check-celery"),
    path('health/database/', DatabaseHealthCheckView.as_view(), name="health-check-database"),

] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
