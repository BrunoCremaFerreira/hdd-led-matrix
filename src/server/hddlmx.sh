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

_check_root_access()
{
  # Check is the current user is root
    if [[ $EUID -ne 0 ]]; then
        echo "This script needs to be run as root."
        exit 1
    fi  
}

_perform_or_operation() 
{
  local string1=$1
  local string2=$2
  local result=""

  # Splits strings into arrays, removing non-numeric characters
  array1=($(echo "$string1" | tr -cd '0-1 '))
  array2=($(echo "$string2" | tr -cd '0-1 '))

  # Check the size of arrays
  size1=${#array1[@]}
  size2=${#array2[@]}

  # Checks if arrays are the same size
  if [[ $size1 -ne $size2 ]]; then
    echo "Strings have different lengths. Unable to perform the operation."
    return
  fi

  # Performs the OR operation on the numbers 0 and 1
  for ((i=0; i<size1; i++)); do
    if [[ ${array1[i]} -eq 1 || ${array2[i]} -eq 1 ]]; then
      result+="1,"
    else
      result+="0,"
    fi
  done

  # Remove the final comma
  result=${result%,}

  echo "$result"
}

_check_if_disks_are_present()
{  
    # List all disks installed
    local installed_disks=$(ls /dev/$os_disk_pattern 2>/dev/null)

    # Define initial value to matrix_data
    local matrix_data="$disk_position_matrix"

    # Extract disks from initial matrix_data
    local hds_string=$(echo "$matrix_data" | grep -oP "\b($os_disk_pattern)\b")

    # Change disk names from initial matrix_data
    for hd in $hds_string; do
    if [[ $installed_disks =~ $hd ]]; then
        matrix_data="${matrix_data//$hd/0}"
    else
        matrix_data="${matrix_data//$hd/1}"
    fi
    done

    echo "$matrix_data"
}

_replace_disks() {
  local disks=$1
  local result=$2

  # Iterates over the disks in the string
  for disk in $(echo "$disks" | tr ' ' '\n'); do
    # Checks if the disk exists in the variable disks_with_errors
    if [[ $disks =~ $disk ]]; then
      result=$(echo "$result" | sed "s/$disk/1/g")
    else
      result=$(echo "$result" | sed "s/$disk/0/g")
    fi
  done

  echo "$result"
}

_check_if_disk_failed_with_smartctl()
{
    # Run smartctl command to list disks with errors
    local disks_with_errors=$(smartctl --scan | awk '{print $1}' | xargs -I {} smartctl -H {} | awk '/^SMART overall-health self-assessment test result/ { if ($NF != "PASSED") print FILENAME }' | grep -oE '[a-z]+$')

    local result=$(_replace_disks "$disks_with_errors" "$disk_position_matrix")
    echo "$result"
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
    _check_root_access
    local err_mx_1=$(_check_if_disks_are_present)
    local err_mx_2=$(_check_if_disk_failed_with_smartctl)
    echo "$err_mx_2" #============>TODO: Continue from here... 06/28/2023 [Bruno Crema Ferreira]
    local or_result=$(_perform_or_operation "$err_mx_1" "$err_mx_2")
    if [[ $or_result == *"1"* ]]; then
        _show_disk_error "$or_result"
    else
        echo "No errors was found."
    fi
}

_main()
{
    _load_configurations
    
    case $1 in
        -a) _show_animation ;;
        -e) _check_for_disk_errors ;;
        -i) 
            local mx_installed_disks=$(echo "$disk_position_matrix" | sed "s/$os_disk_pattern/1/g")
            echo "$mx_installed_disks"
            _show_installed_disks "$mx_installed_disks";;
        -t) _test_matrix ;;
         *)
            _show_help
            ;;
    esac
}

_main $1