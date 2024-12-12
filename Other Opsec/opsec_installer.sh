#!/bin/bash


GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    echo -e "${RED}[!] ######### REMOVING ALL TOOLS #########${NC}"
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
    remove_package "firefox"
    remove_package "librewolf"
    remove_package "signal-desktop"
    remove_package "fail2ban"
    remove_package "snort"
    remove_package "rkhunter"
    remove_package "chkrootkit"
    remove_package "clamav"
    remove_package "suricata"
    remove_package "ossec-hids"
    
}

function show_progress() {
    echo -e "${YELLOW}👓 Installing $1, please wait...${NC}"
    # Simüle edilen ilerleme çubuğu
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

   
    echo -e "${YELLOW}[+] Installing necessary dependencies...${NC}"
    sudo apt-get update -y > /dev/null 2>&1
    sudo apt-get install -y build-essential wget tar > /dev/null 2>&1

    
    FIREJAIL_URL="https://github.com/netblue30/firejail/releases/download/0.9.72/firejail-0.9.72.tar.xz"
    TEMP_DIR="/tmp/firejail_install"
    mkdir -p "$TEMP_DIR" 
    cd "$TEMP_DIR" || { echo -e "${RED}[-] Failed to change to temporary directory.${NC}"; exit 1; }

    wget -O firejail.tar.xz "$FIREJAIL_URL"
    if [ $? -ne 0 ]; then
        echo -e "${RED}[-] Failed to download Firejail source code. Please check the URL.${NC}"
        exit 1
    fi

    
    if [ ! -w "$TEMP_DIR/firejail.tar.xz" ]; then
        echo -e "${RED}[-] No write permission for the file. Checking permissions...${NC}"
        sudo chmod 777 "$TEMP_DIR/firejail.tar.xz" 
    fi

    
    tar -xvf firejail.tar.xz > /dev/null 2>&1
    cd firejail-0.9.72 || { echo -e "${RED}[-] Failed to access the source code folder.${NC}"; exit 1; }
    ./configure > /dev/null 2>&1
    make > /dev/null 2>&1

    
    echo -e "${YELLOW}[+] Starting Firejail installation...${NC}"
    sudo make install > /dev/null 2>&1

    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] Firejail 0.9.72 installed successfully!${NC}"
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
    echo -e "${GREEN}[+] UFW configured successfully!${NC}"
}


setup_opensnitch() {
    echo -e "${BLUE}[+] Installing Opensnitch...${NC}"
    install_package "opensnitch"
    install_package "opensnitch-ui"
    sudo systemctl enable opensnitchd > /dev/null 2>&1
    sudo systemctl start opensnitchd > /dev/null 2>&1
    echo -e "${GREEN}[+] Opensnitch installed successfully!${NC}"
}

setup_tor_browser() {
    echo -e "${BLUE}[+] Installing Tor Browser...${NC}"

    
    TOR_BROWSER_URL="https://www.torproject.org/dist/torbrowser/14.0.3/tor-browser-linux-x86_64-14.0.3.tar.xz"

    
    wget -O tor-browser.tar.xz "$TOR_BROWSER_URL" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}[-] Failed to download Tor Browser. Please check the URL or your internet connection.${NC}"
        exit 1
    fi

    
    tar -xvf tor-browser.tar.xz > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}[-] Failed to extract Tor Browser file.${NC}"
        exit 1
    fi

    
    extracted_dir=$(find . -type d -name "tor-browser*" | head -n 1)

    if [ -d "$extracted_dir" ]; then
        cd "$extracted_dir" || { echo -e "${RED}[-] Failed to access Tor Browser folder.${NC}"; exit 1; }

        
        ./start-tor-browser.desktop --register-app > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[+] Tor Browser installed successfully!${NC}"
        else
            echo -e "${RED}[-] Failed to start Tor Browser.${NC}"
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
        echo -e "${GREEN}[+] KeePass installed successfully!${NC}"
    else
        echo -e "${RED}[-] Failed to install KeePass.${NC}"
    fi
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


setup_snort() {
    install_package "snort"
    echo -e "${GREEN}[+] Snort installed!${NC}"
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
    echo " "
    echo -e "${RED}[!] ######### INSTALLING ALL TOOLS #########${NC}"
    install_dependencies
    setup_tor
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
    setup_snort
    setup_ossec
    echo -e "${GREEN}[+] All tools installed successfully!${NC}"
    echo " "
}

check_installed() {
    tools=("tor" "openvpn" "ufw" "opensnitch" "dnscrypt-proxy" "exiftool" "bleachbit" "keepassxc" "signal-desktop" "fail2ban" "snort" "rkhunter" "chkrootkit" "clamav" "suricata" "firejail" "ossec-hids")

    for tool in "${tools[@]}"; do
        case $tool in
            "firejail")
                
                if ! which firejail > /dev/null 2>&1; then
                    echo -e "${YELLOW}[*] Firejail not installed. Installing now...${NC}"
                    setup_firejail
                else
                    echo -e "${GREEN}[+] Firejail is already installed.${NC}"
                fi
                ;;
            "ossec-hids")
                
                if [ ! -d "/var/ossec" ]; then
                    echo -e "${YELLOW}[*] OSSEC not installed. Installing now...${NC}"
                    setup_ossec
                else
                    echo -e "${GREEN}[+] OSSEC is already installed.${NC}"
                fi
                ;;
            "rkhunter")
                
                if ! which rkhunter > /dev/null 2>&1; then
                    echo -e "${YELLOW}[*] rkhunter not installed. Installing now...${NC}"
                    install_package "rkhunter"
                else
                    echo -e "${GREEN}[+] rkhunter is already installed.${NC}"
                fi
                ;;
            "chkrootkit")
                
                if ! which chkrootkit > /dev/null 2>&1; then
                    echo -e "${YELLOW}[*] chkrootkit not installed. Installing now...${NC}"
                    install_package "chkrootkit"
                else
                    echo -e "${GREEN}[+] chkrootkit is already installed.${NC}"
                fi
                ;;
            "clamav")
                
                if ! which clamscan > /dev/null 2>&1; then
                    echo -e "${YELLOW}[*] ClamAV not installed. Installing now...${NC}"
                    install_package "clamav"
                else
                    echo -e "${GREEN}[+] ClamAV is already installed.${NC}"
                fi
                ;;
            "suricata")
                
                if ! which suricata > /dev/null 2>&1; then
                    echo -e "${YELLOW}[*] suricata not installed. Installing now...${NC}"
                    install_package "suricata"
                else
                    echo -e "${GREEN}[+] suricata is already installed.${NC}"
                fi
                ;;
            *)
                
                if ! dpkg -l | grep -q "$tool"; then
                    echo -e "${YELLOW}[*] $tool not installed. Installing now...${NC}"
                    case $tool in
                        "tor") setup_tor ;;
                        "openvpn") setup_vpn ;;
                        "ufw") setup_ufw ;;
                        "opensnitch") setup_opensnitch ;;
                        "dnscrypt-proxy") setup_dnscrypt ;;
                        "exiftool") setup_exiftool ;;
                        "bleachbit") setup_bleachbit ;;
                        "keepassxc") setup_keepass ;;
                        "signal-desktop") setup_signal ;;
                        "fail2ban") setup_fail2ban ;;
                        "snort") setup_snort ;;
                        *) echo -e "${RED}[-] Unknown tool: $tool${NC}" ;;
                    esac
                else
                    echo -e "${GREEN}[+] $tool is already installed.${NC}"
                fi
                ;;
        esac
    done
}




echo -e "${BLUE}Select an option:${NC}"
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
        check_installed
        ;;
    3)  # Install all vehicles directly
        echo -e "${YELLOW}Running script directly...${NC}"
        install_all_tools
        ;;
    *)
        echo -e "${RED}Invalid option! Exiting...${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}######## ALL SELECTED ACTIONS COMPLETED! ########${NC}"



read -p "Would you like to proceed with the configuration setup? (yes/no): " run_config

if [[ "$run_config" == "yes" ]]; then
    if [[ -f "./configurator.sh" ]]; then
        echo -e "${BLUE}[+] Running configurator.sh...${NC}"
        chmod +x ./configurator.sh
        ./configurator.sh
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}[+] configurator.sh executed successfully!${NC}"
        else
            echo -e "${RED}[-] configurator.sh execution failed!${NC}"
        fi
    else
        echo -e "${RED}[-] configurator.sh not found in the current directory!${NC}"
    fi
else
    echo -e "${YELLOW}[!] Skipping configurator.sh execution.${NC}"
    echo " "
fi
