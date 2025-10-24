# Using the old Buster image as requested.
FROM python:3.8-slim-buster

WORKDIR /app
COPY . /app

# FIX: Update the Debian package source list to point to the archive server.
# Buster is now old-stable, and its packages have been moved. This command
# manually redirects the repository URLs to the archive server, resolving
# the "does not have a Release file" error (Exit Code 100).
…        libxext6 \
        unzip \
    && pip install --no-cache-dir -r requirements.txt \
    # Cleanup to reduce image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["python3", "app.py"]
