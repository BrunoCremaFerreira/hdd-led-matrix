#!/bin/bash

# -- Configurations
export HDD_LED_MATRIX_DEVICE=/dev/ttyACM0
export DISK_POSITION_MATRIX="[sda,sdb,sdc,sdd], [0,0,sdx,0],[0,0,0,0]"
# --

_get_device_names()
{
    lsblk --output name --nodeps --sort NAME --include 8 -nd
}

_show_disk_error()
{
    stty -F /dev/ttyACM0 -hupcl
    echo "err:$1" > $HDD_LED_MATRIX_DEVICE
}

_show_installed_disks()
{
    stty -F /dev/ttyACM0 -hupcl
    echo "disks:$1" > $HDD_LED_MATRIX_DEVICE
}

_show_animation()
{
    stty -F /dev/ttyACM0 -hupcl
    echo "0" > $HDD_LED_MATRIX_DEVICE
}

_check_if_disks_is_present()
{  
    local has_error=0

    # List all disks installed
    local hds_instalados=$(ls /dev/sd[a-z] 2>/dev/null)

    # Define initial value to matrix_data
    local matrix_data="$DISK_POSITION_MATRIX"

    # Extract disks from initial matrix_data
    local hds_string=$(echo "$matrix_data" | grep -oP '\b(sd[a-z]|s[0-9])\b')

    # Change disk names from initial matrix_data
    for hd in $hds_string; do
    if [[ $hds_instalados =~ $hd ]]; then
        matrix_data="${matrix_data//$hd/0}"
    else
        matrix_data="${matrix_data//$hd/1}"
        has_error=1
    fi
    done

    if [[ $has_error == 1 ]]; then
        echo "$matrix_data"
        _show_disk_error "$matrix_data"
    fi
}

_test_matrix()
{
    echo "Simulating disk error:"
    echo "  .   *   .   ."
    echo "  *   .   .   ." 
    echo "  .   .   *   ."
    _show_disk_error "[0,1,0,0] [1,0,0,0] [0,0,1,0]"
    sleep 10

    echo "Simulating disk Installed Position:"
    echo "  *   .   *   *"
    echo "  .   *   *   *" 
    echo "  *   *   .   *"
    _show_installed_disks "[1,0,1,1], [0,1,1,1] [1,1,0,1]"
    sleep 10

    echo "Simulating normal disk activity"
    _show_animation

    echo "Done."
}

_main()
{
    #_test_matrix
    _check_if_disks_is_present
}

_main