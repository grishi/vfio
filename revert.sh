#!/bin/bash
set -x

systemctl stop coolercontrold.service

# Unload VFIO-PCI Kernel Driver
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# Re-Bind GPU to our display drivers
virsh nodedev-reattach pci_0000_01_00_0
virsh nodedev-reattach pci_0000_01_00_1

# Rebind VT consoles
#echo 1 > /sys/class/vtconsole/vtcon0/bind
#echo 1 > /sys/class/vtconsole/vtcon1/bind
# Re-Bind EFI-Framebuffer
#echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind

# Read our nvidia configuration when before starting our graphics
nvidia-xconfig --query-gpu-info > /dev/null 2>&1

# Load nvidia drivers
modprobe nvidia_drm
modprobe nvidia_modeset
modprobe nvidia_uvm
modprobe i2c_nvidia_gpu
modprobe nvidia

# Restart Display Manager
#systemctl start sddm.service
mount -a
systemctl start nvidia-persistenced.service
#nvidia-smi -pl 360
systemctl start coolercontrold.service
systemctl start ollama.service
systemctl start comfyui.service

#hyprctl dispatch workspace 1

#lgtv setInput HDMI_1

## Another way
#echo 0000:01:00.0 > /sys/bus/pci/devices/0000:01:00.0/driver/unbind
#echo 0000:01:00.1 > /sys/bus/pci/devices/0000:01:00.1/driver/unbind

#echo nvidia > /sys/bus/pci/devices/0000:01:00.0/driver_override

#echo 0000:01:00.0 > /sys/bus/pci/drivers_probe