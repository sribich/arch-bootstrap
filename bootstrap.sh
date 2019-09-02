#!/usr/bin/env bash

printf "hi"
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/lib/bootstrap"
printf "hi"

if [[ -n "${DEBUG:-}" ]]; then
    activate_module debug
fi

activate_module array
activate_module runtime
activate_module selection
activate_module menu

###############################################################################
## Imports
###############################################################################

##
# When scripts are executed, they run under the directory in which they
# were called. This command remedies that by changing the directory to the
# folder in which the executed file resides.
##
declare -rg root_dir="$(dirname "$(readlink -f "$0" || realpath "$0")")" || exit

source "${root_dir}/src/config"

source "${root_dir}/src/boot_mode"
source "${root_dir}/src/connection"

# source "${root_dir}/src/util/print"
# source "${root_dir}/src/util/menu"
# source "${root_dir}/src/util/device"
# source "${root_dir}/src/util/control_flow"
# source "${root_dir}/src/util/misc"
# source "${root_dir}/src/util/system"

# source "${root_dir}/src/steps/01_keymap"
# source "${root_dir}/src/steps/02_editor"
# source "${root_dir}/src/steps/03_partition_disk"
# source "${root_dir}/src/steps/11/install_bootloader"
# source "${root_dir}/src/step05_configure_fstab"
# source "${root_dir}/src/steps/12_root_password"

###############################################################################
## Script Configuration
###############################################################################
bootstrap::configure()
{

    if grep "archiso" "/etc/hostname" >/dev/null; then
        printf "hi\n"
        print.error "This script will only run from an Arch Linux live image"
        exit 1
    fi

    get_boot_mode
    check_connection

    # timedatectl set-ntp true
}

finish()
{
    print_title "Install Completed"

    if confirm "Reboot?"; then
        reboot
    fi

    exit 0
}

print_title()
{
    print.title "Arch Bootstrap"
}

###############################################################################
## Main
###############################################################################
main()
{
    print.title "Arch Bootstrap"
    print.info  "A set of bash scripts to simplify ArchLinux installation"

    if [[ -f "${root_dir}/bootstrap_config" ]]; then
        source "${root_dir}/bootstrap_config"
    fi

    bootstrap::configure

    menu.run \
        "print_title"                            \
        "Select Keymap" "KEYMAP" "select_keymap" \
        "Select Editor" "EDITOR" "select_editor" \
        "Partition Disk" "PARTITION_DEVICE" "partition_disk" \
        "Bootloader" "ROOT_PASSWORD_STATUS" "select_bootloader" \
        "Fstab" "ROOT_PASSWORD_STATUS" "configure_fstab" \
        "Root Password" "ROOT_PASSWORD_STATUS" "root_password"

    finish
}

main "$@"


