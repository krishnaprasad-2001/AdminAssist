# AdminAssist

## Overview

AdminAssist is a powerful tool designed to assist server administrators and support technicians in troubleshooting WordPress installations and general server-related issues. Whether you're diagnosing a misconfigured website, fixing database errors, or analyzing server logs, AdminAssist provides quick and efficient solutions to streamline your workflow.

## Why AdminAssist?

- ✅ Best for WordPress Troubleshooting – Easily detect WordPress installations, check database connectivity, list installed themes, and fix common issues.
- ✅ Automated Setup – A simple installation script sets up everything in `/opt/AdminAssist`.
- ✅ Modular Design – Tasks are divided into separate scripts for better organization (e.g., `db.sh` for database management, `wp.sh` for WordPress-related tasks).
- ✅ System Integration – The installer creates a shortcut (`BK`) for easy execution from anywhere.

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

### Enable Auto-Completion (Optional)

To enable tab completion, run:

```bash
source /opt/AdminAssist/autoCompletion.sh
```

---

## Usage

Once installed, you can use AdminAssist through the `BK` command:

```bash
BK deb              # Check debug mode  
BK tdeb             # Toggle debug mode  
BK db               # Get database details  
BK upgrade          # Upgrade the WordPress installation  
BK theme            # List installed WordPress themes  
BK fix_db           # Fix database connectivity errors  
BK nginx            # View nginx error logs
BK apache           # View Apache error logs
BK add_custom_rule  # Assist in adding nginx custom Rule  
BK ipcheck          # Check if an IP is public or private
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

We've noticed that **autocompletion isn't working as expected** for all shelss when opening a new shell. If it automatically doesn't work for new bash shells, please try sourcing the autocompletion file.

```bash
source /opt/AdminAssist/autoCompletion.sh
```

### 🛠 What's Happening?

- The completion script **exists** but doesn't load automatically for all shells.
- It **only works when sourced manually**.

### 🤔 Possible Causes

- The completion script might not be in the correct location.
- The shell might not be loading it at startup.
- There could be an issue with how Bash is handling autocompletion.

### 🔍 Need Help!

If you have any ideas, feel free to **open an issue** or **submit a pull request**! 🚀

---

## Contributing

We welcome contributions! Fork, make changes, and submit a pull request.
