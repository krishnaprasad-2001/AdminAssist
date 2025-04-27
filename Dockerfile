# Use Debian Bookworm as the base image
FROM debian:bookworm

# Define a build argument (default is false)
ARG INSTALL_SCRIPT=false

# Install dependencies
RUN apt update && apt install -y \
    curl git vim build-essential \
    software-properties-common \
    && apt clean

# Cloning the Github repo with the Script codes
RUN git clone https://github.com/krishnaprasad-2001/AdminAssist /root/AdminAssist

WORKDIR /root/AdminAssist

# Conditionally install the script if the INSTALL_SCRIPT argument is set to true
RUN if [ "$INSTALL_SCRIPT" = "true" ]; then \
    echo "Installing the script..."; \
    # Add commands to install or setup your script here, e.g., \
     chmod +x /root/AdminAssist/install.sh && bash /root/AdminAssist/install.sh; \
    fi

# Set the default command to bash
CMD ["bash"]
