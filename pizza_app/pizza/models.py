from django.db import models


class Ingredient(models.Model):
    ingredient_name = models.CharField(max_length=200)
    is_vegetarian = models.BooleanField(default=True)
    is_gluten_free = models.BooleanField(default=True)
    add_on_price = models.IntegerField()


class Pizza(models.Model):

    class Meta:
        db_table = 'pizza_pizza'

    def is_vegetarian(self):
        # TODO
        # Return True if all of the Pizza's ingredients are vegetarian, else False
        return False

    def is_gluten_free(self):
        # TODO
        # Return True if all of the Pizza's ingredients are gluten-free, else False
        return False

    pizza_name = models.CharField(max_length=200)
    ingredients = models.ManyToManyField(Ingredient)
    price = models.IntegerField()
