#!/bin/bash

# Update & install Docker
sudo apt update -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Create app directory
mkdir -p /opt/flask-app

# Add app source code inline (use Terraform file provisioners for real deployments)
cat <<EOF > /opt/flask-app/main.py
from flask import Flask, jsonify
import random

app = Flask(__name__)
OPTIONS = ["Investments", "Smallcase", "Stocks", "buy-the-dip", "TickerTape"]

@app.route('/api/v1', methods=['GET'])
def get_random_string():
    return jsonify({"message": random.choice(OPTIONS)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081)
EOF

cat <<EOF > /opt/flask-app/requirements.txt
flask
EOF

cat <<EOF > /opt/flask-app/Dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY main.py requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8081
CMD ["python", "main.py"]
EOF

# Build and run container
cd /opt/flask-app
docker build -t flask-random-api .
docker run -d -p 8081:8081 flask-random-api
