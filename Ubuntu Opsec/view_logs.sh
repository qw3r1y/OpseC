#!/bin/bash

# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Root check
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}You need root privileges to run this script.${RESET}"
    exit 1
fi
echo -e "${YELLOW}[!] Please make sure to configure your settings by selecting option 2 in the main menu. If not done, log monitoring may not work properly.${RESET}"

check_and_install_xterm() {
    if ! dpkg-query -l | grep -q "xterm"; then
        echo -e "${YELLOW}xterm is not installed. Installing...${RESET}"
        sudo apt update && sudo apt install -y xterm
        if dpkg-query -l | grep -q "xterm"; then
            echo -e "${GREEN}xterm has been successfully installed.${RESET}"
        else
            echo -e "${RED}xterm installation failed!${RESET}"
            exit 1
        fi
    else
        echo -e "${GREEN}xterm is already installed.${RESET}"
    fi
}
# Log file paths
OSSEC_LOG="/var/ossec/logs/alerts/alerts.log"
SURICATA_LOG="/var/log/suricata/fast.log"

# Service check and start function
check_and_start_service() {
    local SERVICE_NAME=$1
    local START_CMD=$2

    # Check if service is running
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${GREEN}$SERVICE_NAME is already running.${RESET}"
    else
        echo -e "${YELLOW}$SERVICE_NAME is not running. Starting...${RESET}"
        eval "$START_CMD"
        sleep 2  # Short wait after starting
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            echo -e "${GREEN}$SERVICE_NAME has been successfully started.${RESET}"
        else
            echo -e "${RED}$SERVICE_NAME could not be started!${RESET}"
        fi
    fi
}

# Check UFW status and start if needed
check_and_start_ufw() {
    if ufw status | grep -q inactive; then
        echo -e "${YELLOW}UFW is inactive. Starting...${RESET}"
        sudo ufw enable
        sleep 2  # Short wait after starting
        echo -e "${GREEN}UFW has been successfully started.${RESET}"
    else
        echo -e "${GREEN}UFW is already running.${RESET}"
    fi
}

# Open xterm to monitor OSSEC log file
open_ossec_log() {
    xterm -hold -e "bash -c 'echo -e \"${CYAN}Monitoring OSSEC logs ($OSSEC_LOG)...${RESET}\"; tail -f \"$OSSEC_LOG\"; exec bash'" &
}

# Open xterm to monitor Suricata log file
open_suricata_log() {
    xterm -hold -e "bash -c 'echo -e \"${CYAN}Monitoring Suricata logs ($SURICATA_LOG)...${RESET}\"; tail -f \"$SURICATA_LOG\"; exec bash'" &
}

# Open xterm to monitor DROP iptables rules
open_iptables_drop() {
    xterm -hold -e "bash -c 'echo -e \"${CYAN}Monitoring iptables DROP rules...${RESET}\"; sudo iptables -L --line-numbers | grep DROP; exec bash'" &
}

# Check dnscrypt service status
check_dnscrypt() {
    local SERVICE_NAME="dnscrypt-proxy"  # dnscrypt service name

    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${GREEN}$SERVICE_NAME is already running.${RESET}"
        echo " "
    else
        echo -e "${YELLOW}$SERVICE_NAME is not running. Starting...${RESET}"
        sudo systemctl start "$SERVICE_NAME"
        sleep 2  # Short wait after starting
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            echo -e "${GREEN}$SERVICE_NAME has been successfully started.${RESET}"
        else
            echo -e "${RED}$SERVICE_NAME could not be started!${RESET}"
        fi
    fi
}

# Check fail2ban status
check_fail2ban() {
    xterm -hold -e "bash -c 'echo -e \"${CYAN}Fail2Ban Status:${RESET}\"; sudo fail2ban-client status; exec bash'" &
}

# Check dnscrypt-proxy service status
check_dnscrypt_status() {
    xterm -hold -e "bash -c 'echo -e \"${CYAN}dnscrypt-proxy Service Status:${RESET}\"; systemctl status dnscrypt-proxy; exec bash'" &
}

# Main function
main() {
    # Check and start OSSEC and Suricata services

    check_and_install_xterm()
    check_and_start_service "ossec" "systemctl start ossec"
    check_and_start_service "suricata" "systemctl start suricata"

    # Check and start UFW
    check_and_start_ufw

    # Check dnscrypt service
    check_dnscrypt

    # Check fail2ban and dnscrypt-proxy status
    check_fail2ban
    check_dnscrypt_status

    # Open log files and monitor iptables DROP rules in separate terminal windows
    open_ossec_log
    open_suricata_log
    open_iptables_drop
}

# Run the script
main
