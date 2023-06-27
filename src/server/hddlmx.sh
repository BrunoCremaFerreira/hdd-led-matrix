#!/bin/bash

_show_disk_error()
{
    stty -F $hdd_led_matrix_device -hupcl
    echo "err:$1" > $hdd_led_matrix_device
}

_show_installed_disks()
{
    stty -F $hdd_led_matrix_device -hupcl
    echo "disks:$1" > $hdd_led_matrix_device
}

_show_animation()
{
    stty -F $hdd_led_matrix_device -hupcl
    echo "0" > $hdd_led_matrix_device
}

_check_if_disks_are_present()
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
        echo "Error output: $matrix_data"
        _show_disk_error "$matrix_data"
        return 1
    fi

    return 0
}

_check_if_disk_failed_on_syslog()
{
    local syslog=""

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        syslog="/var/log/syslog"
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        syslog="/var/log/messages"
    else
        echo "Current OS is not supported!"
        exit 1
    fi

    # Search for disk errors on syslog
    local failures=$(grep -i "error" "$syslog" | grep -iE /dev/"$os_disk_pattern")

    if [[ -n "$failures" ]]; then
        echo "Failures found:"
        echo "$failures"
    else
        echo "No disk failures found in syslog."
    fi    
}

_load_configurations()
{
    local cfg_file="hddlmx.conf"

    if [ ! -f "$cfg_file" ]; then
        echo "The hddlmx.conf configuration file was not found!"
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

_show_help()
{
    echo "+------------Help------------+"
    echo "      -a  Matrix animation"
    echo "      -e  Check for disk errors"
    echo "      -h  Help"
    echo "      -i  Show installed disks"
    echo "      -t  Test the matrix"
}

_check_for_disk_errors()
{
    _check_if_disks_are_present
    if [[ $? == 1 ]]; then
    echo ""
    #    exit 0
    fi

    _check_if_disk_failed_on_syslog
}

_main()
{
    _load_configurations
    
    case $1 in
        -a) _show_animation ;;
        -e) _check_for_disk_errors ;;
        -i) _show_installed_disks ;;
        -t) _test_matrix ;;
         *)
            _show_help
            ;;
    esac
}

_main $1