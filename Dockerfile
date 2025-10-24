# 1. Base Image - Use a stable Debian image
FROM python:3.10-slim-bullseye

# 2. Set Environment Variables for the Runner
# Update this URL and version for the latest runner release
ENV RUNNER_VERSION 2.328.0
ENV RUNNER_ARCH linux-x64
ENV RUNNER_FILE actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz
ENV RUNNER_URL https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_FILE}

# 3. Install Dependencies for the Actions Runner
# Use apt-get to install core utilities and .NET dependencies (like libicu)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    tar \
    libicu72 \
    liblttng-ust1 \
    libkrb5-3 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# 4. Create Non-Root Runner User (Solves "Must not run with sudo" error)
ENV RUNNER_USER runneruser
ENV RUNNER_HOME /home/${RUNNER_USER}

RUN useradd -ms /bin/bash ${RUNNER_USER} && \
    mkdir -p /actions-runner && \
    chown -R ${RUNNER_USER}:${RUNNER_USER} /actions-runner

# 5. Download, Extract, and Configure the Runner
WORKDIR /actions-runner

# Download the runner (using curl)
RUN curl -o ${RUNNER_FILE} -L ${RUNNER_URL}

# Extract the runner files
RUN tar xzf ./${RUNNER_FILE}

# 6. Your Application Setup (Moved to ensure runner setup is complete)
WORKDIR /app
COPY . /app
# Run pip install as root for system-wide package installation (or switch user if preferred)
RUN pip install -r requirements.txt && pip install awscli

# 7. Switch to Non-Root Runner User and Set Runner Work Directory
WORKDIR /actions-runner
USER ${RUNNER_USER}

# 8. Container Command (Configure and Run the runner)
# NOTE: Replace TOKEN_HERE and URL_HERE with your actual values
# The configuration must be done when the container starts for the first time.
CMD ["./config.sh", "--url", "https://github.com/rubybriggs/AWS-CI-CD-PROJECT", "--token", "fORewkkBuZJ0Ak98YiK+MEhLj7XRp9/05W6j1zRf", "--name", "my-docker-runner", "--runonce"]
# You can replace the CMD with ['./run.sh'] if you configure it manually later.
