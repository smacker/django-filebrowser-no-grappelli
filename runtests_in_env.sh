#!/bin/bash

DJANGO_VERSIONS=("1.8.0" "1.9.0" "1.10.0" "1.11.0" "2.0a")
VIRTUALENV_DIR="envs"
PROJECTS_DIR="projects"
BASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

mkdir -p $VIRTUALENV_DIR
mkdir -p $PROJECTS_DIR

for version in "${DJANGO_VERSIONS[@]}"
do
    echo "--------"
    echo "DJANGO $version"
    echo "--------"

    echo "install last django"
    if [ ! -d "$VIRTUALENV_DIR/$version" ]; then
        virtualenv --system-site-packages "$VIRTUALENV_DIR/$version"
    fi
    source "$VIRTUALENV_DIR/$version/bin/activate"
    pip install "django~=$version"

    echo "install test dependencies"
    pip install -r "$BASEDIR/tests/requirements.txt"

    echo "run filebrowser test"
    python "$BASEDIR/runtests.py"

    if [ -d "$PROJECTS_DIR/fb-dj$version" ]; then
        continue
    fi

    echo "prepare projects for manual testing"
    PROJECT_PATH="$PROJECTS_DIR/fb-dj$version"
    rm -rf $PROJECT_PATH
    mkdir -p $PROJECT_PATH
    django-admin startproject fb $PROJECT_PATH
    ln -s "$BASEDIR/filebrowser" "$PROJECT_PATH/filebrowser"

    echo "
INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'filebrowser',
    #'dummy',
)

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'test.db'),
    }
}

MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
MEDIA_URL = '/media/'
    " >> "$PROJECT_PATH/fb/settings.py"

    echo "
from django.conf import settings
from django.conf.urls.static import static
from django.conf.urls import include, url
from filebrowser.sites import site

from django.contrib import admin
admin.autodiscover()

urlpatterns = [
    url(r'^admin/filebrowser/', include(site.urls)),
    url(r'^admin/', include(admin.site.urls)),
]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
" > "$PROJECT_PATH/fb/urls.py"

    (
        cd $PROJECT_PATH
        mkdir -p media/uploads/
        mkdir -p media/_versions/

        python manage.py test

        python manage.py startapp dummy

        echo "
from django.db import models
from filebrowser.fields import FileBrowseField, FileBrowseUploadField

class DemoItem(models.Model):
    title = models.CharField('Title', max_length=210)
    attach = FileBrowseField('Attach', max_length=200)
    upload = FileBrowseUploadField('Attach', max_length=200)
        " > dummy/models.py

        echo "
from django.contrib import admin
from dummy.models import DemoItem

class DemoAdmin(admin.ModelAdmin):
    pass

admin.site.register(DemoItem, DemoAdmin)
        " > dummy/admin.py

        sed -i "s/#'dummy/'dummy/" fb/settings.py

        python manage.py makemigrations

        python manage.py migrate
        python manage.py createsuperuser --noinput --username admin --email admin@sample.com

    )
done


