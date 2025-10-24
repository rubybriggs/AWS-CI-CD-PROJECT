# Stage 1: Build & Dependencies
FROM python:3.8-slim-buster

# Security: Create a non-root user and switch to it
# This step ensures the application runs with limited permissions
RUN adduser --disabled-password --gecos "" appuser
USER appuser

# Set working directory
WORKDIR /app

# Efficiency: Copy only requirements.txt first to leverage Docker's build cache
COPY requirements.txt .

# Install Python dependencies
# Use --no-cache-dir to prevent caching pip files, further reducing image size
RUN pip install --no-cache-dir -r requirements.txt

# Temporarily switch back to root for installing system dependencies
# This is necessary for apt-get permissions.
USER root

# Install system dependencies (including awscli and ffmpeg components)
# The fix for your error is here: USER root must be on its own line before RUN.
# We also combine all apt commands and cleanup into one layer to minimize image size.
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        awscli \
        ffmpeg \
        libsm6 \
        libxext6 \
        unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Switch back to the non-root user (appuser) before running the application
USER appuser

# Copy application code (ensure a .dockerignore file is present)
COPY . .

# Start the application
CMD ["python3", "app.py"]
