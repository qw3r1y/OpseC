# OPSEC Tools 🛡️

This tool consists of 4 different bash scripts designed to help you configure, manage and monitor your security-focused systems. Below you can find detailed information about the tool and instructions for use.

## Getting Started 🚀

Before running the tool, you need to grant the necessary permissions to all files. You can do this as follows:

```bash
chmod +x *
./start.sh
```

After running the `start.sh` file, you will see 3 options:

### 1. Installing Required Files 📥

This option installs the following tools required for the OPSEC tool:

- **Strongswan**: A tool used for secure VPN connections.
- **Tor**: Anonymizing tool for Internet privacy.
- **Suricata**: A network-based threat detection and prevention tool.
- **Chkrootkit**: A tool used for rootkit detection.
- **Rkhunter**: Provides rootkit detection and system security auditing.
- **ClamAV**: Virus scanning and malware analysis.
- **Firejail**: A security tool that provides application isolation.
- **VPN Settings**: Configure VPN for secure connection.
- **Tor Browser**: Anonymous web browsing.
- **UFW (Uncomplicated Firewall)**: A simple and effective firewall tool.
- **OpenSnitch**: Outbound connection monitoring.
- **DNSCrypt**: A tool used to encrypt DNS traffic.
- **ExifTool**: Edits and displays file metadata.
- **BleachBit**: Disk cleaning and privacy protection tool.
- **KeePass**: A software for password management.
- **Signal**: Secure messaging app.
- **Fail2Ban**: Protection against brute force attacks.
- **OSSEC**: Host-based security and log analysis tool.

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

### 3. View Logs and Active Rules 📊

With this option, you can see the logs and active security rules from the tools installed on the system.

- **Suricata and OSSEC Logs:**
- You can detect suspicious activities on the system.

- **Closed Ports and Rules:**
- You can view the ports that are closed to unauthorized access and active security rules.

- **Dnscrypt Enablement:**
- Allows you to see whether Dnscrypt is enabled or not.

## Usage Notes 📝

- The tool is designed to work on Linux-based systems.
- Make sure that the necessary permissions are granted before running the `start.sh` file.
- For more information about the installed tools and configurations, you can review the documentation of the relevant tools.
