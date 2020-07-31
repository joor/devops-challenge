from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    # ex: /pizza/1/
    url(r'^(?P<pizza_id>[0-9]+)/$', views.detail, name='detail'),
]
