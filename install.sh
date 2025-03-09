#!/bin/bash
BASE_DIR=$(dirname "$(realpath "$0")")
source "$BASE_DIR/configuration.conf"
source "$BASE_DIR/fun.sh"
E_EXISTING_INSTALLATION_FOUND=1;

if [ -e /opt/AdminAssist ]; then
    print_doggy
    echo "Existing installation found"
    echo "If you want to upgrade the script, please run BK.sh upgrade"
    echo "Or if you want to remove the existing installation, run BK.sh uninstall"
    exit $E_EXISTING_INSTALLATION_FOUND
else
    mkdir -p /opt/AdminAssist
    print_doggy
    echo "Copying files..."
    cp -r "$(dirname "$(realpath "$0")")"/* /opt/AdminAssist
    echo "Creating shortcuts..."
    mkdir -p /var/log/AdminAssist
    ln -s /opt/AdminAssist/BK.sh /usr/bin/BK &>> $ERROR_LOG
    echo -e "Execute \e[34m source /opt/AdminAssist/autoCompletion.sh \e[0m to enable tab completion"
    echo "source /opt/AdminAssist/autoCompletion.sh" >> ~/.bashrc
    # bash --rcfile <(cat ~/.bashrc; echo "source /opt/AdminAssist/autoCompletion.sh")
    exec bash
fi
