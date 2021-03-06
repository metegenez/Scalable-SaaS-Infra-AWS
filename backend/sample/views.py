from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.shortcuts import redirect
from .models import Url
from rest_framework.response import Response
from rest_framework import status
import uuid
from django.core.validators import URLValidator
import os
# Create your views here.
class HealthCheck(APIView):
    permission_classes = [AllowAny]
    def get(self, request, format="json"):
        return Response(status=status.HTTP_200_OK)

# Create your views here.
class UrlRedirect(APIView):
    permission_classes = [AllowAny]
    def get(self, request, calculated_prefix):
        route = Url.objects.filter(calculated_prefix=calculated_prefix).first()
        route.routing_count = route.routing_count + 1
        route.save()
        return redirect(route.provided_url)


class UrlInfo(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        try:
            if "prefix" in request.query_params:
                prefix = request.query_params["prefix"]
                if Url.objects.filter(calculated_prefix=prefix).count() > 0:
                    return Response({"error": "prefix duplicated"}, status=status.HTTP_400_BAD_REQUEST)
            else:
                prefix = uuid.uuid4().hex[:7].lower()
            validate = URLValidator()
            url = "https://" + request.data["payload"]["url"]
            try:
                validate(url)
            except:
                return Response({}, status=status.HTTP_400_BAD_REQUEST)

            if Url.objects.filter(provided_url=url).count() > 0:
                return Response({}, status=status.HTTP_200_OK)
            Url.objects.create(provided_url=url, calculated_prefix=prefix)
            content = {
                "url": url,
                "shortened": os.environ.get("API_URL") + "/" + prefix
            }
            return Response(content, status=status.HTTP_200_OK)
        except:
            return Response({}, status=status.HTTP_400_BAD_REQUEST)