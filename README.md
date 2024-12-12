# OPSEC Tools 🛡️

This tool consists of 4 different bash scripts designed to help you configure, manage and monitor your security-focused systems. Below you can find detailed information about the tool and instructions for use.

## Getting Started 🚀

Before running the tool, you need to grant the necessary permissions to all files. You can do this as follows:

```bash
chmod +x *
./start.sh
```
<p align="center"> <img src="https://github.com/user-attachments/assets/4e2ac820-b9fb-4812-bf43-e64984b02b4c" alt="opsecmenu" width="400"/> </p>


-------------------------------------------------------------------------------
After running the `start.sh` file, you will see 3 options:

### 1. Installing Required Files 📥

This option installs the following tools required for the OPSEC tool:

- **Strongswan**: Secure VPN connections.
- **Tor**: Anonymizing tool for internet privacy.
- **Suricata**: Network-based threat detection and prevention.
- **Chkrootkit**: Rootkit detection.
- **Rkhunter**: Rootkit detection and system auditing.
- **ClamAV**: Virus scanning and malware analysis.
- **Firejail**: Application isolation.
- **VPN Settings**: VPN configuration for secure connections.
- **Tor Browser**: Anonymous web browsing.
- **UFW**: Simple firewall.
- **OpenSnitch**: Outbound connection monitoring.
- **DNSCrypt**: DNS traffic encryption.
- **ExifTool**: File metadata editing.
- **BleachBit**: Disk cleaning and privacy tool.
- **KeePass**: Password management.
- **Signal**: Secure messaging app.
- **Fail2Ban**: Protection against brute-force attacks.
- **OSSEC**: Host-based security and log analysis.


There are three sub-options in this section:

1. **Clean Installation:**
- If there are previously installed files on your system, it removes them and performs a clean installation from scratch.

2. **Installing Missing Tools:**
- Checks if the tools are available on your system and installs the missing ones.
- Completes the following missing tools:
  - **Strongswan, Tor, Suricata, Chkrootkit, Rkhunter, ClamAV, Firejail, VPN Settings, Tor Browser, UFW, OpenSnitch, DNSCrypt, ExifTool, BleachBit, KeePass, Signal, Fail2Ban, OSSEC.**

3. **Installing All Tools:**
- Reinstalls all the following tools regardless of whether they are present on your system:
  - **Strongswan, Tor, Suricata, Chkrootkit, Rkhunter, ClamAV, Firejail, VPN Settings, Tor Browser, UFW, OpenSnitch, DNSCrypt, ExifTool, BleachBit, KeePass, Signal, Fail2Ban, OSSEC.**

<p align="center">
  <img src="https://github.com/user-attachments/assets/8ba2cb9c-39c6-4796-99f9-c01fa3d67c70" alt="2" width="400"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/189aaefe-9d7a-4cb7-ad57-0de57d8edd04" alt="3" width="400"/>
</p>

-------------------------------------------------------------------------------------

### 2. Config Settings Menu ⚙️

With this option, you can access the configuration settings of the above installed tools. You can customize certain tools as you wish or apply default settings for all tools.

- **Automatic Settings:**
  - Remote access ports (SSH, FTP, etc.) such as 22, 21, 3389 are closed.
  - The system is protected against brute force attacks.
  - DNSCrypt tool is enabled.

- **Tool Settings:**
  - **Firejail**: Application isolation is configured and its usage is explained.
  - **UFW**: Ports are configured for a simple and effective firewall tool.
  - **OpenSnitch**: Outbound connection monitoring tool is reminded to start manually.
  - **DNSCrypt**: Encryption of DNS traffic is enabled.
  - **Fail2Ban**: Protection rules against brute force attacks are configured.
  - **Suricata**: Network-based threat detection and prevention tool is configured.
  - **Security Scans**: Scans are performed for system security.
  - **Tor**: Tor is configured for privacy and anonymity.
 
![4](https://github.com/user-attachments/assets/4a86e3a9-056c-44cf-8fde-992397fa7568)

----------------------------------------------------------------
### 3. View Logs and Active Rules 📊

With this option, you can see the logs and active security rules from the tools installed on the system.

- **Suricata and OSSEC Logs:**
  - You can detect suspicious activities on the system.

- **Closed Ports and Rules:**
  - You can view the ports that are closed to unauthorized access and active security rules.

- **Dnscrypt Enablement:**
  - Allows you to see whether Dnscrypt is enabled or not.
    
![5](https://github.com/user-attachments/assets/954f1332-bda1-4b43-8a59-5f724f2fba5f)

-------------------------------------------------------------------------------
## Usage Notes 📝

  - The tool is designed to work on Linux-based systems.
  - Make sure that the necessary permissions are granted before running the `start.sh` file.
  - For more information about the installed tools and configurations, you can review the documentation of the relevant tools.
