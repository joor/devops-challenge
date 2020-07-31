FROM django

ENV PORT ${PORT:-8080}

ADD . /pizza_app

WORKDIR /pizza_app

CMD [ "python", "./manage.py runserver 0.0.0.0:${PORT}" ]
