#!/bin/bash

RESET="\033[0m" #Normal
RED="\033[1;31m" #Red
GREEN="\033[1;32m" #Green
YELLOW="\033[1;33m" #Yellow
WHITE="\033[1;37m" #White

# Function to check and create a Python virtual environment using pythonz
pyvenv() {
    local v_name=${1:-$(read -p "Enter the virtual environment name: " name && echo $name)}
    local v_home="$HOME/python-virtual-environs/$v_name"

    # Check if pythonz is installed
    if ! command -v pythonz &> /dev/null; then
        echo -e "${RED}Couldn't find pythonz. ${WHITE}Installing...\n"
        curl -kL https://raw.github.com/saghul/pythonz/master/pythonz-install | bash

        # Check if the bashrc configuration exists
        if ! grep -q '[[ -s $HOME/.pythonz/etc/bashrc ]]' "$HOME/.bashrc"; then
            echo '[[ -s $HOME/.pythonz/etc/bashrc ]] && source $HOME/.pythonz/etc/bashrc' >> "$HOME/.bashrc"
            echo -e "${GREEN}Added pythonz to .bashrc\n"
        fi

        # Source the updated .bashrc
        source "$HOME/.bashrc"
        pyvenv $1
    fi

    if [ -z "$v_name" ]; then
        echo -e "\n${RED}Error: Virtual environment name must be provided.\n"
        return 1
    fi

    if [ ! -d "$v_home" ]; then
        py_ver=${2:-$(read -p "Enter the Python version: " version && echo $version)}

        if [ ! pythonz list | grep -q "$py_ver" ]; then
            echo -e "\n${RED}Python version '$py_ver' is not installed.\n${WHITE}Installing now.\n"
            pythonz install "$py_ver"
        fi

        echo -e "\n${YELLOW}Creating folder ${WHITE}$v_home${YELLOW} ...${RESET}\n"
        mkdir -p "$v_home"  # Create the directory for the virtual environment
        usepy="$(pythonz locate $py_ver)"
        if [ -z "$usepy" ]; then
            echo -e "\n${RED}$usepy wasn't found, ${WHITE}despite supposedly being installed already.\nThat's both ${RED}unexpected ${WHITE}and ${RED}fatal${WHITE}. Gotta quit here.\n${RESET}"
            exit 1
        fi
        echo -e "\n${WHITE}$usepy -m venv '$v_home'${RESET}"
        $usepy -m venv "$v_home" 
    else
        usepy="$v_home/bin/python3"
        py_ver=$($usepy --version 2>&1 | awk '{print $2}')
    fi

    echo -e "${WHITE}\n    \$usepy=$usepy"
    echo -e "    \$v_name=$v_name"
    echo "    \$v_home=$v_home"
    echo -e "    \$py_ver=$py_ver\n"

    echo -e "\n    source '$v_home/bin/activate'"
    source "$v_home/bin/activate"
    echo -e "\nType 'deactivate' to exit this venv."
    echo -e "${RESET} \n"
}
