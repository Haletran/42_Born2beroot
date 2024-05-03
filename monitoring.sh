#!/bin/bash

#OTHERS USEFULS SCRIPTS
source utils.sh
terminal_name=$(tty)
kernel=$(uname -r)
host=$(hostname)
inter=$(ip -4 addr | grep 3: | awk '{print $2}' | sed 's/.$//')

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

set -u

usage() {
  printf "Usage: $0 [-a <architecture>] [-c <cpu] ... [--all]"
}


while [ $# -gt 0 ]; do
  case "$1" in
    -a|--architecture)
      printf "${GREEN}Architecture:${NC} $(uname -a)"
      ;;
    -c|--cpu-physical)
      printf "${GREEN}CPU physical:${NC} $(nproc --all)"
      ;;
    -vc|--vcpu)
      "${GREEN}vCPU:${NC} $(cat /proc/cpuinfo | grep processor | wc -l)"
      ;;
    -m|--memory-usage)
      printf "${GREEN}Memory Usage:${NC} $(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')"
      ;;
    -d|--disk-usage)
      printf "${GREEN}Disk Usage:${NC} $(df -h | grep sda1 | awk '{print $3}')/$(df -h | grep sda1 | awk '{print $2}') ($(df -h | grep sda1 | awk '{print $5}'))"
      ;;
    -cl|--cpu-load)
      printf "${GREEN}CPU load:${NC} $(top -bn1 | awk '/Cpu/ { print $2}')%"
      ;;
    -lb|--last-boot)
      printf "${GREEN}Last boot:${NC} $(last reboot | head -n 1 | awk '{print $5, $6, $7, $8}')"
      ;;
    -lvm|--lvm-use)
	  if lsblk | grep -q "lvm"; then printf "${GREEN}LVM use:${NC} yes"; else printf "${GREEN}LVM use:${NC} no"; fi
      ;;
    -tc|--tcp-connections)
      printf "${GREEN}Connection TCP:${NC} $(ss -neopt state established | wc -l)"
      ;;
    -ul|--user-log)
      printf "${GREEN}User log:${NC} $(users | wc -w)"
      ;;
    -n|--network)
      printf "${GREEN}Network:${NC} IP $(ip -4 addr show dev eno1 | awk '/inet / {print $2}') $(ip address | grep ether | head -n 1 | awk '{print $2}')"
      ;;
    -s|--sudo)
      printf "${GREEN}Sudo:${NC} $(journalctl -q _COMM=sudo | grep COMMAND | wc -l)"
      ;;
    --allc)
printf "${RED}====${NC}HARDWARE INFORMATION${RED}====${NC}\n"
cpu
printf "${GREEN}CPU physical:${NC} $(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)\n"
printf "${GREEN}vCPU:${NC} $(grep "^processor" /proc/cpuinfo | wc -l)\n"
printf "${GREEN}CPU load: ${NC}%s%%\n" "$(top -bn1 | awk '/Cpu/ { print $2}')"
gpu
printf "${GREEN}RAM:${NC} %s/%s\n" "$(free -m | grep Mem | awk '{print $3}')" "$(free -m | grep Mem | awk '{print $2}')GB"
disk
printf "${RED}====${NC}SOFTWARE INFORMATION${RED}====${NC}\n"
opsys
printf "${GREEN}Host:${NC} $host\n"
printf "${GREEN}Kernel:${NC} $kernel\n"
printf "${GREEN}Shell:${NC} $terminal_name\n" 
Packages
printf "${RED}====${NC}SYSTEM INFORMATION${RED}====${NC}\n"
printf "${GREEN}Architecture:${NC} $(uname -o -p )\n"
printf "${GREEN}Date:${NC} $(date)\n"
printf "${GREEN}Last Reboot:${NC} $(last reboot | head -n 1 | awk '{print $5, $6, $7, $8}')\n"
printf "${GREEN}Uptime:${NC} $(uptime -p)\n"
printf "${GREEN}Locale:${NC} $(locale | grep "LANG=" | awk -F= '{print $2}')\n"
printf "${GREEN}Sudo:${NC} $(journalctl -q _COMM=sudo | grep COMMAND | wc -l)\n"
printf "${RED}====${NC}INTERNET INFORMATION${RED}====${NC}\n"
internet
printf "${GREEN}IP: ${NC}$(ip -4 addr show dev ${inter}| awk '/inet / {print $2}')\n"
printf "${GREEN}MAC: ${NC}$(ip address | grep ether | head -n 1 | awk '{print $2}')\n"
printf "${GREEN}Connection TCP:${NC} $(ss -neopt state established | wc -l)\n"
printf "${GREEN}User log:${NC} $(users | wc -w)\n"
printf "${RED}====${NC}SERVICES STATUS${RED}====${NC}\n"
if systemctl is-active --quiet "ssh"; then printf "${GREEN}SSH:${NC} Running\n" ; else printf "${GREEN}SSH:${NC} Not Running\n"; fi
if systemctl is-active --quiet "vsftpd"; then printf "FTP: Running\n" ; else printf "FTP: Not Running\n"; fi
if systemctl is-active --quiet "ufw"; then printf "${GREEN}UFW:${NC} Running\n" ; else printf "${GREEN}UFW:${NC} Not Running\n"; fi
if lsblk | grep -q "lvm"; then printf "${GREEN}LVM use:${NC} yes\n"; else printf "${GREEN}LVM use:${NC} no\n"; fi
printf "${RED}============================${NC}\n"
      ;;
    --all)
printf "====HARDWARE INFORMATION====\n"
cpu
printf "CPU physical: $(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)\n"
printf "vCPU: $(grep "^processor" /proc/cpuinfo | wc -l)\n"
printf "CPU load: %s%%\n" "$(top -bn1 | awk '/Cpu/ { print $2}')"
gpu
printf "RAM: %s/%s\n" "$(free -m | grep Mem | awk '{print $3}')" "$(free -m | grep Mem | awk '{print $2}')GB" "$(
disk
printf "====SOFTWARE INFORMATION====\n"
opsys
printf "Host: $host\n"
printf "Kernel: $kernel\n"
printf "Shell: $terminal_name\n" 
Packages
printf "====SYSTEM INFORMATION====\n"
printf "Architecture: $(uname -o -p )\n"
printf "Date: $(date)\n"
printf "Last Reboot: $(last reboot | head -n 1 | awk '{print $5, $6, $7, $8}')\n"
printf "Uptime: $(uptime -p)\n"
printf "Locale: $(locale | grep "LANG=" | awk -F= '{print $2}')\n"
printf "Sudo: $(journalctl -q _COMM=sudo | grep COMMAND | wc -l)\n"
printf "====INTERNET INFORMATION====\n"
internet
printf "IP: $(ip -4 addr show dev ${inter}| awk '/inet / {print $2}')\n"
printf "MAC: $(ip address | grep ether | head -n 1 | awk '{print $2}')\n"
printf "Connection TCP: $(ss -neopt state established | wc -l)\n"
printf "User log: $(users | wc -w)\n"
printf "====SERVICES STATUS====\n"
if systemctl is-active --quiet "ssh"; then printf "SSH: Running\n" ; else printf "SSH: Not Running\n"; fi
if systemctl is-active --quiet "vsftpd"; then printf "FTP: Running\n" ; else printf "FTP: Not Running\n"; fi
if systemctl is-active --quiet "ufw"; then printf "UFW: Running\n" ; else printf "UFW: Not Running\n"; fi
if lsblk | grep -q "lvm"; then printf "LVM use: yes\n"; else printf "LVM use: no\n"; fi
printf "============================\n"
      ;;
    *)
      printf "${RED}Invalid option: $1${NC}"
	    usage
      exit 1
      ;;
  esac
  shift
done
