# ==========================================
# Consolidated Pathnex Dockerfile
# ==========================================
# This Dockerfile provides examples for Python, Node.js, Java, and Nginx applications.
# Use the appropriate stage or base image for your specific application.

# ------------------------------------------
# Example 1: Python Flask Application
# ------------------------------------------
FROM python:3.11 AS python-app
WORKDIR /opt/pathnex/flask-app

# Copy application files
COPY app.py /opt/pathnex/flask-app/
COPY . /opt/pathnex/flask-app/

# Install dependencies
RUN apt-get update && pip install flask

# Start application
CMD ["python", "/opt/pathnex/flask-app/app.py"]


# ------------------------------------------
# Example 2: Node.js Application
# ------------------------------------------
FROM node:18 AS node-app
WORKDIR /opt/pathnex/node-app

# Copy application files
COPY app.js /opt/pathnex/node-app/

# Start application
CMD ["node", "/opt/pathnex/node-app/app.js"]


# ------------------------------------------
# Example 3: Java Application
# ------------------------------------------
FROM openjdk:11 AS java-app
WORKDIR /opt/pathnex/java-app

# Copy and compile application files
COPY Hello.java /opt/pathnex/java-app/
RUN javac /opt/pathnex/java-app/Hello.java

# Start application
CMD ["java", "-cp", "/opt/pathnex/java-app", "Hello"]


# ------------------------------------------
# Example 4: Nginx Static Web Server
# ------------------------------------------
FROM nginx:latest AS web-server

# Copy static files to nginx html directory
COPY index.html /usr/share/nginx/html/index.html

# Expose HTTP port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]


# ------------------------------------------
# Example 5: Custom Script Execution
# ------------------------------------------
FROM ubuntu:latest AS script-runner
WORKDIR /opt/pathnex/scripts

# Copy script and make it executable
COPY start.sh /opt/pathnex/scripts/
RUN chmod +x /opt/pathnex/scripts/start.sh

# Define persistent volume for data
VOLUME ["/opt/pathnex/data"]

# Start script
CMD ["/opt/pathnex/scripts/start.sh"]
