FROM ubuntu:22.04

# -----------------------------
# Install required packages
# -----------------------------
RUN apt update && apt install -y \
    openssh-server \
    curl \
    wget \
    unzip \
    sudo \
    python3 \
    && mkdir /var/run/sshd

# -----------------------------
# Create user 'user' with sudo
# -----------------------------
RUN useradd -m trthaodev && echo "trthaodev:thaodev@" | chpasswd && adduser trthaodev sudo

# -----------------------------
# Configure SSH
# -----------------------------
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'ClientAliveInterval 60' >> /etc/ssh/sshd_config && \
    echo 'ClientAliveCountMax 3' >> /etc/ssh/sshd_config

# -----------------------------
# Download Ngrok v3
# -----------------------------
RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz && \
    tar -xzf ngrok-v3-stable-linux-amd64.tgz && mv ngrok /usr/local/bin/

# -----------------------------
# Copy start script
# -----------------------------
COPY start-ngrok-ssh.sh /usr/local/bin/start-ngrok-ssh.sh
RUN chmod +x /usr/local/bin/start-ngrok-ssh.sh

# -----------------------------
# Expose ports
# -----------------------------
# Web server for Railway keep-alive
EXPOSE 8080
# SSH
EXPOSE 22
# Optional ports for aaPanel or FTP
EXPOSE 14489 888 80 443 20 21

# -----------------------------
# Start container
# -----------------------------
CMD ["/usr/local/bin/start-ngrok-ssh.sh"]
