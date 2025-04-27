#!/bin/bash
BASE_DIR=$(dirname "$(realpath "$0")")
# source "$BASE_DIR/configuration.conf"
source "$BASE_DIR/fun.sh"
E_EXISTING_INSTALLATION_FOUND=1;
declare -A conf

# Get the configuration values from configuration.conf file.
set_configuration(){
	while IFS="=" read -r key value
	do
		# To ensure that the lines that start with the "#" are not included in the file.
		if [[ -z "$key" || "$key" =~ ^# ]]; then
			continue
		fi
		conf[$key]=$value
	done < $BASE_DIR/configuration.conf
	if [ ! -w "$ERROR_LOG" ]; then
		conf[ERROR_LOG]="$ASH/ERROR_LOG"
	fi
}

install(){
	if [[ $install_prefix ]]; then
		echo "Install prefix is $install_prefix"
		# Check if the client specifies an absolute path
		if [[ $install_prefix == /* ]]; then
			# If it's an absolute path, use it for installation
			ASH=$install_prefix/AdminAssist
		else
			echo "Prefix not an absolute path, defaultint to ~/.AdminAssist"
			# If it's a relative path, use the default location
			ASH=~/.AdminAssist
		fi
	else
		# If no install_prefix is specified, use the default location
		echo "installing in default $ASH"
		ASH=~/.AdminAssist
	fi
	if [[ ! $ASH_REPOSITORY ]]; then
		# The project repository 
		ASH_REPOSITORY=https://github.com/krishnaprasad-2001/AdminAssist
	fi
	set -e
	if [[ -d $ASH ]]; then
		echo $ASH
		printf '%s\n' "${YELLOW}You already have Oh My Bash installed.${NORMAL}" >&2
		print_doggy
		printf '%s\n' "You'll need to remove '$ASH' if you want to re-install it." >&2
		return 1
	fi
	umask g-w,o-w
	printf '%s\n' "${BLUE}Cloning Admin Assist...${NORMAL}"
	type -P git &>/dev/null || {
		echo "Error: git is not installed"
			return 1
		}
	execute_command git clone --depth=1 -q "$ASH_REPOSITORY" "$ASH" >/dev/null || {
		printf "Error: git clone of AdminAssist repo failed\n"
			return 1
		}
	set_configuration
	touch ${conf[ERROR_LOG]}
	if [[ -t 0 ]]; then
		# If running interactively, prompt user
		read -p "Do you want to change this? (y/n): " choice
		if [[ "$choice" =~ ^(y|Y|yes|YES)$ ]]; then 
			vim +'call search("^custom_log_dir=") | normal $' "$BASE_DIR/configuration.conf"
		fi
	else
		# Non-interactive mode, skip the prompt
		echo "Running non-interactively, skipping user prompt."
	fi

	execute_command ln -s $ASH/BK.sh /usr/bin/BK &>> ${conf[ERROR_LOG]}
	print_doggy
	execute_command echo -e "Execute \e[34m source /opt/AdminAssist/autoCompletion.sh \e[0m to enable tab completion"
	execute_command echo "source $ASH/autoCompletion.sh" >> ~/.bashrc
	# execute_command # bash --rcfile <(cat ~/.bashrc; echo "source /opt/AdminAssist/autoCompletion.sh")
	execute_command exec bash
}

function read_arguments {
	install_opts=
	install_prefix=
	while (($#)); do
		local arg=$1; shift
		if [[ :$install_opts: != *:literal:* ]]; then
			case $arg in
				--prefix=*)
					arg=${arg#*=}
					if [[ $arg ]]; then
						install_prefix=$arg
					else
						install_opts+=:error
						printf 'install (AdminAssist): %s\n' "$RED$BOLD[Error]$NORMAL ${RED}the option argument for '--prefix' is empty.$NORMAL" >&2
					fi
					continue ;;
				--prefix)
					if (($#)); then
						install_prefix=$1; shift
					else
						install_opts+=:error
						printf 'install (AdminAssist): %s\n' "$RED$BOLD[Error]$NORMAL ${RED}an option argument for '$arg' is missing.$NORMAL" >&2
					fi
					continue ;;
				--help | --usage | --unattended | --dry-run)
					install_opts+=:${arg#--}
					continue ;;
				--version | -v)
					install_opts+=:version
					continue ;;
				--)
					install_opts+=:literal
					continue ;;
				-*)
					install_opts+=:error
					if [[ $arg == -[!-]?* ]]; then
						printf 'install (AdminAssist): %s\n' "$RED$BOLD[Error]$NORMAL ${RED}unrecognized options '$arg'.$NORMAL" >&2
					else
						printf 'install (AdminAssist): %s\n' "$RED$BOLD[Error]$NORMAL ${RED}unrecognized option '$arg'.$NORMAL" >&2
					fi
					continue ;;
			esac
		fi

		install_opts+=:error
		printf 'install (AdminAssist): %s\n' "$RED$BOLD[Error]$NORMAL unrecognized argument '$arg'." >&2
	done
}

function execute_command {
	if [[ :$install_opts: == *:dry-run:* ]]; then
		printf '%s\n' "$BOLD$GREEN[dryrun]$NORMAL $BOLD$*$NORMAL" >&5
	else
		printf '%s\n' "$BOLD\$ $*$NORMAL" >&5
		command "$@"
	fi
}

function install_main {
	local ncolors=
	if type -P tput &>/dev/null; then
		ncolors=$(tput colors 2>/dev/null || tput Co 2>/dev/null || echo -1)
	fi
	local RED GREEN YELLOW BLUE BOLD NORMAL
	if [[ -t 1 && $ncolors && $ncolors -ge 8 ]]; then
		RED=$(tput setaf 1 2>/dev/null || tput AF 1 2>/dev/null)
		GREEN=$(tput setaf 2 2>/dev/null || tput AF 2 2>/dev/null)
		YELLOW=$(tput setaf 3 2>/dev/null || tput AF 3 2>/dev/null)
		BLUE=$(tput setaf 4 2>/dev/null || tput AF 4 2>/dev/null)
		BOLD=$(tput bold 2>/dev/null || tput md 2>/dev/null)
		NORMAL=$(tput sgr0 2>/dev/null || tput me 2>/dev/null)
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		NORMAL=""
	fi

	local install_opts install_prefix
	read_arguments "$@"
	if [[ :$install_opts: == *:error:* ]]; then
		printf '\n'
		install_opts+=:usage
	fi
	if [[ :$install_opts: == *:help:* ]]; then
		# print_help
		install_opts+=:exit
	else
		if [[ :$install_opts: == *:version:* ]]; then
			install_opts+=:exit
		fi
		if [[ :$install_opts: == *:usage:* ]]; then
			install_opts+=:exit
		fi
	fi
	if [[ :$install_opts: == *:error:* ]]; then
		return 2
	elif [[ :$install_opts: == *:exit:* ]]; then
		return 0
	fi
	install
}
install_main "$@" 5>&2
