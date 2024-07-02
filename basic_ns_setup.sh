#!/bin/bash
log_directory="/home/luis/Documents/bash_scripts/nsconf_log"

logfile="$log_directory/log_$(date +"%Y-%m-%d_%H-%M-%S").txt"
touch "$logfile"
exec > >(tee "$logfile") 2>&1

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# 1 - Check for interfaces in the system and show them
interfaces=$(ip link show | awk -F: '$0 !~ "lo|vir|docker|wl|^[^0-9]"{print $2}' | sed 's/ //g')

echo $interfaces

# 2 - Check and rename ONU interface if needed
if [[ $interfaces == *"ONU"* ]]; then
    echo "ONU interface already exists."
elif [[ $interfaces == *"enx9c5322211774"* ]]; then
    sudo ip link set enx9c5322211774 down
    sudo ip link set enx9c5322211774 name jotaro
    sudo ip link set jotaro up
else
    echo "No suitable interface found for jotaro."
fi

# 3 - Check and rename OLT interface if needed
if [[ $interfaces == *"OLT"* ]]; then
    echo "OLT interface already exists."
elif [[ $interfaces == *"enx9c5322212df3"* ]]; then
    sudo ip link set enx9c5322212df3 down
    sudo ip link set enx9c5322212df3 name josuke
    sudo ip link set josuke up
else
    echo "No suitable interface found for josuke."
fi

# 3 - Check and rename OLT interface if needed
if [[ $interfaces == *"OLT"* ]]; then
    echo "OLT interface already exists."
elif [[ $interfaces == *"enx1c61b4dbd09e"* ]]; then
    sudo ip link set enx1c61b4dbd09e down
    sudo ip link set enx1c61b4dbd09e name giorno
    sudo ip link set giorno up
else
    echo "No suitable interface found for giorno."
fi

# 3 - Check and rename OLT interface if needed
if [[ $interfaces == *"OLT"* ]]; then
    echo "OLT interface already exists."
elif [[ $interfaces == *"enx30de4b49c07c"* ]]; then
    sudo ip link set enx30de4b49c07c down
    sudo ip link set enx30de4b49c07c name jolyne
    sudo ip link set jolyne up
else
    echo "No suitable interface found for jolyne."
fi

# 4 - Check and create nsONU namespace if needed
ip netns list | grep -q "platinum"
if [ $? -eq 1 ]; then
    sudo ip netns add platinum
fi

# 5 - Check and create nsOLT namespace if needed
ip netns list | grep -q "diamond"
if [ $? -eq 1 ]; then
    sudo ip netns add diamond
fi

# 5 - Check and create nsOLT namespace if needed
ip netns list | grep -q "gold"
if [ $? -eq 1 ]; then
    sudo ip netns add gold
fi

# 5 - Check and create nsOLT namespace if needed
ip netns list | grep -q "stone"
if [ $? -eq 1 ]; then
    sudo ip netns add stone
fi

# 6 - Set interfaces ONU and OLT down
sudo ip link set jotaro down
sudo ip link set josuke down
sudo ip link set giorno down
sudo ip link set jolyne down


sudo ip link set jotaro netns platinum 
sudo ip netns exec platinum ip addr add 10.10.10.3/24 dev jotaro
sudo ip netns exec platinum ip link set jotaro up     
sudo ip netns exec platinum ip ro ad default via 10.10.10.3
echo "Moved jotaro to namespace platinum"

sudo ip link set josuke netns diamond 
sudo ip netns exec diamond ip addr add 10.10.10.4/24 dev josuke
sudo ip netns exec diamond ip link set josuke up     
sudo ip netns exec diamond ip ro ad default via 10.10.10.4
echo "Moved josuke to namespace diamond"

sudo ip link set giorno netns gold 
sudo ip netns exec gold ip addr add 10.10.10.5/24 dev giorno
sudo ip netns exec gold ip link set giorno up     
sudo ip netns exec gold ip ro ad default via 10.10.10.5
echo "Moved giorno to namespace gold"

sudo ip link set jolyne netns stone 
sudo ip netns exec stone ip addr add 10.10.10.6/24 dev jolyne
sudo ip netns exec stone ip link set jolyne up     
sudo ip netns exec stone ip ro ad default via 10.10.10.6
echo "Moved jolyne to namespace stone"

