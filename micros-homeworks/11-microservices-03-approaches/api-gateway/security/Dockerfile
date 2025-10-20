# FROM python:3.9-alpine
FROM cr.yandex/mirror/python:3.11-slim
RUN apt-get update && apt-get install -y curl

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt
COPY src ./

CMD [ "python", "./server.py" ]