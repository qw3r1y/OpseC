#!/bin/bash

# Colors
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m' # No Color

# Suricata configuration function
configure_suricata() {
    echo -e "${BLUE}[+] Starting Suricata configuration...${NC}"

    # List network interfaces
    echo -e "${YELLOW}[+] Available network interfaces:${NC}"
    ip link show | awk -F': ' '/^[0-9]/ {print $2}' | grep -v "lo" # Skip "lo" interface

    # Ask the user to select a network interface
    echo -e "${YELLOW}[?] Enter the network interface to be used by Suricata:${NC}"
    read -r interface

    # Check the user's input for the interface
    if ip link show "$interface" > /dev/null 2>&1; then
        echo -e "${BLUE}[+] $interface selected.${NC}"

        # Edit Suricata configuration file
        CONFIG_FILE="/etc/suricata/suricata.yaml"
        if [ -f "$CONFIG_FILE" ]; then
            echo -e "${YELLOW}[+] Editing $CONFIG_FILE file...${NC}"
            
            # Update interface settings in the Suricata configuration file
            sudo sed -i "s/^  - interface:.*$/  - interface: $interface/" "$CONFIG_FILE"

            # Restart Suricata
            echo -e "${BLUE}[+] Restarting Suricata...${NC}"
            sudo systemctl restart suricata

            echo -e "${GREEN}[+] Suricata configured successfully!${NC}"
        else
            echo -e "${RED}[!] $CONFIG_FILE not found! Is Suricata installed?${NC}"
        fi
    else
        echo -e "${RED}[!] $interface is an invalid network interface!${NC}"
    fi
}

# What is Firejail?
explain_firejail() {
    echo -e "${BLUE}[+] What is Firejail?${NC}"
    echo -e "${YELLOW}Firejail is a security tool for Linux used to sandbox applications. \
It limits applications' access permissions on the system, aiming to reduce \
the impact of malicious software. Basic commands: 'firejail <application>'.${NC}"
}

# Close critical ports with UFW
secure_ufw_ports() {
    echo -e "${BLUE}[+] Configuring UFW for critical ports...${NC}"
    
    # Block critical ports
    sudo ufw deny 22 > /dev/null 2>&1   # SSH
    sudo ufw deny 21 > /dev/null 2>&1   # FTP
    sudo ufw deny 3389 > /dev/null 2>&1  # RDP

    # Deny all incoming connections
    sudo ufw default deny incoming > /dev/null 2>&1

    # Allow outgoing connections
    sudo ufw default allow outgoing > /dev/null 2>&1

    # Reload UFW
    sudo ufw reload > /dev/null 2>&1

    echo -e "${GREEN}[+] Critical ports successfully closed!${NC}"
    echo -e "${GREEN}[+] All incoming connections denied, outgoing connections allowed.${NC}"
}

# Opensnitch manual start reminder
opensnitch_manual_start() {
    echo -e "${YELLOW}[!] You need to manually start the Opensnitch GUI application. To do this, type 'opensnitch-ui' in the terminal.${NC}"
}

# Activate DNSCrypt
activate_dnscrypt() {
    echo -e "${BLUE}[+] Activating dnscrypt-proxy...${NC}"
    
    # Enable dnscrypt-proxy
    sudo systemctl enable dnscrypt-proxy > /dev/null 2>&1
    sudo systemctl start dnscrypt-proxy > /dev/null 2>&1

    # Edit configuration file for dnscrypt-proxy settings
    echo -e "${BLUE}[+] Editing dnscrypt-proxy configuration file...${NC}"
    
    # Change server_names parameter to only use Cloudflare DNS
    sudo sed -i 's/^#server_names = \[.*\]$/server_names = \["cloudflare"\]/' /etc/dnscrypt-proxy/dnscrypt-proxy.toml

    # Restart dnscrypt-proxy
    sudo systemctl restart dnscrypt-proxy > /dev/null 2>&1
    
    echo -e "${GREEN}[+] dnscrypt-proxy successfully activated and configured!${NC}"
}

# Check and install vsftpd if needed
install_vsftpd_if_needed() {
    # Check vsftpd service status
    if ! systemctl is-active --quiet vsftpd; then
        echo -e "${BLUE}[+] vsftpd service not found, installing...${NC}"
        # Install vsftpd
        sudo apt update
        sudo apt install -y vsftpd
        sudo systemctl start vsftpd
        sudo systemctl enable vsftpd
        echo -e "${GREEN}[+] vsftpd successfully installed and started.${NC}"
    else
        echo -e "${GREEN}[+] vsftpd service is already installed and running.${NC}"
    fi
}

setup_fail2ban_rules() { 
    echo -e "${BLUE}[+] Configuring Fail2ban...${NC}"

    # Check vsftpd and install if not installed
    install_vsftpd_if_needed

    # Check if vsftpd log file exists, create it if not
    if [ ! -f /var/log/vsftpd.log ]; then
        echo -e "${BLUE}[+] Creating /var/log/vsftpd.log file...${NC}"
        sudo touch /var/log/vsftpd.log
        sudo chown root:root /var/log/vsftpd.log
        sudo chmod 644 /var/log/vsftpd.log
    fi

    # Create Fail2ban configuration file and add protection for various services
    sudo bash -c "cat > /etc/fail2ban/jail.local <<EOL
[DEFAULT]
bantime = 900         # Ban IP for 15 minutes
findtime = 600        # 10 minutes to reach maxretry
maxretry = 3          # Ban after 3 failed attempts

# SSH service protection
[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3

# FTP service protection (vsftpd)
[vsftpd]
enabled = true
port = ftp
logpath = /var/log/vsftpd.log
maxretry = 3

# HTTP/HTTPS service protection (Apache)
[apache-auth]
enabled = true
port = http,https
logpath = /var/log/apache*/*error.log
maxretry = 3

# SMTP service protection (Postfix)
[postfix]
enabled = true
port = smtp
logpath = /var/log/mail.log
maxretry = 3

# Other popular services (Dovecot IMAP/POP3)
[dovecot]
enabled = true
port = pop3,pop3s,imap,imaps
logpath = /var/log/mail.log
maxretry = 3
EOL"

    # Enable vsftpd logging configuration
    sudo bash -c "echo 'xferlog_enable=YES' >> /etc/vsftpd.conf"
    sudo bash -c "echo 'xferlog_file=/var/log/vsftpd.log' >> /etc/vsftpd.conf"
    sudo bash -c "echo 'xferlog_std_format=YES' >> /etc/vsftpd.conf"

    # Restart vsftpd service
    sudo systemctl restart vsftpd

    # Restart Fail2ban service
    sudo systemctl restart fail2ban > /dev/null 2>&1

    echo -e "${GREEN}[+] Fail2ban configuration completed successfully! SSH, FTP (vsftpd), HTTP, SMTP, and other services are protected.${NC}"
}

# Security scans interaction with the user
run_security_scans() {
    echo -e "${BLUE}[?] Would you like to perform security scans? (y/n):${NC}"
    read -r user_response
    if [[ "$user_response" =~ ^[Yy](es)?$ ]]; then
        # chkrootkit scan
        echo -e "${BLUE}[?] Would you like to perform a chkrootkit scan? (y/n):${NC}"
        read -r chkrootkit_response
        if [[ "$chkrootkit_response" =~ ^[Yy](es)?$ ]]; then
            echo -e "${YELLOW}[+] Starting chkrootkit scan...${NC}"
            sudo chkrootkit
        else
            echo -e "${YELLOW}[!] Skipped chkrootkit scan.${NC}"
        fi

        # rkhunter scan
        echo -e "${BLUE}[?] Would you like to perform a rkhunter scan? (y/n):${NC}"
        read -r rkhunter_response
        if [[ "$rkhunter_response" =~ ^[Yy](es)?$ ]]; then
            echo -e "${YELLOW}[+] Starting rkhunter scan...${NC}"
            sudo rkhunter --check
        else
            echo -e "${YELLOW}[!] Skipped rkhunter scan.${NC}"
        fi

        # ClamAV scan
        echo -e "${BLUE}[?] Would you like to perform a ClamAV scan? (y/n):${NC}"
        read -r clamav_response
        if [[ "$clamav_response" =~ ^[Yy](es)?$ ]]; then
            echo -e "${YELLOW}[+] Updating ClamAV database...${NC}"
            sudo freshclam
            echo -e "${YELLOW}[+] Starting ClamAV scan on home directory...${NC}"
            sudo clamscan -r /home --bell -i
        else
            echo -e "${YELLOW}[!] Skipped ClamAV scan.${NC}"
        fi
    else
        echo -e "${YELLOW}[!] Skipped security scans.${NC}"
    fi
}

# Tor configuration function
configure_tor() {
    echo -e "${BLUE}[+] Starting Tor configuration...${NC}"

    # Enable and start the Tor service
    echo -e "${BLUE}[+] Enabling Tor service...${NC}"
    sudo systemctl enable tor
    sudo systemctl start tor

    # Check and set Tor proxy settings
    echo -e "${YELLOW}[+] Checking proxy configuration for Tor...${NC}"
    local proxy_file="/etc/tor/torrc"
    if ! grep -q "SocksPort 9050" "$proxy_file"; then
        echo -e "${YELLOW}[+] Adding SocksPort 9050 setting...${NC}"
        sudo bash -c "echo 'SocksPort 9050' >> $proxy_file"
    fi

    echo -e "${GREEN}[+] Tor successfully configured! The proxy is available at 'localhost:9050' for all connections.${NC}"
}

user_custom_setup() {
    echo -e "${BLUE}[+] Welcome to the user configuration menu!${NC}"
    echo -e "${YELLOW}Please select an option:${NC}"
    echo "1) Learn about Firejail"
    echo "2) Close critical ports using UFW"
    echo "3) Reminder: Start Opensnitch manually"
    echo "4) Activate DNSCrypt"
    echo "5) Configure Fail2ban"
    echo "6) Configure Suricata (Network Interface Selection)"
    echo "7) Perform security scans"
    echo "8) Configure Tor"  # Option 8 now for Tor configuration
    echo "9) Run all configurations"  # New option for running all configurations
    echo "10) Exit"  # Option 10 for exiting the script
    echo -e "${YELLOW}Enter your choice (1-10):${NC}"
    read -r user_choice
    case $user_choice in
        1) explain_firejail ;;  # Firejail explanation function
        2) secure_ufw_ports ;;  # UFW configuration
        3) opensnitch_manual_start ;;  # Opensnitch reminder
        4) activate_dnscrypt ;;  # Activate DNSCrypt
        5) setup_fail2ban_rules ;;  # Configure Fail2ban
        6) configure_suricata ;;  # Suricata configuration
        7) run_security_scans ;;  # Perform security scans
        8) configure_tor ;;  # Configure Tor
        9) 
            echo -e "${BLUE}[+] Running all configurations...${NC}"
            # Execute all functions one by one
            explain_firejail
            secure_ufw_ports
            opensnitch_manual_start
            activate_dnscrypt
            setup_fail2ban_rules
            configure_suricata
            run_security_scans
            configure_tor
            echo -e "${GREEN}[+] All configurations have been applied successfully!${NC}"
            echo " "
            ;;
        10) 
            echo -e "${RED}[!] Exiting. Script terminated.${NC}" 
            echo " "
            exit 0 
            ;;
        *) 
            echo -e "${RED}[!] Invalid choice! Please enter a value between 1-10.${NC}"
            echo " " 
            ;;
    esac
}

# Script execution starts here
echo -e "${RED} ############# STARTING CONFIGURATION #############${NC}"
echo " "

while true; do
    user_custom_setup
done