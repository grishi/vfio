#!/bin/bash
# Helpful to read output when debugging
set -x

# Stop your display manager. If you're on kde it'll be sddm.service. Gnome users should use 'killall gdm-x-session' instead
#systemctl --user -M grishi@ stop plasma*
#systemctl stop sddm.service
systemctl stop nvidia-persistenced.service
systemctl stop coolercontrold.service
systemctl stop ollama.service
systemctl stop comfyui.service


# Unbind VTconsoles
#echo 0 > /sys/class/vtconsole/vtcon0/bind
#echo 0 > /sys/class/vtconsole/vtcon1/bind
# Unbind EFI-Framebuffer
#echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# Avoid a race condition by waiting a couple of seconds. This can be calibrated to be shorter or longer if required for your system
sleep 5

# Unload all Nvidia drivers
modprobe -r nvidia_uvm
modprobe -r nvidia_drm
modprobe -r nvidia_modeset
modprobe -r i2c_nvidia_gpu
modprobe -r nvidia

# Unbind the GPU from display driver
virsh nodedev-detach pci_0000_01_00_0
virsh nodedev-detach pci_0000_01_00_1

# Load VFIO kernel module
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1

systemctl start coolercontrold.service

#lgtv setInput HDMI_2

##another way to try
#echo 0000:01:00.0 > /sys/bus/pci/devices/0000:01:00.0/driver/unbind
#echo 0000:01:00.1 > /sys/bus/pci/devices/0000:01:00.1/driver/unbind

#echo vfio-pci > /sys/bus/pci/devices/0000:01:00.0/driver_override
#echo vfio-pci > /sys/bus/pci/devices/0000:01:00.1/driver_override

#echo 0000:01:00.0 > /sys/bus/pci/drivers_probe
#echo 0000:01:00.1 > /sys/bus/pci/drivers_probe