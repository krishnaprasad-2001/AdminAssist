# AdminAssist

## Overview

AdminAssist is a powerful tool designed to assist server administrators and support technicians in troubleshooting WordPress installations and general server-related issues. Whether you're diagnosing a misconfigured website, fixing database errors, or analyzing server logs, AdminAssist provides quick and efficient solutions to streamline your workflow.

## Why AdminAssist?

- ✅ Best for WordPress Troubleshooting – Easily detect WordPress installations, check database connectivity, list installed themes, and fix common issues.
- ✅ AI Chatbot – Online based AI chatbot that just helps you get things done. ( Since this is online chatbot, this only  works when you are connected to the internet )
- ✅ Automated Setup – A simple installation script sets up everything in `/opt/AdminAssist`.
- ✅ Modular Design – Tasks are divided into separate scripts for better organization (e.g., `db.sh` for database management, `wp.sh` for WordPress-related tasks).
- ✅ System Integration – The installer creates a shortcut (`BK`) BashKit for easy execution from anywhere.
- ✅ Docker test – Implemented a Docker module to check the script by running this in a container.

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/krishnaprasad-2001/AdminAssist.git
cd AdminAssist
```

### Run the Installer

```bash
chmod +x install.sh  
./install.sh
```

---

## 🐳 Docker Support (To test the script)

You can also use Docker to set up AdminAssist!

There are two ways to build:

### 1. Build and Install Automatically

If you want AdminAssist **installed automatically inside the container**, build the image with the `INSTALL_SCRIPT` argument:

```bash
sudo docker build --build-arg INSTALL_SCRIPT=true -t myimage .
```

This will:

- Clone AdminAssist
- Install AdminAssist automatically inside `/opt/AdminAssist`

### 2. Build Only (Clone Code, Install Later)

If you prefer to just **clone the code** and install manually later:

```bash
sudo docker build -t adminassist .
```

Then inside the container:

```bash
cd /root/AdminAssist
chmod +x install.sh
./install.sh
```

This gives you full control over when and how you install AdminAssist.

---

### 2. Using Docker for forked repo

This will copy the contents from the current directory into the container rather than cloning from the latest repository. ( You can fork the repo and use this Dockerfile2 to test the changes made from your side as this will just use the repo on your machine )

You can run the below command to get the Docker container with the current codes

```bash
sudo docker build -t testing -f Dockerfile2 .
```
Installation would be the same as in the previous step

```bash
cd /root/AdminAssist
chmod +x install.sh
./install.sh
```

### Enable Auto-Completion (Optional)

To enable tab completion, run:

```bash
source /opt/AdminAssist/autoCompletion.sh
```

---

## Usage

Once installed, you can use AdminAssist through the `BK` command:

```bash
BK chat              # To get the ChatBot interface
BK chat              # To get the ChatBot interface
BK deb               # Check debug mode  
BK tdeb              # Toggle debug mode  
BK db                # Get database details  
BK upgrade           # Upgrade the WordPress installation  
BK theme             # List installed WordPress themes  
BK fix_db            # Fix database connectivity errors  
BK nginx             # View nginx error logs
BK apache            # View Apache error logs
BK add_custom_rule   # Assist in adding nginx custom Rule  
BK ipcheck           # Check if an IP is public or private
BK dockertest        # Try out the installation by Docker container. 
BK dockerforktest    # Try out your forked changes inside a Docker container.
```

---

## Troubleshooting

If you already have an existing installation, you'll see the message:

```
Existing installation found
```

---

## Modules

- `install.sh` – Install the script
- `chat` – Online AI chatbot
- `BK.sh` – Main script handling commands
- `configuration.conf` – Stores user-defined settings
- `Debug.sh` – Implements script debugging
- `log.sh` – Script-specific logging functionality
- `Nginx.sh` – Check for Nginx error logs
- `db.sh` – Manage database-related tasks
- `help.txt` – Help documentation
- `autoCompletion.sh` – Shell auto-completion
- `IP.sh` – IP management modules
- `Wordpress.sh` – WordPress-related tasks
- `Database.sh` – Deep database tasks
- `Cpanel.sh` – cPanel verification and modules

---

## ⚠️ Autocompletion Issue

We've noticed that **autocompletion isn't working as expected everytime** for all shells when opening a new shell. If it automatically doesn't work for new bash shells, please try sourcing the autocompletion file. 

```bash
source /opt/AdminAssist/autoCompletion.sh
```

### 🤔 Possible Causes

- The completion script might not be in the correct location.
- The shell might not be loading it at startup.
- There could be an issue with how Bash is handling autocompletion.

## ⚠️ Logging issue

I was able to see that **Even though the script works, the scripts might produce some logs or error messages while running without installing first**. 

### 🛠 What's Happening?

- This is because the necessary log files has not been generated yet.


### 🔍 Need Help!

If you have any ideas, feel free to **open an issue** or **submit a pull request**! 🚀

---

## Contributing

We welcome contributions! Fork, make changes, and submit a pull request.

💬 This project is open-source and free to use under the MIT license. Feel free to fork, improve, or use it in your own tools!

---

### 💬 From the Creator

> I tried to polish this project for too long, thinking it had to be “perfect” before I shared it. But perfection isn’t how we grow — collaboration is.
>
> I’m still learning, and this project is far from complete. If it helps you, great! If you have ideas or feedback, even better.
>
> Thanks for checking out AdminAssist — and thanks for supporting creators who are still figuring it out. 🙌
