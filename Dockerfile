FROM debian:bookworm

# Install dependencies 
RUN apt update && apt install -y \ 
	curl git vim build-essential \
    software-properties-common \
    && apt clean

# Cloning the Github repo with the Script codes.
RUN git clone https://github.com/krishnaprasad-2001/AdminAssist    /root/AdminAssist

WORKDIR /root/AdminAssist

# Set the default command to bash
CMD ["bash"]
