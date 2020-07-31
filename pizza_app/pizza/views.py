from django.http import HttpResponse
from django.template import loader

from .models import Pizza, Ingredient


def index(request):
    pizzas = Pizza.objects.all()
    template = loader.get_template('pizza/index.html')
    context = {
        'pizzas': pizzas,
    }
    return HttpResponse('<h1>Pizzas:</h1>' + template.render(context, request))


def detail(request, pizza_id):
    return HttpResponse("You're looking at the ingredients for pizza %s." % pizza_id)
