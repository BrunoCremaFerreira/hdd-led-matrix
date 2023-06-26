#!/bin/sh

export HDD_LED_MATRIX_DEVICE=/dev/ttyACM0

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

_test_matrix()
{
    echo "Simulating disk error:"
    echo "  .   *   .   ."
    echo "  *   .   .   ." 
    echo "  .   .   *   ."
    _show_disk_error "0100 1000 0010"
    sleep 10

    echo "Simulating disk Installed Position:"
    echo "  *   .   *   *"
    echo "  .   *   *   *" 
    echo "  *   *   .   *"
    _show_installed_disks "1011 0111 1101"
    sleep 10

    echo "Simulating normal disk activity"
    _show_animation

    echo "Done."
}

_main()
{
    _test_matrix
}

_main