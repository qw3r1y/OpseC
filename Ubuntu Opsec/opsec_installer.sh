#!/bin/bash


GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
ORANGE='\e[38;5;214m' 
NC='\033[0m' 

# # Root kontrolü
# if [ "$(id -u)" -ne 0 ]; then
#     echo -e "${RED}[-] This script must be run as root!${NC}"
#     exit 1
# fi


remove_package() {
    echo -e "${YELLOW}[*] Removing $1...${NC}"
    sudo apt-get remove --purge -y "$1" > /dev/null 2>&1
    sudo apt-get autoremove -y > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] $1 removed successfully!${NC}"
    else
        echo -e "${RED}[-] Failed to remove $1.${NC}"
    fi
}


remove_all_tools() {
    echo -e "${ORANGE}[!] REMOVING ALL TOOLS${NC}"
    echo " "
    remove_package "tor"
    remove_package "openvpn"
    remove_package "firejail"
    remove_package "ufw"
    remove_package "opensnitch"
    remove_package "dnscrypt-proxy"
    remove_package "exiftool"
    remove_package "bleachbit"
    remove_package "keepassxc"
    remove_package "signal-desktop"
    remove_package "fail2ban"
    remove_package "rkhunter"
    remove_package "chkrootkit"
    remove_package "clamav"
    remove_package "suricata"
    remove_package "ossec-hids"
    echo -e "${RED}########### [+] ALL TOOLS REMOVED SUCCESSFULLY! ###########${NC}"
    echo " "
    echo " "
}




function show_progress() {
    echo -e "${YELLOW}👓 Installing $1, please wait...${NC}"
    
    for i in {1..50}; do
        sleep 0.1
        echo -n -e "${GREEN}█${NC}"
    done
    echo -e "\n"
}


install_package() {
    show_progress "$1"
    sudo apt-get update -y > /dev/null 2>&1
    sudo apt-get install -y "$1" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] $1 successfully installed!${NC}"
    else
        echo -e "${RED}[-] Failed to install $1.${NC}"
    fi
}


install_dependencies() {
    echo -e "${BLUE}[+] Installing required dependencies...${NC}"
    show_progress "Dependencies"
    sudo apt-get update -y > /dev/null 2>&1
    sudo apt-get install -y xterm libsystemd-dev libssl-dev libpcre2-dev build-essential libz-dev > /dev/null 2>&1
    pip3 install qt-material --break-system-packages > /dev/null 2>&1
    echo -e "${GREEN}[+] Dependencies installed successfully!${NC}"
}


setup_tor() {
    install_package "tor"
    sudo systemctl enable tor > /dev/null 2>&1
    sudo systemctl start tor > /dev/null 2>&1
    echo -e "${GREEN}[+] Tor installed and running on port 9050.${NC}"
}


setup_vpn() {
    install_package "openvpn"
    echo -e "${GREEN}[+] OpenVPN installed! Add your VPN configuration files to /etc/openvpn/.${NC}"
}

setup_firejail() {
    echo -e "${BLUE}[+] Installing Firejail 0.9.72...${NC}"

    
    echo -e "${YELLOW}[+] Trying to install Firejail using apt...${NC}"
    sudo apt-get update -y > /dev/null 2>&1
    sudo apt-get install -y firejail > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] Firejail successfully installed with apt!${NC}"
        return 0
    else
        echo -e "${RED}[-] Firejail could not be installed with apt, trying to install from source...${NC}"
    fi

    
    echo -e "${YELLOW}[+] Installing necessary dependencies...${NC}"
    sudo apt-get install -y build-essential wget tar > /dev/null 2>&1

    
    FIREJAIL_URL="https://github.com/netblue30/firejail/releases/download/0.9.72/firejail-0.9.72.tar.xz"
    TEMP_DIR="/tmp/firejail_install"
    mkdir -p "$TEMP_DIR" 
    cd "$TEMP_DIR" || { echo -e "${RED}[-] Unable to access temporary directory.${NC}"; exit 1; }

    wget -O firejail.tar.xz "$FIREJAIL_URL"
    if [ $? -ne 0 ]; then
        echo -e "${RED}[-] Firejail source code could not be downloaded. Please check the link.${NC}"
        exit 1
    fi

    
    if [ ! -w "$TEMP_DIR/firejail.tar.xz" ]; then
        echo -e "${RED}[-] No write permissions. Checking permissions...${NC}"
        sudo chmod 777 "$TEMP_DIR/firejail.tar.xz"
    fi

    
    tar -xvf firejail.tar.xz > /dev/null 2>&1
    cd firejail-0.9.72 || { echo -e "${RED}[-] Unable to access source folder.${NC}"; exit 1; }
    ./configure > /dev/null 2>&1
    make > /dev/null 2>&1

    
    echo -e "${YELLOW}[+] Starting Firejail installation...${NC}"
    sudo make install > /dev/null 2>&1

    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] Firejail 0.9.72 successfully installed from source!${NC}"
    else
        echo -e "${RED}[-] Firejail installation failed.${NC}"
        exit 1
    fi

    
    firejail --version
}


setup_ufw() {
    echo -e "${BLUE}[+] Installing and configuring UFW...${NC}"
    install_package "ufw"
    sudo ufw enable > /dev/null 2>&1
    sudo ufw default deny incoming > /dev/null 2>&1
    sudo ufw default allow outgoing > /dev/null 2>&1
    echo -e "${GREEN}[+] UFW successfully configured!${NC}"
}


setup_opensnitch() {
    echo -e "${BLUE}[+] Installing Opensnitch...${NC}"
    install_package "opensnitch"
    install_package "opensnitch-ui"
    sudo systemctl enable opensnitchd > /dev/null 2>&1
    sudo systemctl start opensnitchd > /dev/null 2>&1
    echo -e "${GREEN}[+] Opensnitch successfully installed!${NC}"
}

setup_tor_browser() {
    echo -e "${BLUE}[+] Installing Tor Browser...${NC}"

    
    TOR_BROWSER_URL="https://www.torproject.org/dist/torbrowser/14.0.3/tor-browser-linux-x86_64-14.0.3.tar.xz"

    
    wget -O tor-browser.tar.xz "$TOR_BROWSER_URL" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}[-] Tor Browser could not be downloaded. Check the URL or your internet connection.${NC}"
        exit 1
    fi

    
    tar -xvf tor-browser.tar.xz > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}[-] Tor Browser file could not be extracted.${NC}"
        exit 1
    fi

    
    extracted_dir=$(find . -type d -name "tor-browser*" | head -n 1)

    if [ -d "$extracted_dir" ]; then
        cd "$extracted_dir" || { echo -e "${RED}[-] Unable to access Tor Browser folder.${NC}"; exit 1; }
        
        
        ./start-tor-browser.desktop --register-app > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[+] Tor Browser successfully installed!${NC}"
        else
            echo -e "${RED}[-] Tor Browser could not be started.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}[-] Tor Browser folder not found.${NC}"
        exit 1
    fi
}


setup_dnscrypt() {
    install_package "dnscrypt-proxy"
    echo -e "${GREEN}[+] dnscrypt-proxy installed! Configure it via /etc/dnscrypt-proxy/dnscrypt-proxy.toml.${NC}"
}


setup_exiftool() {
    install_package "exiftool"
    echo -e "${GREEN}[+] Exiftool installed! Remove metadata with 'exiftool -all= <file>'.${NC}"
}


setup_bleachbit() {
    install_package "bleachbit"
    echo -e "${GREEN}[+] Bleachbit installed! Clean system and protect privacy with its GUI.${NC}"
}


setup_keepass() {
    echo -e "${BLUE}[+] Installing KeePass...${NC}"
    install_package "keepassxc"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] KeePass successfully installed!${NC}"
    else
        echo -e "${RED}[-] KeePass could not be installed.${NC}"
    fi
}

setup_strongswan() {
    
    echo -e "${GREEN}[+] Installing strongSwan...${NC}"
    apt-get install -y strongswan

    
    echo -e "${GREEN}[+] strongSwan installed and running!${NC}"
}


setup_signal() {
    echo -e "${BLUE}[+] Installing Signal...${NC}"
    curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add - > /dev/null 2>&1
    echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal-xenial.list > /dev/null 2>&1
    sudo apt-get update -y > /dev/null 2>&1
    install_package "signal-desktop"
}


setup_fail2ban() {
    install_package "fail2ban"
    sudo systemctl enable fail2ban > /dev/null 2>&1
    sudo systemctl start fail2ban > /dev/null 2>&1
    echo -e "${GREEN}[+] Fail2ban installed and running.${NC}"
}


setup_rkhunter() {
    echo -e "${BLUE}[+] Installing rkhunter...${NC}"
    install_package "rkhunter"
    sudo rkhunter --update > /dev/null 2>&1
    sudo rkhunter --propupd > /dev/null 2>&1
    echo -e "${GREEN}[+] rkhunter successfully installed! Updated and configured!${NC}"
}


setup_clamav() {
    echo -e "${BLUE}[+] Installing ClamAV...${NC}"
    install_package "clamav"
    sudo freshclam > /dev/null 2>&1
    echo -e "${GREEN}[+] ClamAV successfully installed and database updated!${NC}"
}


setup_chkrootkit() {
    echo -e "${BLUE}[+] Installing chkrootkit...${NC}"
    install_package "chkrootkit"
    echo -e "${GREEN}[+] chkrootkit successfully installed!${NC}"
}


setup_suricata() {
    echo -e "${BLUE}[+] Installing Suricata...${NC}"
    install_package "suricata"
    sudo suricata-update > /dev/null 2>&1
    sudo systemctl enable suricata > /dev/null 2>&1
    sudo systemctl start suricata > /dev/null 2>&1
    echo -e "${GREEN}[+] Suricata successfully installed and running!${NC}"
}


setup_ossec() {
    echo -e "${BLUE}[+] Installing OSSEC...${NC}"

    
    git clone https://github.com/ossec/ossec-hids.git > /dev/null 2>&1
    cd ossec-hids || { echo -e "${RED}[-] Unable to access OSSEC source directory!${NC}"; exit 1; }

    
    echo -e "${YELLOW}[+] Running OSSEC installation...${NC}"

    
    sudo ./install.sh | tee /dev/tty

    echo -e "${GREEN}[+] OSSEC successfully installed!${NC}"
}




install_all_tools() {
    echo -e "${ORANGE}[!] INSTALLING ALL TOOLS${NC}"
    echo ""
    install_dependencies
    setup_strongswan 
    setup_tor 
    setup_suricata 
    setup_chkrootkit
    setup_rkhunter 
    setup_clamav 
    setup_firejail 
    setup_vpn 
    setup_tor_browser 
    setup_ufw 
    setup_opensnitch 
    setup_dnscrypt 
    setup_exiftool 
    setup_bleachbit 
    setup_keepass 
    setup_signal 
    setup_fail2ban  
    setup_ossec 
    echo " "
    echo -e "${RED}########### [+] ALL TOOLS INSTALLED SUCCESSFULLY! ###########${NC}"
}

check_installed() {
    tools=("tor" "openvpn" "ufw" "opensnitch" "dnscrypt-proxy" "exiftool" "bleachbit" "keepassxc" "signal-desktop" "fail2ban" "rkhunter" "chkrootkit" "clamav" "suricata" "firejail" "ossec-hids" "strongswan")
    
    for tool in "${tools[@]}"; do
        case $tool in
            "firejail")
                if ! command -v firejail > /dev/null 2>&1; then
                    echo -e "${YELLOW}[*] Firejail not installed. Installing now...${NC}"
                    install_package "firejail"
                else
                    echo -e "${GREEN}[+] Firejail is already installed.${NC}"
                fi
                ;;

            "ossec-hids")
                if [ ! -d "/var/ossec" ]; then
                    echo -e "${YELLOW}[*] OSSEC not installed. Installing now...${NC}"
                    install_package "ossec-hids"
                else
                    echo -e "${GREEN}[+] OSSEC is already installed.${NC}"
                fi
                ;;

            "rkhunter")
                if ! command -v rkhunter > /dev/null 2>&1; then
                    echo -e "${YELLOW}[*] rkhunter not installed. Installing now...${NC}"
                    install_package "rkhunter"
                else
                    echo -e "${GREEN}[+] rkhunter is already installed.${NC}"
                fi
                ;;

            "chkrootkit")
                if ! command -v chkrootkit > /dev/null 2>&1; then
                    echo -e "${YELLOW}[*] chkrootkit not installed. Installing now...${NC}"
                    install_package "chkrootkit"
                else
                    echo -e "${GREEN}[+] chkrootkit is already installed.${NC}"
                fi
                ;;

            "clamav")
                if ! command -v clamscan > /dev/null 2>&1; then
                    echo -e "${YELLOW}[*] ClamAV not installed. Installing now...${NC}"
                    install_package "clamav"
                else
                    echo -e "${GREEN}[+] ClamAV is already installed.${NC}"
                fi
                ;;

            "suricata")
                if ! command -v suricata > /dev/null 2>&1; then
                    echo -e "${YELLOW}[*] Suricata not installed. Installing now...${NC}"
                    install_package "suricata"
                else
                    echo -e "${GREEN}[+] Suricata is already installed.${NC}"
                fi
                ;;

            "strongswan")
                if ! command -v ipsec > /dev/null 2>&1; then
                    echo -e "${YELLOW}[*] strongSwan not installed. Installing now...${NC}"
                    install_package "strongswan"
                else
                    echo -e "${GREEN}[+] strongSwan is already installed.${NC}"
                fi
                ;;

            "opensnitch")
                if ! systemctl is-active --quiet opensnitch; then
                    echo -e "${YELLOW}[*] Opensnitch not installed or not running. Installing now...${NC}"
                    install_package "opensnitch"
                else
                    echo -e "${GREEN}[+] Opensnitch is already installed and running.${NC}"
                fi
                ;;

            "fail2ban")
                if ! systemctl is-active --quiet fail2ban; then
                    echo -e "${YELLOW}[*] Fail2Ban not installed or not running. Installing now...${NC}"
                    install_package "fail2ban"
                else
                    echo -e "${GREEN}[+] Fail2Ban is already installed and running.${NC}"
                fi
                ;;

            *)
                if ! command -v "$tool" > /dev/null 2>&1; then
                    echo -e "${YELLOW}[*] $tool not installed. Installing now...${NC}"
                    case $tool in
                        "tor") install_package "tor" ;;
                        "openvpn") install_package "openvpn" ;;
                        "ufw") install_package "ufw" ;;
                        "dnscrypt-proxy") install_package "dnscrypt-proxy" ;;
                        "exiftool") install_package "exiftool" ;;
                        "bleachbit") install_package "bleachbit" ;;
                        "keepassxc") install_package "keepassxc" ;;
                        "signal-desktop") install_package "signal-desktop" ;;
                        *) echo -e "${RED}[-] Unknown tool: $tool${NC}" ;;
                    esac
                else
                    echo -e "${GREEN}[+] $tool is already installed.${NC}"
                fi
                ;;
        esac
    done
}

install_package() {
    sudo apt update
    sudo apt install -y "$1"
}


install_package() {
    sudo apt update
    sudo apt install -y "$1"
}



# Menüler
echo -e "1. Clean Installation (Uninstall all and reinstall)"
echo -e "2. Install Missing Tools (Skip already installed tools)"
echo -e "3. Run Script Directly (Install everything)"
read -p "Enter your choice: " choice
echo " "

case $choice in
    1)  # Uninstall and reinstall all installed applications
        remove_all_tools
        install_all_tools
        ;;
    2)  # Install only missing tools
        echo -e "${YELLOW}Checking and installing missing tools...${NC}"
        echo
        check_installed
        ;;
    3)  # Install all tools directly
        echo -e "${YELLOW}Running script directly...${NC}"
        echo
        install_all_tools
        ;;
    *)
        echo -e "${RED}Invalid option! Exiting...${NC}"
        echo
        exit 1
        ;;
esac

echo -e "${GREEN}All selected actions completed!${NC}"


read -p "Would you like to proceed with the configuration setup? (yes/no): " run_config

if [[ "$run_config" == "yes" ]]; then
    if [[ -f "./configurator.sh" ]]; then
        echo -e "${BLUE}[+] Running configurator.sh...${NC}"
        chmod +x ./configurator.sh
        ./configurator.sh
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}[+] configurator.sh executed successfully!${NC}"
            echo " "
        else
            echo -e "${RED}[-] configurator.sh execution failed!${NC}"
            echo " "
        fi
    else
        echo -e "${RED}[-] configurator.sh not found in the current directory!${NC}"
        echo " "
    fi
else
    echo -e "${YELLOW}[!] Skipping configurator.sh execution.${NC}"
    echo " "
fi