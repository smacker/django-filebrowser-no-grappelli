from django.conf.urls import include, url
from django.contrib import admin

from filebrowser.sites import site

admin.autodiscover()

urlpatterns = [
    url(r'^admin/filebrowser/',
        include(site.urls[:2], namespace=site.urls[2])),
    url(r'^admin/', include(admin.site.urls[:2], admin.site.urls[2])),
]
