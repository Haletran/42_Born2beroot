#!/bin/bash

set -u

#ANSI COLORS
DEF_COLOR='\033[0;39m'
YELLOW='\033[0;93m'
BLUE='\033[0;94m'
CYAN='\033[0;96m'
NC='\033[0m'
RED='\033[0;31m'

#PASSWORD :
# P@ssw0rd123
#L1m!t3dP@ss
#Ch0c0l@t3C@ke
#R@1nb0w2Sky
#F1sh1ngT!m3
#S@lt&Pepp3r1
#G00dM0rn!ng!
#B@seb@llL0v3r
#W1nt3rW@nd3rl@nd
#H@pp1n3ss&J0y
#D@nc3InTh3Ra1n

#VARS
DISTRIB=$(lsb_release -a | grep Di | awk '{print $3}')

usage() {
  printf "\n${RED}Usage:${NC} $0 [-p1 <part1>] [-p2 <part2> ] [-b <bonus>]\n"
}

pres() {
  printf ${BLUE}"\n-------------------------------------------------------------\n"${DEF_COLOR};
  printf ${YELLOW}"\n\t\tSCRIPT CREATED BY: "${DEF_COLOR};
  printf ${CYAN}"bapasqui\t\n"${DEF_COLOR};
  printf ${YELLOW}"\t    Github : ${NC}https://github.com/Haletran\t\n"${DEF_COLOR};
  printf ${BLUE}"\n-------------------------------------------------------------\n"${DEF_COLOR};
}

while [ $# -gt 0 ]; do
  case "$1" in
    -p1 | --part1)
      if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root. (Using this command : su -)"
        exit 1
      fi
      pres
      # READ USER INPUT
      read -p $'\e[33mWhat is your username ?\e[0m ' USERNAME
      printf "${RED}~10 characters long, an uppercase letter, a lowercase letter, \nand a number, not 3 consecutive identical characters.\n${NC}"
      #read -p "Enter the password for user: " PASSWORD
      #read -p "Enter the password for root: " ROOT_PASSWORD

      #BASIC SETUP
      apt-get update && sudo apt-get upgrade -y
      apt-get install -y sudo
      if [ $? -eq 0 ]; then echo "sudo installed successfully."; else echo "Failed to install sudo."; fi
      apt-get install -y ufw vim net-tools libpam-pwquality
      groupadd user42
      if ! id "$USERNAME" &>/dev/null; then
        useradd -m -s /bin/bash "$USERNAME"
        #echo "$USERNAME:$PASSWORD" | chpasswd 
        #if [ $? -eq 0 ]; then echo "$USERNAME password changed successfully."; else echo "Failed to change $USERNAME password."; fi
      #else 
        #echo "$USERNAME:$PASSWORD" | chpasswd
        #if [ $? -eq 0 ]; then echo "$USERNAME password changed successfully."; else echo "Failed to change $USERNAME password."; fi
      fi

      usermod -aG sudo $USERNAME
      usermod -aG user42 $USERNAME
      hostnamectl set-hostname $USERNAME"42"

      #CHANGE SUDO PASSWORD
      #echo "root:$ROOT_PASSWORD" | chpasswd
      #if [ $? -eq 0 ]; then echo "Root password changed successfully."; else echo "Failed to change root password."; fi
      cp -r "../Born2Beroot" "/home/$USERNAME/"
      printf "Logout of root and $USERNAME.\n Login as $USERNAME and execute the second part of the script.\n (sudo ./setup.sh -p2)"
      ;;
  -p2 | --part2)
      if [ "$EUID" -ne 0 ]; then
        printf "Please run this script as sudo. \n(sudo bash setup.sh <parameters> or sudo ./setup.sh <parameters>)\n"
        exit 1
      fi
      pres

      #GET USERNAME
      USERNAME=$(whoami)
      
      #SETUP UFW
      echo "IPV6=yes" >> /etc/default/ufw
      sudo ufw default deny incoming
      sudo ufw allow 4242/tcp
      sudo ufw enable
      sudo systemctl start ufw
      
      #SETUP SSH
      if (systemctl is-active sshd.service | grep -q "active"); then
          echo "PORT 4242" >> /etc/ssh/sshd_config
      else 
          sudo systemctl enable ssh.service
          sudo systemctl start ssh.service
          echo "Port 4242" >> /etc/ssh/sshd_config	  
      fi
      echo "PermitRootLogin no" >> /etc/ssh/sshd_config
      systemctl restart ssh
      
      #SETUP PASSWORD EXPIRATION DATE AND POLICIES
      sed -i 's/PASS_MAX_DAYS	99999/PASS_MAX_DAYS	30/' /etc/login.defs
      sed -i 's/PASS_MIN_DAYS	0/PASS_MIN_DAYS	2/' /etc/login.defs
      sudo chage --mindays 2 --warndays 7 --maxdays 30 $USERNAME
      sudo chage --mindays 2 --warndays 7 --maxdays 30 root
      #/etc/login.defs
      sudo cp /etc/pam.d/common-password /etc/pam.d/common-password.bak
      sudo echo "password        requisite         pam_pwquality.so minlen=10 ucredit=-1 lcredit=-1 dcredit=-1 maxrepeat=3 difok=7 enforce_for_root reject_username" >> /etc/pam.d/common-password

      
      #SETUP SUDO
      read -p $'\e[33mCustom Message for failed Sudo password: \e[0m ' MESSAGE
      mkdir -p /var/log/sudo
      sudo echo "Defaults    passwd_tries=3" >> /etc/sudoers
      sudo echo "Defaults    badpass_message="$'\042'"$MESSAGE"$'\042' >> /etc/sudoers
      sudo echo "Defaults    logfile="$'\042'"/var/log/sudo/sudo.log"$'\042' >> /etc/sudoers
      sudo echo "Defaults    log_input, log_output" >> /etc/sudoers
      sudo echo "Defaults    requiretty" >> /etc/sudoers
      sudo echo "Defaults    secure_path="$'\042'"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"$'\042' >> /etc/sudoers
      sudo echo "$USERNAME  ALL=(ALL) NOPASSWD: /usr/local/bin/monitoring.sh" >> /etc/sudoers

      #SETUP CRONJOB
      mv monitoring.sh /usr/local/bin/monitoring.sh
      mv utils.sh /usr/local/bin/utils.sh
      crontab -u root -l > crontmp
      echo "*/10 * * * * bash /usr/local/bin/monitoring.sh | wall" > crontmp
      crontab -u root crontmp
      rm crontmp
      #crontab -u root -e
      #*/10 * * * * /usr/local/bin/monitoring.sh | wall (optionnal)

      printf "${YELLOW}Your $DISTRIB VM is ready, you might need to change your password if you didn't respect policy${NC}\n"
      ;;
  -b | --bonus)
      if [ "$EUID" -ne 0 ]; then
        printf "Please run this script as sudo. \n(sudo bash setup.sh <parameters> or sudo ./setup.sh <parameters>)\n"
        exit 1
      fi
      pres

      #INSTALL DEPENDENCIES
      sudo apt-get install lighttpd mariadb-server mariadb-client software-properties-common
      sudo add-apt-repository ppa:ondrej/php && sudo apt-get update
      sudo apt install php7.1-cgi php7.1-mcrypt php7.1-cli php7.1-mysql php7.1-gd php7.1-imagick php7.1-recode php7.1-tidy php7.1-xml php7.1-xmlrpc

      #SYSTEMCTL ENABLE AND START
      sudo systemctl start lighttpd.service
      sudo systemctl enable lighttpd.service
      sudo systemctl start mysql.service
      sudo systemctl enable mysql.service
      
      #SETUP DB
      sudo mysql_secure_installation
      sudo systemctl restart mysql.service

      #SETUP PHP
      sudo apt install -y apt-transport-https lsb-release ca-certificates wget 
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list 
      sudo apt update 
      #https://www.osradar.com/install-lighttpd-debian-10/
      #https://www.osradar.com/install-wordpress-with-lighttpd-debian-10/

      ;;
  -t | --test)
      if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root. (Using this command : su -)"
        exit 1
      fi
      #CHECK IF APP ARMOR or SELINUX IS ENABLED (for Debian 10< or for Rocky)
      if cat /etc/os-release | grep -q Debian; then 
      	if (cat /sys/module/apparmor/parameters/enabled | grep -q Y); then echo "AppArmor already enabled"; else echo "You need to enable AppArmor"; fi
      else
      	if (sestatus | grep -q enabled); then echo "SELINUX already enabled"; else echo "You need to enable SELINUX"; fi
      fi

      #CLONE AND USE TESTER
      git clone https://github.com/gemartin99/Born2beroot-Tester.git tester
      cd tester
      bash Test.sh
      ;;
  *)
      printf "${RED}Invalid option:${NC} $1"
	    usage
      exit 1
      ;;
  esac
  shift
done

