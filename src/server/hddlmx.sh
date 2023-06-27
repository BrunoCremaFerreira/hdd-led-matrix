#!/bin/bash

_get_device_names()
{
    lsblk --output name --nodeps --sort NAME --include 8 -nd
}

_show_disk_error()
{
    stty -F /dev/ttyACM0 -hupcl
    echo "err:$1" > $hdd_led_matrix_device
}

_show_installed_disks()
{
    stty -F /dev/ttyACM0 -hupcl
    echo "disks:$1" > $hdd_led_matrix_device
}

_show_animation()
{
    stty -F /dev/ttyACM0 -hupcl
    echo "0" > $hdd_led_matrix_device
}

_check_if_disks_is_present()
{  
    local has_error=0

    # List all disks installed
    local hds_instalados=$(ls /dev/$os_disk_pattern 2>/dev/null)

    # Define initial value to matrix_data
    local matrix_data="$disk_position_matrix"

    # Extract disks from initial matrix_data
    local hds_string=$(echo "$matrix_data" | grep -oP "\b($os_disk_pattern)\b")

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
        return 1
    fi

    return 0
}

_load_configurations()
{
    local cfg_file="hddlmx.conf"

    if [ ! -f "$cfg_file" ]; then
        echo "O arquivo de configuração não foi encontrado."
        exit 1
    fi

    readonly disk_position_matrix=$(grep -oP 'DISK_POSITION_MATRIX=\K.*' "$cfg_file")
    readonly os_disk_pattern=$(grep -oP 'OS_DISK_PATTERN=\K.*' "$cfg_file")
    readonly hdd_led_matrix_device=$(grep -oP 'HDD_LED_MATRIX_DEVICE=\K.*' "$cfg_file")
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
    _load_configurations
    _check_if_disks_is_present
    sleep 10
    _test_matrix
}

_main $1