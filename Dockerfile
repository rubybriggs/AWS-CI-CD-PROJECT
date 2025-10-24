# Stage 1: Build & Dependencies
# Use a more specific slim image
FROM python:3.8-slim-buster

# Security: Create a non-root user and switch to it
RUN adduser --disabled-password --gecos "" appuser
USER appuser

# Set working directory
WORKDIR /app

# Efficiency: Copy only requirements.txt first to leverage Docker's build cache
COPY requirements.txt .

# Install Python dependencies
# This layer is only invalidated when requirements.txt changes
RUN pip install --no-cache-dir -r requirements.txt

# Install system dependencies (including awscli and ffmpeg components)
# Ensure cleanup is done in the same layer to reduce image size
USER root # Temporarily switch back to root for apt
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        awscli \
        ffmpeg \
        libsm6 \
        libxext6 \
        unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Switch back to the non-root user
USER appuser

# Copy application code (use a .dockerignore file to exclude unnecessary files)
COPY . .

# Start the application
CMD ["python3", "app.py"]
