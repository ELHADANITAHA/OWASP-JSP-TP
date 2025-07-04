# Dockerfile template for Ansible container
# Installs Ansible and dependencies for automation tasks
FROM ${base_image}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    sshpass \
    git \
    ansible \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /ansible

CMD ["bash"]
