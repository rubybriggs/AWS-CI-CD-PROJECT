# Dockerfile

# Use a newer, supported Debian distribution (Bullseye) to avoid repository 404 errors.
FROM python:3.10-slim-bullseye 

# Set environment variables for non-interactive installs, a good practice for Debian.
ENV DEBIAN_FRONTEND=noninteractive

# Security: Create a non-root user and switch to it.
RUN adduser --disabled-password --gecos "" appuser
USER appuser

# Set working directory.
WORKDIR /app

# Efficiency: Copy requirements first to leverage Docker's build cache.
COPY requirements.txt .

# Install Python dependencies. Use --no-cache-dir to keep the image slim.
RUN pip install --no-cache-dir -r requirements.txt

# Temporarily switch back to root for installing system dependencies (apt-get requires root).
USER root

# Install system dependencies and perform cleanup in a single RUN layer.
# This minimizes the image size by immediately removing package lists and temporary files.
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        awscli \
        ffmpeg \
        libsm6 \
        libxext6 \
        unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Switch back to the non-root user (appuser) before running the application.
USER appuser

# Copy the rest of the application code.
COPY . .

# Expose the application port (Hypothetical, adjust as needed).
EXPOSE 8000

# Command to run the application.
CMD ["python3", "app.py"]

