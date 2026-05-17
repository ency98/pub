#!/usr/bin/env bash
# =============================================================================
#  setup_menu.sh — Interactive TUI for running setup functions
#  Arrow keys + Space to toggle, Enter to run selected, q to quit
# =============================================================================

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
	echo "" && print_double_line
	echo -e "${GREEN}$MESSAGE${NC}"
	print_double_line && echo ""
}

#? Print a single (80 char) line of dashes for visual separation in output.
print_line(){ echo -e "\n${GREEN}--------------------------------------------------------------------------------${NC}" ; }

#? Print a single (80 char) line of equal signs for visual separation in output.
print_double_line(){ echo -e "${BLUE}================================================================================${NC}" ; }

# ── Colors & styles ──────────────────────────────────────────────────────────
# Use $'...' so variables hold actual ESC bytes, not literal backslash sequences.
# This is required for printf "%s" to emit color (echo -e also works either way).
RED=$'\033[0;31m';  GREEN=$'\033[0;32m';  YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'; CYAN=$'\033[0;36m';   NC=$'\033[0m'
BOLD=$'\033[1m';    DIM=$'\033[2m';        RESET=$'\033[0m'
BG_SEL=$'\033[48;5;236m'; FG_SEL=$'\033[1;97m'
CHECK_ON="${GREEN}[✓]${RESET}"; CHECK_OFF="${DIM}[ ]${RESET}"

# ── Menu items: "Label|function_name" ─────────────────────────────────────────
declare -a ITEMS=(
	"Update this script|update_bootstrap_script"
	"Update all|update_all"
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

# ── Track selected state (0=off, 1=on) ───────────────────────────────────────
declare -a SELECTED
for i in "${!ITEMS[@]}"; do SELECTED[$i]=0; done

CURSOR=0
COUNT=${#ITEMS[@]}

# ── Stub functions (replace with your real implementations) ──────────────────
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	updates
update_all ()
{
	local BANNER_TITLE="Updating the system"
	local BANNER_EXIT="System update script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")\n${RED}Please reboot your system as soon as possible to ensure all changes have been applied.${NC}"

	banner "$BANNER_TITLE"

	info "Updating the system."

	print_line
	if [[ "$(uname -s)" == "Darwin" ]]; then
		info "\nDetected macOS."
		if -f /home/linuxbrew/.linuxbrew/bin/brew &>/dev/null; then
			print_line
			info "brew package manager detected. Running brew update and upgrade."
			info "Running brew update...\n"
			brew update -q  && \
			success "\nSuccessfully updated brew" || error "\nFailed to update brew"
			info "Running brew upgrade...\n"
			brew upgrade -q  && \
			success "\nSuccessfully upgraded brew" || error "\nFailed to upgrade brew"
		fi
	elif [[ "$(uname -s)" == "Linux" ]]; then
		info "\nDetected Linux."
		print_line
		info "Running apt update and upgrade."
		info "Running apt update...\n"
		sudo apt-get update -y -q --fix-missing && \
		success "\nSuccessfully updated system" || error "\nFailed to update system"
		print_line
		info "Running apt upgrade...\n"
		sudo apt-get upgrade -y -q --fix-missing --auto-remove --purge && \
		success "\nSuccessfully upgraded system" || error "\nFailed to upgrade system"
		print_line
		info "Since we are here making sure curl and wget are installed."
		sudo apt install curl wget -qq -y  && \
		success "curl and wget installed successfully" || error "Failed to install curl and wget"
		if -f /home/linuxbrew/.linuxbrew/bin/brew &>/dev/null; then
			print_line
			info "brew package manager detected. Running brew update and upgrade as well."
			info "Running brew update and upgrade."
			brew update -q  && \
			success "\nSuccessfully updated brew" || error "\nFailed to update brew"
			brew upgrade -q  && \
			success "\nSuccessfully upgraded brew" || error "\nFailed to upgrade brew"
		fi
	fi

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	return 0
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	update bootstrap script
update_bootstrap_script ()
{
	local BANNER_TITLE="Updating the bootstrap script"
	local BANNER_EXIT="Bootstrap script update finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"
	local BOOTSTRAP_SRC="https://raw.githubusercontent.com/ency98/pub/refs/heads/main/bootstrap.sh"
	local BOOTSTRAP_DEST="/tmp/bootstrap.sh"

	banner "$BANNER_TITLE"

	info "Updating this script."

	print_line
	info "Downloading updated bootstrap script from:\n${YELLOW}$BOOTSTRAP_SRC${NC}"
	wget -O "$BOOTSTRAP_DEST" "$BOOTSTRAP_SRC"  && \
	success "\nSuccessfully downloaded bootstrap script" || error "\nFailed to download bootstrap script"

	print_line
	info "Updating bootstrap script..."
	mkdir -p ~/.scripts
	chmod +x "$BOOTSTRAP_DEST"  && \
	success "\nSuccessfully updated bootstrap script permissions" || error "\nFailed to update bootstrap script permissions"
	rm -rf "$HOME/.scripts/bootstrap.sh"
	mv -v "$BOOTSTRAP_DEST" "$HOME/.scripts/bootstrap.sh"  && \
	success "\nSuccessfully updated bootstrap script file."  || error "\nFailed to update bootstrap script file."

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	unset BOOTSTRAP_SRC
	unset BOOTSTRAP_DEST
	exit 0

}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	apt install: base applications
install_base_apps_apt() #* Install base applications from a list of packages stored in a remote file
{
	local PACKAGE_LIST_URL="${PKG_LIST:-https://raw.githubusercontent.com/ency98/pub/refs/heads/main/base-packages}"
	local PACKAGE_LIST="/tmp/base-packages"

	info "Install base applications from a list of packages stored in a remote file"

	print_line

    info "Downloading updated base packages list..."
    wget -O "$PACKAGE_LIST" "$PACKAGE_LIST_URL"
    if [ $? -ne 0 ]; then
        error "Failed to download base packages list from $PACKAGE_LIST_URL"
        return 1
    fi

    info "Installing packages from list..."
    print_line
    echo -e "\n\n${YELLOW}$(column < "$PACKAGE_LIST")${NC}\n"
    print_line

    local failed_packages=()

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

    # Summary
    print_line
    if [ ${#failed_packages[@]} -eq 0 ]; then
        success "All packages installed successfully."
    else
        warn "The following packages failed to install:"
        for pkg in "${failed_packages[@]}"; do
            error "  - $pkg"
        done
    fi
    print_line

    rm -f "$PACKAGE_LIST" && \
    success "Removed temporary package list" || warn "Could not remove temporary package list"
	unset PACKAGE_LIST_URL
	unset PACKAGE_LIST
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	brew
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

	print_line
	info "Checking if brew is already installed."
	if -f /home/linuxbrew/.linuxbrew/bin/brew &>/dev/null; then
		success "brew is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		unset REQUIRED_PACKAGES
		return 0
	else
		warn "brew is not installed."
		info "Continuing with installation..."
	fi

	print_line
	info "Installing required packages..."
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

	print_line
	info "Downloading install script..."
	if ! command -v "curl" &>/dev/null; then
		warn "curl not found. Downloading install script with wget instead of curl."
		print_line
		info "Running install script..."
		/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	else
		print_line
		info "Running install script..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	if -f /home/linuxbrew/.linuxbrew/bin/brew &>/dev/null; then
		print_line
		success "brew installed successfully."
		print_line
		info "Installing curl with brew."
		brew install curl &>/dev/null
	else
		print_line
		error "brew installation failed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return 1
	fi

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	return 0
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	cargo
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

	print_line
	info "Checking if cargo is already installed."
	if command -v "cargo" &>/dev/null; then
		success "cargo is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		unset REQUIRED_PACKAGES
		return 1
	else
		warn "cargo is not installed."
		info "Continuing with installation..."
	fi

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
	if [ -f "$HOME/.cargo/env" ]; then
		. "$HOME/.cargo/env";
	fi

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	return 0
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	zsh
install_zsh ()
{
	local BANNER_TITLE="Installing zsh shell"
	local BANNER_EXIT="zsh install script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"

	banner "$BANNER_TITLE"

	info "Installing zsh"

	print_line
	info "Checking if zsh is already installed."
	if command -v "zsh" &>/dev/null; then
		success "zsh is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return 0
	else
		warn "zsh is not installed."
		info "Continuing with installation..."
	fi

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
		return 1
	fi

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	return 0
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	docker
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

	print_line
	info "Checking if Docker is already installed."
	if command -v "docker" &>/dev/null; then
		success "Docker is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return 0
	else
		warn "Docker is not installed."
		info "Continuing with installation..."
	fi

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

	if command -v "docker" &>/dev/null; then
		print_line
		success "Docker installed successfully."
	else
		print_line
		error "Docker installation failed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return 1
	fi

	info "Adding users to docker group"
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

	info "Creating and setting permissions for the usual docker data directory..."
	warn "Setting permissions on /mnt to 777 and owner to root:100"
	sudo chmod 777 -R /mnt && sudo chown root:100 /mnt

	info "Creating docker datadirectory: ${YELLOW}/mnt/docker${NC}"
	mkdir -p /mnt/docker

	info "Exporting DOCKER_APPDATA_DIR environment variable: ${YELLOW}DOCKER_APPDATA_DIR=/mnt/docker${NC}"
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
	return 0
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	nerdfonts
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

	#?	Detect OS
	if [[ "$(uname -s)" == "Darwin" ]]; then
		print_line
		error "Nerdfonts install is only supported on Linux for now."
		info "Skipping nerd font installation."

		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return 0
	elif [[ "$(uname -s)" == "Linux" ]]; then
		info "Detected OS: Linux"
		info "Continuing with installation..."
	fi

	if [[ ! -d "$fonts_dir" ]]; then
		print_line
		warn "Fonts directory not found."
		info "Creating fonts directory: $fonts_dir"
		mkdir -p "$fonts_dir"
	fi

	for font in "${fonts[@]}"; do
		print_line
		info "Downloading $download_url"

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

	info "Removing Windows Compatible fonts..."
	find "$fonts_dir" -name '*Windows Compatible*' -delete

	info "Building font information caches in [dirs] $fonts_dir..."
	fc-cache -fv


	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	unset version
	unset fonts_dir
	unset fonts
	unset zip_file
	unset download_url
	return 0
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	atuin
install_atuin ()
{
	local BANNER_TITLE="Installing atuin a shell history manager"
	local BANNER_EXIT="atuin install script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"

	banner "$BANNER_TITLE"

	info "Starting installation of atuin."

	print_line
	info "Checking if atuin is already installed."
	if [ -d "$HOME/.atuin" ]; then
		success "atuin is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return 0
	else
		warn "atuin is not installed."
		info "Continuing with installation..."
	fi

	print_line
	info "Running install script..."
	warn "Downloading script from:\n${YELLOW}https://setup.atuin.sh${NC}"
	curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

	if [ -d "$HOME/.atuin" ]; then
		print_line
		success "atuin installed successfully."
	else
		print_line
		error "atuin installation failed."
	fi

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	starship
install_starship ()
{
	local BANNER_TITLE="Installing Starship Prompt"
	local BANNER_EXIT="Starship install script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"

	banner "$BANNER_TITLE"

	info "Installing the starship prompt"

	print_line
	info "Checking if starship is already installed."
	if command -v "starship" &>/dev/null; then
		success "starship is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return 0
	else
		info "starship is not installed."
		info "Continuing with installation..."
	fi

	print_line
	info "Downloading install script..."
	if ! command -v "curl" &>/dev/null; then
		warn "curl not found. Downloading starship install script with wget instead of curl."
		print_line
		info "Running install script for: starship..."
		wget https://starship.rs/install.sh -qO- | sh
	else
		print_line
		info "Running install script."
		warn "Downloading script from:\n${YELLOW}https://starship.rs/install.sh${NC}"
		curl -sS https://starship.rs/install.sh | sh
	fi


	if command -v "starship" &>/dev/null; then
		print_line
		success "starship prompt installed successfully."
		print_lie
		info "Configuring starship promt withthe preset $PRESET"
		starship preset gruvbox-rainbow -o ~/.config/starship.toml
	else
		print_line
		error "starship prompt installation failed."
	fi


	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	chezmoi
install_chezmoi ()
{
	local BANNER_TITLE="Installing chezmoi dotfile manager"
	local BANNER_EXIT="chezmoi install script finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"

	banner "$BANNER_TITLE"

	info "Starting installation of chezmoi."

	print_line
	info "Checking if chezmoi is already installed."
	if command -v "chezmoi" &>/dev/null; then
		success "chezmoi is already installed."
		banner "$BANNER_EXIT"
		unset BANNER_TITLE
		unset BANNER_EXIT
		return 0
	else
		info "chezmoi is not installed."
		info "Continuing with installation..."
	fi

	print_line
	info "Downloading chezmoi binary."
	warn "Downloading Binary from:\n${YELLOW}get.chezmoi.io${NC}"
	sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin

	info "Copying chezmoi binary to /usr/local/bin/chezmoi for system wide availability."
	sudo cp -v $HOME/.local/bin/chezmoi /usr/local/bin/chezmoi

	if command -v "chezmoi" &>/dev/null; then
		print_line
		success "chezmoi installed successfully."
	else
		print_line
		error "chezmoi installation failed."
	fi

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
}
#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	init chezmoi
GIT_USERNAME=""
GIT_EMAIL=""
GIT_TOKEN=""
GIT_REPO="github.com/$GIT_USERNAME/dotfiles.git"
DOTFILES_REPO="https://$GIT_TOKEN@${GIT_REPO}"
init_chezmoi_token ()
{
	local BANNER_TITLE="Initializing chezmoi to update and manage local dot files"
	local BANNER_EXIT="chezmoi initialization finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"


	banner "$BANNER_TITLE"

	warn "Configuring chezmoi for token auth..."


	#! GIT EMAIL
	echo "" && print_line && echo -e "${RED}\n"
	read -rp "Please enter your GitHub email: " GIT_EMAIL && echo -e "${NC}"
	warn "GitHub email entered: ${YELLOW}$GIT_EMAIL${NC}" && echo ""

	#! GIT USERNAME
	echo "" && print_line && echo -e "${RED}\n"
	read -rp "Please enter your GitHub username: " GIT_USERNAME && echo -e "${NC}"
	warn "GitHub username entered: ${YELLOW}$GIT_USERNAME${NC}" && echo ""

	#! GIT TOKEN
	echo "" && print_line && echo -e "${RED}\n"
	read -rp "Please enter your GitHub token: " GIT_TOKEN && echo -e "${NC}"
	warn "GitHub token entered: ${YELLOW}$GIT_TOKEN${NC}" && echo ""

	echo "" && print_line && echo ""
	info "Git Username set to: ${YELLOW}$GIT_USERNAME${NC}"
	info "Git email set to: ${YELLOW}$GIT_EMAIL${NC}"
	info "Git token set to: ${YELLOW}$GIT_TOKEN${NC}"
	info "Git repository set to: ${YELLOW}$GIT_REPO${NC}"
	info "Initializing chezmoi with remote repository: https://$GIT_TOKEN@$GIT_REPO"

	echo "" && print_line && echo -e "${YELLOW}\n"
	read -rp "Please check the information above. Press Enter to continue or Ctrl+C to abort: " && echo -e "${NC}"

	return 0
	echo "" && print_line
	info "Checking if chezmoi is already installed."
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
		return 1
	fi

	print_line
	warn "Purging local config just incase there are any conflicts with the remote repository."
	chezmoi purge --force -v

	print_line
	info "Initializing chezmoi with remote repository: https://${GIT_TOKEN}@${GIT_REPO}"
	chezmoi init "https://${GIT_TOKEN}@${GIT_REPO}"

	print_line
	warn "Applying chezmoi configuration to the local system. This will overwrite any existing local dotfiles with the remote repository."
	echo -e "${RED}"
	read -n 1 -s -r -p "Press any key to continue with overwriting the local dotfiles. Press ctrl+c to abort..." -t 10
	echo -e "${NC}"

	print_line
	info "Applying chezmoi configuration to the local system."
	chezmoi -v apply
	if [ $? -ne 0 ]; then
		#& "if" Failed...
		ERROR=$?
		print_line
		error "Error applying chezmoi configuration."
	else
		ERROR=$?
		#& "if" Success...
		print_line
		info "chezmoi successfully applied configuration."
	fi

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	unset GIT_USERNAME
	unset GIT_EMAIL
	unset GIT_TOKEN
	unset GIT_REPO
	unset DOTFILES_REPO
	return $ERROR
}
init_chezmoi_ssh ()
{
	local BANNER_TITLE="Initializing chezmoi to update and manage local dot files"
	local BANNER_EXIT="chezmoi initialization finished at: ${YELLOW}$(date "+%Y-%m-%d_%H:%M:%S")${NC}"
	local GIT_USERNAME=""
	local GIT_EMAIL=""
	local GIT_REPO="github.com/$GIT_USERNAME/dotfiles.git"
	local DOTFILES_REPO="git@$GIT_REPO"

	banner "$BANNER_TITLE"

	warn "Configuring chezmoi for ssh key auth..."

	#! GIT EMAIL
	echo "" && print_line && echo -e "${RED}\n"
	read -rp "Please enter your GitHub email: " GIT_EMAIL && echo -e "${NC}"
	warn "GitHub email entered: ${YELLOW}$GIT_EMAIL${NC}" && echo ""

	#! GIT USERNAME
	echo "" && print_line && echo -e "${RED}\n"
	read -rp "Please enter your GitHub username: " GIT_USERNAME && echo -e "${NC}"
	warn "GitHub username entered: ${YELLOW}$GIT_USERNAME${NC}" && echo ""


	echo "" && print_line && echo ""
	info "Git Username set to: ${YELLOW}$GIT_USERNAME${NC}"
	info "Git email set to: ${YELLOW}$GIT_EMAIL${NC}"
	info "Git repository set to: ${YELLOW}$GIT_REPO${NC}"
	info "Initializing chezmoi with remote repository: $DOTFILES_REPO"

	echo "" && print_line && echo -e "${YELLOW}\n"
	read -rp "Please check the information above. Press Enter to continue or Ctrl+C to abort: " && echo -e "${NC}"

	echo "" && print_line
	info "Checking if chezmoi is already installed."
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
		return 1
	fi

	print_line
	warn "Purging local config just incase there are any conflicts with the remote repository."
	chezmoi purge --force -v

	print_line
	info "Initializing chezmoi with remote repository: $DOTFILES_REPO"
	chezmoi init $DOTFILES_REPO

	print_line
	warn "Applying chezmoi configuration to the local system. This will overwrite any existing local dotfiles with the remote repository."
	echo -e "${RED}"
	read -n 1 -s -r -p "Press any key to continue with overwriting the local dotfiles. Press ctrl+c to abort..." -t 10
	echo -e "${NC}"

	print_line
	info "Applying chezmoi configuration to the local system."
	chezmoi -v apply
	if [ $? -ne 0 ]; then
		#& "if" Failed...
		ERROR=$?
		print_line
		error "Error applying chezmoi configuration."
	else
		ERROR=$?
		#& "if" Success...
		print_line
		info "chezmoi successfully applied configuration."
	fi

	banner "$BANNER_EXIT"
	unset BANNER_TITLE
	unset BANNER_EXIT
	unset GIT_USERNAME
	unset GIT_EMAIL
	unset GIT_TOKEN
	unset GIT_REPO
	unset DOTFILES_REPO
	return $ERROR
}


# ── Terminal helpers ──────────────────────────────────────────────────────────
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
  printf '╔══════════════════════════════════════╗\n'
  printf '║       ⚙  Setup Manager  ⚙            ║\n'
  printf '╚══════════════════════════════════════╝'
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