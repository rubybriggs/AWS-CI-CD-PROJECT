FROM python:3.8-slim-buster

WORKDIR /app
COPY . /app


RUN # 1. FIX: Update the Debian package source list to point to the archive server (for Buster).
    sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list \
    && sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list \
    && echo "deb http://security.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list \
    \
    # 2. Update and Install packages
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        awscli \
        ffmpeg \
        libsm6 \
        libxext6 \
        unzip \
    \
    # 3. Install Python requirements
    && pip install --no-cache-dir -r requirements.txt \
    \
    # 4. Cleanup to reduce image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["python3", "app.py"]
