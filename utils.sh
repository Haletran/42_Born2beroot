#!/bin/sh


#FONCTIONS
disk()
{
printf "DiskUsage: %s(%s)\n" "$(df -h / | awk 'NR==2 {print $3}') / $(df -h / | awk 'NR==2 {print $2}')" "$(df -h / | awk 'NR==2 {print $5}')"
}

internet()
{
wget -q --spider http://google.com

if [ $? -eq 0 ]; then
    printf "Internet: ONLINE\n"
else
    print "Internet: OFFLINE\n"
fi
}

Packages()
{
if command -v apt >/dev/null 2>&1; then
    package_manager="apt"
elif command -v yum >/dev/null 2>&1; then
    package_manager="yum"
elif command -v pacman >/dev/null 2>&1; then
    package_manager="pacman"
elif command -v zypper >/dev/null 2>&1; then
    package_manager="zypper"
else
    package_manager="unknown"
fi

if command -v dpkg >/dev/null 2>&1; then
    # Count the number of installed packages
    num_packages=$(dpkg --get-selections | grep -v deinstall | wc -l)

    printf "Packages: $num_packages ($package_manager)\n"
else
    echo "dpkg is not available. This script is designed for Debian-based systems."
fi
}
opsys()
{
if command -v lsb_release >/dev/null 2>&1; then
    os_name=$(lsb_release -si)
    printf "OS: $os_name\n"
else
    echo "lsb_release is not available. Unable to determine the operating system."
fi
}
cpu()
{
if [ -e "/proc/cpuinfo" ]; then
    # Get the CPU name using grep and awk
    cpu_name=$(grep -m1 "model name" /proc/cpuinfo | awk -F: '{print $2}' | xargs)
    cpu_phy=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
    vcpu=$(grep "^processor" /proc/cpuinfo | wc -l)
    printf "CPU:$ %s \n" "$cpu_name [Physical: $cpu_phy / VCPU: $vcpu]"
else
    echo "/proc/cpuinfo not found. Unable to determine CPU name."
fi
}
gpu()
{
if command -v lspci >/dev/null 2>&1; then
    # Get GPU information using lspci
    gpu_info=$(lspci | grep -i vga)
    
    if [ -n "$gpu_info" ]; then
        printf "GPU: $gpu_info\n"
    else
        echo "No GPU information found."
    fi
else
    echo "lspci is not available. Unable to determine GPU information."
fi
}
#MemUsed = Memtotal + Shmem - MemFree - Buffers - Cached - SReclaimable
