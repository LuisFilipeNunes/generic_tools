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
    sudo ip link set enx9c5322211774 name JOTARO
    sudo ip link set JOTARO up
else
    echo "No suitable interface found for JOTARO."
fi

# 3 - Check and rename OLT interface if needed
if [[ $interfaces == *"OLT"* ]]; then
    echo "OLT interface already exists."
elif [[ $interfaces == *"enx9c5322212df3"* ]]; then
    sudo ip link set enx9c5322212df3 down
    sudo ip link set enx9c5322212df3 name JOSUKE
    sudo ip link set JOSUKE up
else
    echo "No suitable interface found for JOSUKE."
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

# 6 - Set interfaces ONU and OLT down
sudo ip link set JOTARO down
sudo ip link set JOSUKE down

# 7 - Create VLAN interfaces for ONU
for vlan_id in 101 102 103 104 105 106 107 108 109 110; do
    if ! sudo ip netns exec platinum ip link show | grep -q "JOTARO$vlan_id"; then
        sudo ip link add link JOTARO name JOTARO$vlan_id type vlan id $vlan_id

    fi
done

# 8 - Create VLAN interfaces for OLT
for vlan_id in 101 102 103 104 105 106 107 108 109 110; do
    if ! sudo ip netns exec diamond ip link sh | grep -q "JOSUKE$vlan_id"; then
        sudo ip link add link JOSUKE name JOSUKE$vlan_id type vlan id $vlan_id

    fi
done

# 9 - Move VLAN interfaces to namespaces

for vlan_id in 101 102 103 104 105 106 107 108 109 110; do
    if ! sudo ip netns exec diamond ip link sh | grep -q "JOSUKE$vlan_id"; then
        if ! ip link show | grep -q "JOSUKE$vlan_id "; then
            sudo ip link set JOSUKE$vlan_id netns diamond
            echo "Moved JOSUKE$vlan_id to namespace diamond"
            sudo ip netns exec diamond ip addr add 10.10.10.$((vlan_id-30))/24 dev JOSUKE$vlan_id
        fi
    fi
done


for vlan_id in 101 102 103 104 105 106 107 108 109 110; do
    if ! sudo ip netns exec platinum ip link show | grep -q "JOTARO$vlan_id"; then
        if ! ip link show | grep -q "JOTARO$vlan_id "; then
            sudo ip link set JOTARO$vlan_id netns platinum
            sudo ip netns exec platinum ip addr add 10.10.10.$((vlan_id-90))/24 dev JOTARO$vlan_id
            echo "Moved JOTARO$vlan_id to namespace platinum"
        fi
    fi
done


interfaces_onu=$(sudo ip netns exec platinum ip link show | awk -F: '$0 !~ "lo|vir|docker|wl|^[^0-9]"{print $2}' | sed 's/ //g')
interfaces_olt=$(sudo ip netns exec diamond ip link show | awk -F: '$0 !~ "lo|vir|docker|wl|^[^0-9]"{print $2}' | sed 's/ //g')

function enumerate_interfaces() {
    local interfaces="$1"
    local index=1
    for interface in $interfaces; do
        echo "$index - $interface"
        ((index++))
    done
}

echo "Jotaro Platinum interface List:"
enumerate_interfaces "$interfaces_onu"

echo "Josuke Diamond interface List:"
enumerate_interfaces "$interfaces_olt"

echo "Script execution completed."
