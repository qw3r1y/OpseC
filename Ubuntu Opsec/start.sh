#!/bin/bash


clear


echo -e "\e[1;34m"
echo "  OOOOO   PPPPPP   SSSSS   EEEEE   CCCCC  "
echo " O     O  P    P  S       E       C       "
echo " O     O  PPPPPP  SSSSS   EEEE    C       "
echo " O     O  P       S       E       C       "
echo "  OOOOO   P       SSSSS   EEEEE   CCCCC  "
echo -e "\e[0m"  

echo -e "\e[1;33m           OPSEC Menu \e[0m"
echo
echo "1) Install Tools"
echo "2) Configure Settings"
echo "3) Show Logs"
echo "4) Exit"
echo
read -p "Please choose an option (1/2/3/4): " secim
echo


case $secim in
    1)
        
        if [ -f "opsec_installer.sh" ]; then
            bash opsec_installer.sh
        else
            echo "opsec_installer.sh file not found!"
        fi
        
        echo -e "\e[1;31m########### RETURN TO MAIN MENU ###########\e[0m"
        echo -e "\e[1;32mPress Enter to return to the main menu...\e[0m"
        echo -e "\e[1;31m########### RETURN TO MAIN MENU ###########\e[0m"
        read -p ""
        exec "$0"  
        ;;
    2)
        
        if [ -f "configurator.sh" ]; then
            echo " "
            bash configurator.sh
        else
            echo "configurator.sh file not found!"
        fi
        
        echo -e "\e[1;31m########### RETURN TO MAIN MENU ###########\e[0m"
        echo -e "\e[1;32mPress Enter to return to the main menu...\e[0m"
        echo -e "\e[1;31m########### RETURN TO MAIN MENU ###########\e[0m"
        read -p ""
        exec "$0"  
        ;;
    3)
        
        if [ -f "view_logs.sh" ]; then
            sudo bash view_logs.sh
        else
            echo "view_logs.sh file not found!"
        fi
        
        echo -e "\e[1;31m########### RETURN TO MAIN MENU ###########\e[0m"
        echo -e "\e[1;32mPress Enter to return to the main menu...\e[0m"
        echo -e "\e[1;31m########### RETURN TO MAIN MENU ###########\e[0m"
        read -p ""
        exec "$0"  
        ;;
    4)
        
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid selection! Please choose a valid option (1/2/3/4)."
        
        echo -e "\e[1;31m########### RETURN TO MAIN MENU ###########\e[0m"
        echo -e "\e[1;32mPress Enter to return to the main menu...\e[0m"
        echo -e "\e[1;31m########### RETURN TO MAIN MENU ###########\e[0m"
        read -p ""
        exec "$0" 
        ;;
esac
