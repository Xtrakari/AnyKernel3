### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=KernelSU+SuSFS kernel for AOSP LG SM8150
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

# boot install
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot # for devices with init_boot ramdisk
    flash_boot # for devices with init_boot ramdisk
else
    dump_boot # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk

    # -- Schedhorizon Governor Enforcement Injection --
    if [ -d ramdisk ]; then
        ui_print "Patching ramdisk init scripts for Schedhorizon..."
        
        # Target the common power initialization script found on SM8150 devices
        if [ -f ramdisk/init.qcom.power.rc ]; then
            TARGET_RC="ramdisk/init.qcom.power.rc"
        else
            TARGET_RC="ramdisk/init.rc"
        fi
        
        # Append an asynchronous execution block triggered when boot finishes
        cat << 'EOF' >> $TARGET_RC

# Enforce Schedhorizon scaling governor fallback overwrite
on property:sys.boot_completed=1
    exec u:r:su:s0 root root -- /system/bin/sh -c "sleep 3; echo schedhorizon > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor; echo schedhorizon > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor; echo schedhorizon > /sys/devices/system/cpu/cpufreq/policy7/scaling_governor"
EOF
    fi
    
    write_boot # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
fi
## end boot install
