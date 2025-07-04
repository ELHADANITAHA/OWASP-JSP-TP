# Dockerfile template for SAST (Trivy) container
# Installs Trivy and dependencies for static application security testing
FROM ${base_image}

# Install dependencies and Trivy
RUN apt-get update && \
    apt-get install -y curl gnupg lsb-release ca-certificates && \
    curl -fsSL https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor -o /usr/share/keyrings/trivy-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/trivy-archive-keyring.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/trivy.list && \
    apt-get update && \
    apt-get install -y trivy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /SAST
# Default entrypoint
CMD ["bash"]



