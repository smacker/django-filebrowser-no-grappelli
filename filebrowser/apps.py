from django.apps import AppConfig
from django.utils.translation import gettext_lazy as _


class FileBrowserConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'filebrowser'
    verbose_name = _('filebrowser')
