FROM python:3.6-alpine3.8

RUN  apk add --no-cache gcc musl-dev libffi-dev libev-dev

RUN mkdir -p /app
WORKDIR /app

COPY ./flask-kanban /app
RUN  pip install --no-cache-dir -r requirements.txt && \
     sed -i "s|host='localhost'|host='0.0.0.0'|g" run.py 

RUN apk add --no-cache tzdata

EXPOSE 5000

CMD [ "python", "run.py" ]


