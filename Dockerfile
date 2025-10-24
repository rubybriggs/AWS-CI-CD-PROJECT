# Dockerfile

# Stage 1: Use a reliable base image
FROM python:3.10-slim-buster 

# Set environment variables for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# Security: Create a non-root user and switch to it
RUN adduser --disabled-password --gecos "" appuser
USER appuser

# Set working directory
WORKDIR /app

# Efficiency: Copy requirements first to leverage build cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Temporarily switch back to root for installing system dependencies (e.g., ffmpeg components)
USER root

# Install system dependencies and perform cleanup in a single RUN layer
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        awscli \
        ffmpeg \
        libsm6 \
        libxext6 \
        unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Switch back to the non-root user for running the app
USER appuser

# Copy the rest of the application code
COPY . .

# Expose the port the application runs on (Hypothetical web app)
EXPOSE 8000

# Command to run the application
CMD ["python3", "app.py"]
