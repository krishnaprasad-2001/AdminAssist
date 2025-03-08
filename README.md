# AdminAssist

## Overview

AdminAssist is a powerful tool designed to assist server administrators and support technicians in troubleshooting WordPress installations and general server-related issues. Whether you're diagnosing a misconfigured website, fixing database errors, or analyzing server logs, AdminAssist provides quick and efficient solutions to streamline your workflow.

## Why AdminAssist?
- ✅ Best for WordPress Troubleshooting – Easily detect WordPress installations, check database connectivity, list installed themes, and fix common issues.
- ✅ Automated Setup – A simple installation script sets up everything in /opt/AdminAssist.
- ✅ Modular Design – Tasks are divided into separate scripts for better organization (e.g., db.sh for database management, wp.sh for WordPress-related tasks).
- ✅ System Integration – The installer creates a shortcut (BK) for easy execution from anywhere.

## Getting Started

* Clone the repository:
  git clone https://github.com/krishnaprasad-2001/AdminAssist.git
  cd AdminAssist

* Run the Installer
  chmod +x install.sh  
  ./install.sh

* Enable Auto-Completion (Optional)
  To enable tab completion, run:
  source /opt/AdminAssist/autoCompletion.sh

## Usage
Once installed, you can use AdminAssist through the BK command:
- BK deb         # Check debug mode  
- BK tdeb        # Toggle debug mode  
- BK db          # Get database details  
- BK upgrade     # Upgrade the WordPress installation  
- BK theme       # List installed WordPress themes  
- BK fix_db      # Fix database connectivity errors  
- BK apache      # View Apache error logs

## Troubleshooting
If you already have an existing installation, you'll see the message:
Existing installation found  

## Modules
- BK.sh – Main script handling commands.
- db.sh – Manages database-related tasks.
- help.txt – Stores help documentation.
- autoCompletion.sh – Provides shell auto-completion.
- configuration.conf – Stores user-defined settings.

## Contributing
We welcome contributions! Fork, make changes, and submit a pull request.
