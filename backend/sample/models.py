from django.db import models
from django.contrib.auth.models import User
from uuid import uuid4
# Create your models here.

class Url(models.Model):
    provided_url = models.URLField(default="")
    calculated_prefix = models.CharField(default="", max_length=7)
    routing_count = models.IntegerField(default=0)
    user_hash = models.UUIDField(default=uuid4())
