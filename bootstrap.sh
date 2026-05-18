#!/usr/bin/env bash
# =============================================================================
#  setup_menu.sh — Interactive TUI for running setup functions
#  Arrow keys + Space to toggle, Enter to run selected, q to quit
# =============================================================================

source $HOME/.scripts/_functions.sh

#& ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#&  Script variables and functions

#? info|success|warn|error "Message to print."
info()    { echo -e "${BLUE}[INFO]${NC}  $*\n"; }
success() { echo -e "${GREEN}[OK]${NC}    $*\n"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*\n"; }
error()   { echo -e "${RED}[ERROR]${NC} $*\n" >&2; }

#? Prints a banner message.
banner ()
{
	local MESSAGE="$1"
	print_double_line
	echo -e "${GREEN}$MESSAGE${NC}"
	print_double_line
}

#? Print a single (80 char) line of dashes for visual separation in output.
print_line(){ echo -e "${GREEN}--------------------------------------------------------------------------------${NC}\n" ; }

#? Print a single (80 char) line of equal signs for visual separation in output.
print_double_line(){ echo -e "${BLUE}================================================================================${NC}\n" ; }

return_to_menu ()
{
	echo -e "${YELLOW}" && read -rp "Press Enter to return to the main menu or Ctrl+C to exit:" && echo -e "${NC}"
	main
}

#? ── Colors & styles ─────────────────────────────────────────────────────────
# Use $'...' so variables hold actual ESC bytes, not literal backslash sequences.
# This is required for printf "%s" to emit color (echo -e also works either way).
RED=$'\033[0;31m';  GREEN=$'\033[0;32m';  YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'; CYAN=$'\033[0;36m';   NC=$'\033[0m'
BOLD=$'\033[1m';    DIM=$'\033[2m';        RESET=$'\033[0m'
BG_SEL=$'\033[48;5;236m'; FG_SEL=$'\033[1;97m'
CHECK_ON="${GREEN}[✓]${RESET}"; CHECK_OFF="${DIM}[ ]${RESET}"

#? ── Menu items: "Label|function_name" ────────────────────────────────────────
declare -a ITEMS=(
	"Update this script|update_bootstrap_script"
	"Update all|update_all"
	"Create new ssh key|make_ssh_key"
	"Create new user|create_user"
	"Create important files and dirs|create_files_and_dirs"
	"Install base apps from apt|install_base_apps_apt"
	"Install zsh|install_zsh"
	"Install brew|install_brew"
	"Install cargo|install_cargo"
	"Install docker|install_docker"
	"Install nerd fonts|install_nerdfonts"
	"Install atuin|install_atuin"
	"Install starship|install_starship"
	"Install chezmoi|install_chezmoi"
  	"- Init chezmoi (SSH)|init_chezmoi_ssh"
	"- Init chezmoi (Token)|init_chezmoi_token"
)

#? ── Track selected state (0=off, 1=on) ───────────────────────────────────────
declare -a SELECTED
for i in "${!ITEMS[@]}"; do SELECTED[$i]=0; done

CURSOR=0
COUNT=${#ITEMS[@]}

#? ── Stub functions (replace with your real implementations) ──────────────────
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	updates
update_all ()
{
	local BANNER_TITLE="Updating the system"
	local BANNER_EXIT="System update script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")\n${RED}Please reboot your system as soon as possible to ensure all changes have been applied.${NC}"

	banner "$BANNER_TITLE"

	info "Updating the system."

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Checking OS..."
	if [[ "$(uname -s)" == "Darwin" ]]; then
		info "Detected macOS."
		if -f /home/linuxbrew/.linuxbrew/bin/brew &>/dev/null; then
			print_line && info "brew package manager detected. Running brew update and upgrade."
			info "Running brew update..."
			brew update -q  && \
			success "Successfully updated brew" || error "Failed to update brew"
			info "Running brew upgrade..."
			brew upgrade -q  && \
			success "Successfully upgraded brew" || error "Failed to upgrade brew"
		fi
	elif [[ "$(uname -s)" == "Linux" ]]; then
		info "Detected Linux."
		print_line && info "Running apt update and upgrade."
		info "Running apt update...\n"
		sudo apt-get update -y -q --fix-missing && \
		success "Successfully updated system" || error "Failed to update system"
		info "Running apt upgrade...\n"
		sudo apt-get upgrade -y -q --fix-missing --auto-remove --purge && \
		success "Successfully upgraded system" || error "Failed to upgrade system"
		print_line && info "Since we are here making sure curl and wget are installed."
		sudo apt install curl wget -qq -y  && \
		success "curl and wget installed successfully" || error "Failed to install curl and wget"
		if -f /home/linuxbrew/.linuxbrew/bin/brew &>/dev/null; then
			print_line && info "brew package manager detected. Running brew update and upgrade as well."
			info "Running brew update."
			brew update -q  && \
			success "Successfully updated brew" || error "Failed to update brew"
			info "Running brew upgrade."
			brew upgrade -q  && \
			success "Successfully upgraded brew" || error "Failed to upgrade brew"
		fi
	fi

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	return_to_menu
}
#?	update bootstrap script
update_bootstrap_script ()
{
	local BANNER_TITLE="Updating the bootstrap script"
	local BANNER_EXIT="Bootstrap script update finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"
	local URL_SRC="https://raw.githubusercontent.com/ency98/pub/refs/heads/main/bootstrap.sh"
	local DEST="/tmp/bootstrap.sh"

	banner "$BANNER_TITLE"

	info "Updating this script."

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line &&
	info "Cleaning up old files and making sure the correct directories exist."
	cd "$HOME" && mkdir -p "$HOME/.scripts"
	rm -f "$HOME/.scripts/bootstrap.sh" "$DEST"
	print_line
	info "Downloading updated bootstrap script from:\n${YELLOW}$URL_SRC${NC}"
	wget -O "$DEST" "$URL_SRC"  && \
	success "\nSuccessfully downloaded bootstrap script" || error "\nFailed to download bootstrap script" && exit 0

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Updating bootstrap script..."
	mkdir -p ~/.scripts
	chmod +x "$DEST"  && \
	success "\nSuccessfully updated bootstrap script permissions" || error "\nFailed to update bootstrap script permissions"
	mv -v "$DEST" "$HOME/.scripts/bootstrap.sh"  && \
	success "\nSuccessfully updated bootstrap script file."  || error "\nFailed to update bootstrap script file."

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	unset URL_SRC
	unset DEST
	exit 0

}
#?	apt install: base applications
install_base_apps_apt() #* Install base applications from a list of packages stored in a remote file
{
	local BANNER_TITLE="Installing base apps from apt"
	local BANNER_EXIT="Base apps installation script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"
	local PACKAGE_LIST_URL="${PKG_LIST:-https://raw.githubusercontent.com/ency98/pub/refs/heads/main/base-packages}"
	local PACKAGE_LIST="/tmp/base-packages"
    local failed_packages=()

	banner "$BANNER_TITLE"

	info "Install base applications from a list of packages stored in a remote file"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Downloading updated base packages list..."
    wget -O "$PACKAGE_LIST" "$PACKAGE_LIST_URL"
    if [ $? -ne 0 ]; then
        error "Failed to download base packages list from $PACKAGE_LIST_URL"
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		unset PACKAGE_LIST_URL
		unset PACKAGE_LIST
		unset failed_packages
		return_to_menu
    else
		success "Successfully downloaded base packages list from $PACKAGE_LIST_URL"
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

    print_line && info "Installing packages from list..."
    echo -e "\n\n${YELLOW}$(column < "$PACKAGE_LIST")${NC}\n" && print_line

    while IFS= read -r package || [[ -n "$package" ]]; do
        # Skip empty lines and comments
        [[ -z "$package" || "$package" == \#* ]] && continue
        info "Installing: $package"
        sudo apt-get install -y -qq "$package"
        if [ $? -ne 0 ]; then
            error "Failed to install: $package"
            failed_packages+=("$package")
			print_line && echo
        else
            success "Installed: $package"
			print_line && echo
        fi
    done < "$PACKAGE_LIST"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

    # Summary
    print_line && info "Summary..."
    if [ ${#failed_packages[@]} -eq 0 ]; then
        success "All packages installed successfully."
    else
        warn "The following packages failed to install:"
        for pkg in "${failed_packages[@]}"; do
            error "  - $pkg"
        done
    fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

    print_line && info "Cleaning up temp files..."
    rm -f "$PACKAGE_LIST" && \
    success "Removed temporary package list" || warn "Could not remove temporary package list"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	unset PACKAGE_LIST_URL
	unset PACKAGE_LIST
    unset failed_packages
	return_to_menu
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	install brew
install_brew ()
{
	local BANNER_TITLE="Installing Homebrew/Linuxbrew Package Manager"
	local BANNER_EXIT="Brew install script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"
	local REQUIRED_PACKAGES=(
		"curl"
		"git"
		"build-essential"
	"gcc")

	banner "$BANNER_TITLE"

	info "Starting installation of brew."

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Checking if brew is already installed."
	if -f /home/linuxbrew/.linuxbrew/bin/brew &>/dev/null; then
		success "brew is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		unset REQUIRED_PACKAGES
		return_to_menu
	else
		warn "brew is not installed."
		info "Continuing with installation..."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Installing required packages..."
	for PACKAGE in "${REQUIRED_PACKAGES[@]}"; do
		if ! command -v "$PACKAGE" &>/dev/null; then
			warn "Package $PACKAGE not found. Installing $PACKAGE."
			sudo apt update -qq -y &>/dev/null
			sudo apt install -qq -y "$PACKAGE" &>/dev/null
			success "Package $PACKAGE installed successfully."
		else
			success "Package $PACKAGE is already installed."
		fi
	done

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Downloading install script..."
	if ! command -v "curl" &>/dev/null; then
		warn "curl not found. Downloading install script with wget instead of curl."
		print_line && info "Running install script..."
		/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	else
		print_line && info "Running install script..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	if -f /home/linuxbrew/.linuxbrew/bin/brew &>/dev/null; then
		print_line && success "brew installed successfully."
		if [[ "$(uname -s)" == "Darwin" ]]; then
			info "Sourcing brew environment variables for macOS..."
			eval $(/opt/homebrew/bin/brew shellenv)
			FPATH="$(brew --prefix)/share/zsh-completions":"$FPATH"
		elif [[ "$(uname -s)" == "Linux" ]]; then
			info "Sourcing brew environment variables for Linux..."
			eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		fi
		print_line && info "Installing curl with brew."
		brew install curl &>/dev/null
	else
		print_line && error "brew installation failed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return_to_menu
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	return_to_menu
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	install cargo
install_cargo ()
{
	local BANNER_TITLE="Installing Cargo Package Manager"
	local BANNER_EXIT="Cargo install script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"
	local REQUIRED_PACKAGES=(
		"curl"
		"git"
		"build-essential"
	"gcc")

	banner "$BANNER_TITLE"

	info "Starting installation of cargo."

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line
	info "Checking if cargo is already installed."
	if command -v "cargo" &>/dev/null; then
		success "cargo is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		unset REQUIRED_PACKAGES
		return_to_menu
	else
		warn "cargo is not installed."
		info "Continuing with installation..."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line
	if ! command -v "curl" &>/dev/null; then
		warn "curl not found. Downloading cargo install script with wget instead of curl."
		print_line
		info "Downloading install script for: Cargo..."
		wget https://sh.rustup.rs -qO- | sh
		print_line
		info "Running install script for: Cargo B(inary)Install..."
		wget -qO- https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
	else
		print_line
		info "Running install script for: Cargo..."
		curl https://sh.rustup.rs -sSf | sh
		print_line
		info "Running install script for: Cargo B(inary)Install..."
		curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	if [ -f "$HOME/.cargo/env" ]; then
		. "$HOME/.cargo/env";
	fi
	if command -v "cargo" &>/dev/null; then
		print_line && success "cargo installed successfully."
	else
		print_line && error "cargo installation failed."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	return_to_menu
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	install zsh
install_zsh ()
{
	local BANNER_TITLE="Installing zsh shell"
	local BANNER_EXIT="zsh install script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"

	banner "$BANNER_TITLE"

	info "Installing zsh"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line
	info "Checking if zsh is already installed."
	if command -v "zsh" &>/dev/null; then
		success "zsh is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return_to_menu
	else
		warn "zsh is not installed."
		info "Continuing with installation..."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line
	info "Installing zsh..."
	sudo apt install -qq -y "zsh" &>/dev/null

	if command -v "zsh" &>/dev/null; then
		print_line
		success "zsh installed successfully."

		print_line
		info "Setting zsh as the default shell for the current user."
		info "USER: $USER"
		chsh -s $(which zsh) "$USER"
	else
		print_line
		error "zsh installation failed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return_to_menu
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line
	echo -e "${GREEN}You can get a list of available prompts by using ${CYAN}prompt -l${GREEN}. To enable a prompt,
	for example ${CYAN}adam1, simply type ${CYAN}prompt adam1. The list as of version 5.0.0 of zsh is:
	${CYAN}adam1${GREEN},${CYAN} adam2,${CYAN} bart,${CYAN} bigfade,${CYAN} clint,${CYAN} elite2,${CYAN} elite,${CYAN} fade,${CYAN} fire,${CYAN} off,${CYAN} oliver,${CYAN} pws,${CYAN} redhat,${CYAN} suse,${CYAN} walters,${CYAN} zefram${GREEN}.
	You can also get a preview of the prompts using the command ${CYAN}prompt -p${GREEN}.${NC}\n"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	return_to_menu
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	install docker
install_docker ()
{
	local BANNER_TITLE="Installing Docker"
	local BANNER_EXIT="Docker install script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"
	local DKR_GRP=(
	"$USER"
	"bwilsonadmin"
	"ladmin"
	"admwilsonb")

	banner "$BANNER_TITLE"

	info "Installing Docker"


	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line
	info "Checking if Docker is already installed."
	if command -v "docker" &>/dev/null; then
		success "Docker is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return_to_menu
	else
		warn "Docker is not installed."
		info "Continuing with installation..."
	fi


	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line
	info "Running install script..."
	if ! command -v "curl" &>/dev/null; then
		warn "curl not found. Downloading Docker install script with wget instead of curl."
		print_line
		info "Running install script for: Docker..."
		wget https://get.docker.com -qO- | sh
	else
		print_line
		info "Running install script for: Docker..."
		curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
		sh /tmp/get-docker.sh
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Checking if Docker is installed."
	if command -v "docker" &>/dev/null; then
		print_line && success "Docker installed successfully."
	else
		print_line && error "Docker installation failed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return_to_menu
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Adding users to docker group"
	for user in "${DKR_GRP[@]}"; do
		if id "$user" &>/dev/null; then
			info "Adding ${user} to docker group"
			if ! sudo usermod -aG docker "${user}"; then
				error "Failed to add user ${user} to docker group."
			else
				success "User ${user} added to docker group successfully."
			fi
		else
			warn "User ${user} not found. Skipping adding to docker group."
		fi
	done


	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Creating and setting permissions for the usual docker data directory..."
	warn "Setting permissions on /mnt to 777 and owner to root:100"
	sudo chmod 777 -R /mnt && sudo chown root:100 /mnt


	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Creating docker data directory: ${YELLOW}/mnt/docker${NC}"
	mkdir -p /mnt/docker


	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Exporting DOCKER_APPDATA_DIR environment variable: ${YELLOW}DOCKER_APPDATA_DIR=/mnt/docker${NC}"
	if [ ! -f "$HOME/.profile" ]; then
		touch "$HOME/.profile"
	fi
	if ! grep -q "DOCKER_APPDATA_DIR=/mnt/docker" "$HOME/.profile"; then
			echo "DOCKER_APPDATA_DIR=/mnt/docker" | sudo tee -a "$HOME/.profile" &>/dev/null
	fi

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	unset DKR_GRP
	return_to_menu
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	install nerdfonts
install_nerdfonts()
{
	local BANNER_TITLE="Installing nerd fonts from brew"
	local BANNER_EXIT="Nerd fonts install script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"

	banner "$BANNER_TITLE"

	info "Starting install of nerd fonts."

	version='v3.4.0'
	fonts_dir="${HOME}/.local/share/fonts"

	declare -a fonts=(
		CascadiaMono
		CascadiaCode
		FiraCode
		FiraMono
		Hack
		NerdFontsSymbolsOnly
		SourceCodePro
		SpaceMono
		Ubuntu
		UbuntuMono
	)


	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Checking OS..."
	if [[ "$(uname -s)" == "Darwin" ]]; then
		error "Nerdfonts install is only supported on Linux for now."
		info "Skipping nerd font installation."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return_to_menu
	elif [[ "$(uname -s)" == "Linux" ]]; then
		info "Detected OS: Linux"
		info "Continuing with installation..."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Fonts directory..."
	if [[ ! -d "$fonts_dir" ]]; then
		print_line && warn "Fonts directory not found."
		info "Creating fonts directory: $fonts_dir"
		mkdir -p "$fonts_dir"
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Installing fonts..."
	for font in "${fonts[@]}"; do
		print_line && info "Downloading $download_url"

		zip_file="${font}.zip"
		download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${zip_file}"
		wget "$download_url"

		info "Installing $font..."
		if [ -f "$HOME/.local/share/fonts/LICENSE" ]; then
			rm -f "$HOME/.local/share/fonts/LICENSE"
		fi
		if [ -f "$HOME/.local/share/fonts/README.md?" ]; then
		 	rm -f "$HOME/.local/share/fonts/README.md?"
		fi
		if [ -f "$HOME/.local/share/fonts/LICENCE.txt?" ]; then
		 	rm -f "$HOME/.local/share/fonts/LICENCE.txt?"
		fi
		unzip "$zip_file" -d "$fonts_dir"

		info "Cleaning up..."
		rm "$zip_file"
	done

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Removing Windows Compatible fonts..."
	find "$fonts_dir" -name '*Windows Compatible*' -delete

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Building font information caches in [dirs] $fonts_dir..."
	fc-cache -fv

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	unset version
	unset fonts_dir
	unset fonts
	unset zip_file
	unset download_url
	return_to_menu
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	install atuin
install_atuin ()
{
	local BANNER_TITLE="Installing atuin a shell history manager"
	local BANNER_EXIT="atuin install script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"

	banner "$BANNER_TITLE"

	info "Starting installation of atuin."

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Checking if atuin is already installed."
	if [ -d "$HOME/.atuin" ]; then
		success "atuin is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return_to_menu
	else
		warn "atuin is not installed."
		info "Continuing with installation..."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Downloading install script..."
	if ! command -v "curl" &>/dev/null; then
		warn "curl not found. Downloading starship install script with wget instead of curl."
		print_line && warn "Downloading script from:\n${YELLOW}https://setup.atuin.sh${NC}"
		info "Running install script for: starship..."
		wget https://setup.atuin.sh -qO- | sh
	else
		print_line && warn "Downloading script from:\n${YELLOW}https://setup.atuin.sh${NC}"
		info "Running install script."
		curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	if [ -d "$HOME/.atuin" ]; then
		print_line && success "atuin installed successfully."
	else
		print_line && error "atuin installation failed."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	return_to_menu
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	install starship
install_starship ()
{
	local BANNER_TITLE="Installing Starship Prompt"
	local BANNER_EXIT="Starship install script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"

	banner "$BANNER_TITLE"

	info "Installing the starship prompt"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Checking if starship is already installed."
	if command -v "starship" &>/dev/null; then
		success "starship is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return_to_menu
	else
		info "starship is not installed."
		info "Continuing with installation..."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Downloading install script..."
	if ! command -v "curl" &>/dev/null; then
		warn "curl not found. Downloading starship install script with wget instead of curl."
		print_line && warn "Downloading script from:\n${YELLOW}https://starship.rs/install.sh${NC}"
		info "Running install script for: starship..."
		wget https://starship.rs/install.sh -qO- | sh
	else
		print_line && warn "Downloading script from:\n${YELLOW}https://starship.rs/install.sh${NC}"
		info "Running install script for: starship..."
		curl -sS https://starship.rs/install.sh | sh
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	if command -v "starship" &>/dev/null; then
		print_line && success "starship prompt installed successfully."
		info "Configuring starship prompt with the preset $PRESET"
		starship preset gruvbox-rainbow -o ~/.config/starship.toml
	else
		print_line && error "starship prompt installation failed."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	return_to_menu
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	install chezmoi
install_chezmoi ()
{
	local BANNER_TITLE="Installing chezmoi dotfile manager"
	local BANNER_EXIT="chezmoi install script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"

	banner "$BANNER_TITLE"

	info "Starting installation of chezmoi."

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Checking if chezmoi is already installed."
	if command -v "chezmoi" &>/dev/null; then
		success "chezmoi is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return_to_menu
	else
		info "chezmoi is not installed."
		info "Continuing with installation..."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Downloading install script..."
	if ! command -v "curl" &>/dev/null; then
		warn "curl not found. Downloading starship install script with wget instead of curl."
	print_line && warn "Downloading Binary from:\n${YELLOW}get.chezmoi.io${NC}"
	info "Downloading chezmoi binary."
		sh -c "$(wget get.chezmoi.io -qO-)" -- -b $HOME/.local/bin
	else
	print_line && warn "Downloading Binary from:\n${YELLOW}get.chezmoi.io${NC}"
	info "Downloading chezmoi binary."
		sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Copying chezmoi binary to /usr/local/bin/chezmoi for system wide availability."
	sudo cp -v $HOME/.local/bin/chezmoi /usr/local/bin/chezmoi && \
	success "Copied chezmoi binary to /usr/local/bin/chezmoi successfully." || error "Failed to copy chezmoi binary to /usr/local/bin/chezmoi."

	if command -v "chezmoi" &>/dev/null; then
		print_line && success "chezmoi installed successfully."
	else
		print_line && error "chezmoi installation failed."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	main
}
#?	init chezmoi - TOKEN
init_chezmoi_token ()
{
	local BANNER_TITLE="Initializing chezmoi to update and manage local dot files"
	local BANNER_EXIT="chezmoi initialization finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"
	local GIT_USERNAME=""
	local GIT_EMAIL=""
	local GIT_TOKEN=""

	banner "$BANNER_TITLE"

	info "${YELLOW}Configuring chezmoi for ${RED}ssh key${YELLOW} auth...${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
	#! GIT EMAIL
	print_line && echo -e "${RED}"
	read -rp "Please enter your GitHub email: " GIT_EMAIL && echo -e "${NC}"
	info "GitHub email entered: ${YELLOW}$GIT_EMAIL${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
	#! GIT USERNAME
	print_line && echo -e "${RED}"
	read -rp "Please enter your GitHub username: " GIT_USERNAME && echo -e "${NC}"
	info "GitHub username entered: ${YELLOW}$GIT_USERNAME${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
	#! GIT TOKEN
	print_line && echo -e "${RED}"
	read -rp "Please enter your GitHub token: " GIT_TOKEN && echo -e "${NC}"
	info "GitHub token entered: ${YELLOW}$GIT_TOKEN${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && echo ""
	info "Git Username set to: ${YELLOW}$GIT_USERNAME${NC}"
	info "Git email set to: ${YELLOW}$GIT_EMAIL${NC}"
	info "Git token set to: ${YELLOW}$GIT_TOKEN${NC}"
	info "Git repository set to: ${YELLOW}github.com/$GIT_USERNAME/dotfiles.git${NC}"
	info "Initializing chezmoi with remote repository: ${YELLOW}https://github.com/$GIT_USERNAME/dotfiles.git${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && echo -e "${YELLOW}"
	read -rp "Please check the information above. Press Enter to continue or Ctrl+C to abort: "
	echo -e "${NC}$(print_line)\n"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Checking if chezmoi is already installed."
	if command -v "chezmoi" &>/dev/null; then
		success "chezmoi is already installed."
		info "Continuing with initialization..."
	else
		warn "chezmoi is not installed."
		info "Please install chezmoi and re-run this script to initialize chezmoi with your dotfiles repository."

		banner "$BANNER_EXIT - ERROR: chezmoi not installed."
		unset BANNER_TITLE
		unset BANNER_EXIT
		unset GIT_USERNAME
		unset GIT_EMAIL
		unset GIT_TOKEN
		return_to_menu
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && warn "Purging local config just in case there are any conflicts with the remote repository."
	chezmoi purge --force -v

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Initializing chezmoi with remote repository: https://github.com/$GIT_USERNAME/dotfiles.git"
	chezmoi init "https://$GIT_TOKEN@github.com/$GIT_USERNAME/dotfiles.git"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && warn "Applying chezmoi configuration to the local system. This will overwrite any existing local dotfiles with the remote repository."
	echo -e "${RED}"
	read -n 1 -s -r -p "Press any key to continue with overwriting the local dotfiles. Press ctrl+c to abort..."
	echo -e "${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line info "Applying chezmoi configuration to the local system."
	chezmoi -v apply
	if [ $? -ne 0 ]; then
		#& "if" Failed...
		ERROR=$?
		print_line && error "Error applying chezmoi configuration."
	else
		ERROR=$?
		#& "if" Success...
		print_line && info "chezmoi successfully applied configuration."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	unset GIT_USERNAME
	unset GIT_EMAIL
	unset GIT_TOKEN
	return $ERROR
}
#?	init chezmoi - SSH
init_chezmoi_ssh ()
{
	local BANNER_TITLE="Initializing chezmoi to update and manage local dot files"
	local BANNER_EXIT="chezmoi initialization finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"
	local GIT_USERNAME=""
	local GIT_EMAIL=""

	banner "$BANNER_TITLE"

	info "${YELLOW}Configuring chezmoi for ${RED}ssh key${YELLOW} auth...${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
	#! GIT EMAIL
	print_line && echo -e "${RED}"
	read -rp "Please enter your GitHub email: " GIT_EMAIL && echo -e "${NC}"
	info "GitHub email entered: ${YELLOW}$GIT_EMAIL${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
	#! GIT USERNAME
	print_line && echo -e "${RED}"
	read -rp "Please enter your GitHub username: " GIT_USERNAME && echo -e "${NC}"
	info "GitHub username entered: ${YELLOW}$GIT_USERNAME${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && echo ""
	info "Git Username set to: ${YELLOW}$GIT_USERNAME${NC}"
	info "Git email set to: ${YELLOW}$GIT_EMAIL${NC}"
	info "Git repository set to: ${YELLOW}github.com/$GIT_USERNAME/dotfiles.git${NC}"
	info "Initializing chezmoi with remote repository: ${YELLOW}git@github.com/$GIT_USERNAME/dotfiles.git${NC}"
	print_line && echo ""

	warn "${RED}Using the default ssh key. If this is not correct, please create an entry in your ssh config with the correct key.${NC}"
	warn "${RED}EXAMPLE: ${YELLOW}IdentityFile ~/.ssh/github/id_ed25519${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && echo -e "${YELLOW}"
	read -rp "Please check the information above. Press Enter to continue or Ctrl+C to abort: "
	echo -e "${NC}$(print_line)\n"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Checking if chezmoi is already installed."
	if command -v "chezmoi" &>/dev/null; then
		success "chezmoi is already installed."
		info "Continuing with initialization..."
	else
		warn "chezmoi is not installed."
		info "Please install chezmoi and re-run this script to initialize chezmoi with your dotfiles repository."

		banner "$BANNER_EXIT - ERROR: chezmoi not installed."
		unset BANNER_TITLE
		unset BANNER_EXIT
		unset GIT_USERNAME
		unset GIT_EMAIL
		unset GIT_TOKEN
		unset GIT_REPO
		unset DOTFILES_REPO
		return_to_menu
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && warn "Purging local config just in case there are any conflicts with the remote repository."
	chezmoi purge --force -v

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Initializing chezmoi with remote repository: git@github.com/$GIT_USERNAME/dotfiles.git"
	chezmoi init "git@github.com/$GIT_USERNAME/dotfiles.git"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && warn "Applying chezmoi configuration to the local system. This will overwrite any existing local dotfiles with the remote repository."
	echo -e "${RED}"
	read -n 1 -s -r -p "Press any key to continue with overwriting the local dotfiles. Press ctrl+c to abort..."
	echo -e "${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line info "Applying chezmoi configuration to the local system."
	chezmoi -v apply
	if [ $? -ne 0 ]; then
		#& "if" Failed...
		ERROR=$?
		print_line && error "Error applying chezmoi configuration."
	else
		ERROR=$?
		#& "if" Success...
		print_line && info "chezmoi successfully applied configuration."
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	unset GIT_USERNAME
	unset GIT_EMAIL
	unset GIT_TOKEN
	return $ERROR
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	create important files and directories
_helper_create_files_dirs_ch ()
{
	if [[ "$1" == ""$HOME/.ssh"" ]]; then
		info "Setting permissions for .ssh directory..."
		chmod 700 "$HOME/.ssh" && \
		success "Successfully set permissions for .ssh directory" || error "Failed to set permissions for .ssh directory"
	elif [[ "$1" == $HOME/.ssh/config.d ]]; then
		info "Setting permissions for config.d directory..."
		chmod 700 "$HOME/.ssh/config.d" && \
		success "Successfully set permissions for config.d directory" || error "Failed to set permissions for config.d directory"
	elif [[ "$1" == $HOME/.ssh/authorized_keys ]]; then
		info "Setting permissions for authorized_keys..."
		chmod 600 "$HOME/.ssh/authorized_keys" && \
		success "Successfully set permissions for authorized_keys" || error "Failed to set permissions for authorized_keys"
	elif [[ "$1" == "$HOME/.ssh/config" ]]; then
		info "Setting permissions for config file of $USER..."
		chmod 600 "$HOME/.ssh/config" && \
		success "Successfully set permissions for ssh config" || error "Failed to set permissions for ssh config."
	fi
}
_helper_create_files_dirs_create ()
{
    case "$1" in
		dir)
			if [ ! -d "$2" ]; then
				warn "Directory not found: ${YELLOW}$2${NC}"
				info "Creating directory: ${YELLOW}$2${NC}"
				mkdir -p "$2" && \
				success "Created directory: ${YELLOW}$2${NC}" || error "Failed to create directory: ${YELLOW}$2${NC}"
			else
				success "Directory already exists: ${YELLOW}$2${NC}"
			fi
        ;;
		file)
			if [ ! -f "$2" ]; then
				warn "File not found: ${YELLOW}$2${NC}"
				info "Creating file: ${YELLOW}$2${NC}"
				touch "$2" && \
				success "Created file: ${YELLOW}$2${NC}" || error "Failed to create file: ${YELLOW}$2${NC}"
			else
				success "File already exists: ${YELLOW}$2${NC}"
			fi
		;;
		*)
			error "Invalid type: $1. Use 'dir' or 'file'."
			return 1
		;;
	esac
}
create_files_dirs ()
{
	local BANNER_TITLE="Creating important files and directories"
	local BANNER_EXIT="File and directory creation finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"
	#? Add required directories here.
	USER_DIRECTORIES=(
		"$HOME/.local/bin"			#? User bin directory.
		"$HOME/.config" 			#? User config directory.
		"$HOME/.scripts" 			#? User scripts directory.
		"$HOME/.home" 				#? User dotfiles directory.
		"$HOME/.backup_configs" 	#? User backup configs directory.
		"$HOME/.ssh" 				#? User SSH directory.
		"$HOME/.ssh/config.d" 		#? User SSH config directory.
		"$HOME/workspace" 			#? User workspace directory.
	)

	#? Add required files here.
	USER_FILES=(
		"$HOME/.bash_aliases" 			#? Extra alias file
		"$HOME/.ssh/config" 			#? SSH config file
		"$HOME/.ssh/authorized_keys" 	#? SSH authorized keys file
	)

	banner "$BANNER_TITLE"

	info "Creating important files and directories."

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Creating directories...Ensuring directory exists."
	for dir in "${USER_DIRECTORIES[@]}"; do
		print_line && info "Checking if directory exists: $dir"
		_helper_create_files_dirs_create dir "$dir"
		_helper_create_files_dirs_ch "$dir"
		print_line
	done

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Creating files...Ensuring files exists."
	for file in "${USER_FILES[@]}"; do
		print_line && info "Checking if file exists: $file"
		_helper_create_files_dirs_create file "$file"
		_helper_create_files_dirs_ch "$file"
		print_line
	done

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	unset USER_DIRECTORIES
	unset USER_FILES
	main
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	create new user
create_user () #* Adding user and setting password
{
	local BANNER_TITLE="Creating new user"
	local BANNER_EXIT="Create new use script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"

	local NEW_USER=""
	local NEW_USER_PASS=""

	banner "$BANNER_TITLE"

	info "Gather info for new user..."


	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
	#! USERNAME
	print_line && info "Setting username for new user." && echo -e "${RED}"
	read -rp "Please enter new user username: " NEW_USER && echo -e "${NC}"
	if [ -z "$NEW_USER" ]; then
		error "No user specified. Cannot create directories and files without a user."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		unset NEW_USER
		unset NEW_USER_PASS
		unset choice
		return_to_menu
	fi
	if grep -q "^$NEW_USER:" /etc/passwd; then
		error "User already exists: ${YELLOW}$NEW_USER${NC}"
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		unset NEW_USER
		unset NEW_USER_PASS
		unset choice
		return_to_menu
	fi
	info "New User: ${YELLOW}$NEW_USER${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
	#! CREATE NEW USER
	print_line && info "Creating: ${YELLOW}$NEW_USER${NC}"
	sudo useradd -m -s /bin/bash "$NEW_USER"
	if [ $? -ne 0 ]; then
		error "Failed to create new user: ${YELLOW}$NEW_USER${NC}"
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		unset NEW_USER
		unset NEW_USER_PASS
		unset choice
		return_to_menu
	else
		success "Successfully created new user: ${YELLOW}$NEW_USER${NC}"
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
	#! SET PASSWORD FOR NEW USER
	print_line && info "Setting password for: ${YELLOW}$NEW_USER${NC}"
	echo -e "Please enter the password for: ${YELLOW}$NEW_USER${RED}\n"
	read -rsp "Enter Password: " NEW_USER_PASS
	echo -e "${NC}"
	echo "$NEW_USER:$NEW_USER_PASS" | sudo chpasswd && \
    success "Successfully set password for: ${YELLOW}$NEW_USER${NC}" || error "Failed to set password for: ${YELLOW}$NEW_USER${NC}"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
	#! ADD NEW USER TO GROUPS
	print_line && info "Adding $NEW_USER to system groups..."
	info "Adding $NEW_USER to users group..."
	sudo usermod -aG users "$NEW_USER" && \
    success "Successfully added ${YELLOW}$NEW_USER${GREEN} to users group" || error "Failed to add ${YELLOW}$NEW_USER${RED} to users group"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
	print_line && info "Add $NEW_USER to sudo group?"
    read -rp "Do you want to add $NEW_USER to the sudo group? (y/n): " choice
	if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
	    warn "Adding $NEW_USER to sudo group..."
		sudo usermod -aG sudo "$NEW_USER" && \
    	success "Successfully added ${YELLOW}$NEW_USER${GREEN} to sudo group" || error "Failed to add ${YELLOW}$NEW_USER${RED} to sudo group"
	fi
	unset choice

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
	#! SET DEFAULT SHELL
	print_line && info "Setting default shell for $NEW_USER..."
    read -rp "Do you want to change the default shell for $NEW_USER? (y/n): " choice
	if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
		if command -v zsh &>/dev/null; then
			info "zsh is available. Setting zsh as default shell for $NEW_USER..."
			chsh -s $(which zsh) "$NEW_USER" && \
			success "Successfully set zsh as default shell for: ${YELLOW}$NEW_USER${NC}" || error "Failed to set zsh as default shell for: ${YELLOW}$NEW_USER${NC}"
		else
			warn "zsh is not available. Setting bash as default shell for $NEW_USER..."
			chsh -s $(which bash) "$NEW_USER" && \
			success "Successfully set bash as default shell for: ${YELLOW}$NEW_USER${NC}" || error "Failed to set bash as default shell for: ${YELLOW}$NEW_USER${NC}"
		fi
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	unset NEW_USER
	unset NEW_USER_PASS
	unset choice
	return_to_menu
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	create SSH key
make_ssh_key () #* File: ssh key: .ssh/id_ed25519
{
	local BANNER_TITLE="Creating user ssh keys"
	local BANNER_EXIT="Create ssh keys script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"

	banner "$BANNER_TITLE"

	info "Creating ssh keys for: $USER"

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	print_line && info "Creating ssh keys if they don't exist..."
	if [ ! -f "$HOME"/.ssh/id_ed25519 ]; then
		warn "No ssh key found for $USER."
		info "Generating ssh key (id_ed25519) for $USER..."
		ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N '' && \
		success "Successfully generated SSH key for $USER" || error "Failed to generate ssh key for $USER"
	else
		info "User $USER already has an ssh key. Skipping ssh key generation."
		echo -e "\n${GREEN}PUBLIC KEY:${YELLOW}$(cat "$HOME/.ssh/id_ed25519.pub")${NC}"
	fi

	#~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
}
#?	── Terminal helpers ────────────────────────────────────────────────────────
hide_cursor()  { printf '\033[?25l'; }
show_cursor()  { printf '\033[?25h'; }
clear_screen() { printf '\033[2J\033[H'; }
move_to()      { printf '\033[%d;%dH' "$1" "$2"; }

# Restore terminal on exit
cleanup() {
  tput rmcup 2>/dev/null || true
  show_cursor
  stty echo 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# ── Draw the full menu ────────────────────────────────────────────────────────
draw_menu() {
  clear_screen

  # Header
  move_to 1 1
  printf "${BOLD}${CYAN}"
  printf '╔═════════════════════════════════════════════════════════╗\n'
  printf '║                   ⚙  Setup Manager  ⚙                   ║\n'
  printf '╚═════════════════════════════════════════════════════════╝'
  printf "${RESET}\n"

  printf "${DIM}  ↑↓ move  Space toggle  a all  n none  Enter run  q quit${RESET}\n\n"

  # Items
  for i in "${!ITEMS[@]}"; do
    local label="${ITEMS[$i]%%|*}"
    local check; [[ "${SELECTED[$i]}" -eq 1 ]] && check="$CHECK_ON" || check="$CHECK_OFF"

    if [[ "$i" -eq "$CURSOR" ]]; then
      printf "  ${BG_SEL}${FG_SEL} ▶  %s  %-22s ${RESET}\n" "$check" "$label"
    else
      printf "     %s  %-22s \n" "$check" "$label"
    fi
  done

  # Footer: count selected
  local n_sel=0
  for s in "${SELECTED[@]}"; do (( n_sel += s )); done
  printf "\n  ${DIM}%d / %d selected${RESET}\n" "$n_sel" "$COUNT"
}

# ── Run selected functions ────────────────────────────────────────────────────
run_selected() {
  # Leave the alternate screen buffer so output is visible after the script exits.
  tput rmcup 2>/dev/null || true
  show_cursor
  stty echo 2>/dev/null || true

  local any=0
  for i in "${!ITEMS[@]}"; do
    [[ "${SELECTED[$i]}" -eq 1 ]] && any=1 && break
  done

  if [[ "$any" -eq 0 ]]; then
    printf "\n  ${YELLOW}Nothing selected. Exiting.${RESET}\n\n"
    return
  fi

  printf "\n${BOLD}${CYAN}Running selected tasks…${RESET}\n"
  printf "${DIM}══════════════════════════════════════${RESET}\n\n"

  local failed=()
  for i in "${!ITEMS[@]}"; do
    if [[ "${SELECTED[$i]}" -eq 1 ]]; then
      local label="${ITEMS[$i]%%|*}"
      local fn="${ITEMS[$i]##*|}"
      printf "${BOLD}${GREEN}[%d/%d]${RESET} ${BOLD}%s${RESET}\n" "$((i+1))" "$COUNT" "$label"
      if ! $fn; then
        printf "  ${RED}✗ Failed: %s${RESET}\n" "$fn"
        failed+=("$label")
      else
        printf "  ${GREEN}✓ Done${RESET}\n"
      fi
      echo
    fi
  done

  printf "${DIM}══════════════════════════════════════${RESET}\n"
  if [[ ${#failed[@]} -gt 0 ]]; then
    printf "${RED}${BOLD}Some tasks failed:${RESET}\n"
    for f in "${failed[@]}"; do printf "  ${RED}• %s${RESET}\n" "$f"; done
  else
    printf "${GREEN}${BOLD}All tasks completed successfully!${RESET}\n"
  fi
  printf "\nPress any key to exit…"
  read -rsn1
}

# ── Main loop ─────────────────────────────────────────────────────────────────
main() {
  # Switch to alternate screen buffer
  tput smcup 2>/dev/null || true
  hide_cursor
  stty -echo 2>/dev/null || true

  draw_menu

  while true; do
    # Read key (handles escape sequences for arrow keys)
    local key
    IFS= read -rsn1 key

    if [[ "$key" == $'\x1b' ]]; then        # escape sequence
      local seq1 seq2
      IFS= read -rsn1 -t 0.05 seq1
      IFS= read -rsn1 -t 0.05 seq2
      key="${key}${seq1}${seq2}"
    fi

    case "$key" in
      # Arrow up
      $'\x1b[A'|k)
        (( CURSOR = (CURSOR - 1 + COUNT) % COUNT ))
        ;;
      # Arrow down
      $'\x1b[B'|j)
        (( CURSOR = (CURSOR + 1) % COUNT ))
        ;;
      # Space — toggle current
      ' ')
        (( SELECTED[CURSOR] = 1 - SELECTED[CURSOR] ))
        ;;
      # a — select all
      a|A)
        for i in "${!ITEMS[@]}"; do SELECTED[$i]=1; done
        ;;
      # n — deselect all
      n|N)
        for i in "${!ITEMS[@]}"; do SELECTED[$i]=0; done
        ;;
      # Enter — run selected
      ''|$'\n'|$'\r')
        run_selected
        break
        ;;
      # q — quit
      q|Q)
        clear_screen
        printf "\n  ${DIM}Aborted.${RESET}\n\n"
        break
        ;;
    esac

    draw_menu
  done
}
main