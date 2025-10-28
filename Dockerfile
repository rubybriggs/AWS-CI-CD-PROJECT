# Dockerfile

# Use the recommended Amazon Linux 2 based image if deploying with the ECS-based EB environment.
# If using the standard Docker platform, your choice (python:3.10-slim-bullseye) is fine,
# but the standard EB Docker platform requires the application to run on port 80.
# We will use python:3.10-slim-bullseye and address the port requirement later.
FROM python:3.10-slim-bullseye

# Set environment variables for non-interactive installs, a good practice for Debian.
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# *** 1. Prepare Environment (System Packages) ***

# Temporarily switch to root for installing system dependencies and essential tools.
USER root

# Install system dependencies and perform cleanup in a single RUN layer.
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        # Essential build tools often needed for compiling Python packages
        build-essential \
        # Dependencies for popular image/video libraries (like Pillow, OpenCV)
        libsm6 \
        libxext6 \
        ffmpeg \
        # General utilities
        unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# *** 2. Create User and Set Working Directory ***

# Security: Create a non-root user and switch to it.
RUN adduser --disabled-password --gecos "" appuser
# Set working directory for the non-root user.
WORKDIR /app

# *** 3. Install Python Dependencies ***

# Efficiency: Copy requirements first to leverage Docker's build cache.
COPY requirements.txt .

# Install Python dependencies.
RUN pip install --no-cache-dir -r requirements.txt

# *** 4. Copy Application Code ***

# Copy the rest of the application code.
COPY --chown=appuser:appuser . .

# *** 5. Elastic Beanstalk Requirements ***

# CRITICAL: AWS Elastic Beanstalk in its standard configuration expects the application 
# to listen on port 80. You MUST expose port 80, or the EB health checks will fail.
EXPOSE 80

# CRITICAL: Beanstalk requires a specific command to run the application.
# Replace 'your_app_command' with the actual run command (e.g., gunicorn -b 0.0.0.0:80 wsgi:application)
# Note: The application must bind to 0.0.0.0 and port 80 (or $PORT if you configure it)
#CMD ["gunicorn", "--bind", "0.0.0.0:80", "your_module:app"]
# Example for a simple Flask app: 
CMD ["python3", "app.py"]
