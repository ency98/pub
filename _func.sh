#!/usr/bin/env bash

#!##############################################################################
#! ABOUT: This script contains functions that can be used in other scripts.
#!##############################################################################

#* Suppress all output of this function.
#?  &>/dev/null

#* Suppress only error output of this function.
#?  2>/dev/null

#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?  Logging helpers

#? info|success|warn|error "Message to print."
info()    { (( SUPERQUIET )) && return; echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { (( SUPERQUIET )) && return; echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { (( SUPERQUIET )) && return; echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#? Decorations and lines

#? Print a single (80 char) line of dashes for visual separation in output.
print_line(){ echo -e "\n${GREEN}--------------------------------------------------------------------------------${NC}" ; }

#? Print a single (80 char) line of equal signs for visual separation in output.
print_double_line(){ echo -e "${BLUE}================================================================================${NC}" ; }

#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#? This function prints a banner message.

# BANNER_TITLE=""
# BANNER_EXIT=""
banner ()
{
	local MESSAGE="$1"
	echo "" && print_double_line
	echo -e "${GREEN}$MESSAGE${NC}"
	print_double_line && echo ""
}

#? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !#
#?	Export colors variables [set in .profile for bash]
BLACK='\033[0;30m'         # Black            ${BLACK}
RED='\033[0;31m'           # Red              ${RED}
GREEN='\033[0;32m'         # Green            ${GREEN}
YELLOW='\033[0;33m'        # Yellow           ${YELLOW}
BLUE='\033[0;34m'          # Blue             ${BLUE}
MAGENTA='\033[0;35m'       # Magenta          ${MAGENTA}
CYAN='\033[0;36m'          # Cyan             ${CYAN}
WHITE='\033[0;37m'         # White            ${WHITE}
# Bold
B_BLACK='\033[1;30m'       # Bold Black       ${B_BLACK}
B_RED='\033[1;31m'         # Bold Red         ${B_RED}
B_GREEN='\033[1;32m'       # Bold Green       ${B_GREEN}
B_YELLOW='\033[1;33m'      # Bold Yellow      ${B_YELLOW}
B_BLUE='\033[1;34m'        # Bold Blue        ${B_BLUE}
B_MAGENTA='\033[1;35m'     # Bold Magenta     ${B_MAGENTA}
B_CYAN='\033[1;36m'        # Bold Cyan        ${B_CYAN}
B_WHITE='\033[1;37m'       # Bold White       ${B_WHITE}
# Underline
U_BLACK='\033[4;30m'       # Underline Black  ${U_BLACK}
U_RED='\033[4;31m'         # Underline Red    ${U_RED}
U_GREEN='\033[4;32m'       # Underline Green  ${U_GREEN}
U_YELLOW='\033[4;33m'      # Underline Yellow ${U_YELLOW}
U_BLUE='\033[4;34m'        # Underline Blue   ${U_BLUE}
U_MAGENTA='\033[4;35m'     # Underline Magenta${U_MAGENTA}
U_CYAN='\033[4;36m'        # Underline Cyan   ${U_CYAN}
U_WHITE='\033[4;37m'       # Underline White  ${U_WHITE}
# Background
BG_BLACK='\033[40m'        # BG Black         ${BG_BLACK}
BG_RED='\033[41m'          # BG Red           ${BG_RED}
BG_GREEN='\033[42m'        # BG Green         ${BG_GREEN}
BG_YELLOW='\033[43m'       # BG Yellow        ${BG_YELLOW}
BG_BLUE='\033[44m'         # BG Blue          ${BG_BLUE}
BG_MAGENTA='\033[45m'      # BG Magenta       ${BG_MAGENTA}
BG_CYAN='\033[46m'         # BG Cyan          ${BG_CYAN}
BG_WHITE='\033[47m'        # BG White         ${BG_WHITE}
# Bright (high intensity)
BR_BLACK='\033[0;90m'      # Bright Black     ${BR_BLACK}
BR_RED='\033[0;91m'        # Bright Red       ${BR_RED}
BR_GREEN='\033[0;92m'      # Bright Green     ${BR_GREEN}
BR_YELLOW='\033[0;93m'     # Bright Yellow    ${BR_YELLOW}
BR_BLUE='\033[0;94m'       # Bright Blue      ${BR_BLUE}
BR_MAGENTA='\033[0;95m'    # Bright Magenta   ${BR_MAGENTA}
BR_CYAN='\033[0;96m'       # Bright Cyan      ${BR_CYAN}
BR_WHITE='\033[0;97m'      # Bright White     ${BR_WHITE}
# Formatting
BOLD='\033[1m'             # Bold             ${BOLD}
DIM='\033[2m'              # Dim              ${DIM}
UNDERLINE='\033[4m'        # Underline        ${UNDERLINE}
BLINK='\033[5m'            # Blink            ${BLINK}
REVERSE='\033[7m'          # Reverse          ${REVERSE}
HIDDEN='\033[8m'           # Hidden           ${HIDDEN}
STRIKETHROUGH='\033[9m'    # Strikethrough    ${STRIKETHROUGH}
# Reset
NC='\033[0m'               # No Color         ${NC}