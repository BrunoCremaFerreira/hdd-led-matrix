#!/bin/sh

_get_device_names()
{
    lsblk --output name --nodeps --sort NAME --include 8 -nd
}

_main()
{
    _get_device_names
}

_main