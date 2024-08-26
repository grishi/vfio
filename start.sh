#!/bin/bash
# Helpful to read output when debugging
set -x

echo "Stopping services..."
# Stop your display manager. If you're on kde it'll be sddm.service. Gnome users should use 'killall gdm-x-session' instead
#echo "Stopping KDE display manager..."
#systemctl --user -M grishi@ stop plasma*
#echo "Stopping SDDM display manager..."
#systemctl stop sddm.service
echo "Stopping nvidia-persistenced.service..."
systemctl stop nvidia-persistenced.service
echo "Stopping coolercontrold.service..."
systemctl stop coolercontrold.service
echo "Stopping ollama.service..."
systemctl stop ollama.service
echo "Stopping comfyui.service..."
systemctl stop comfyui.service

echo "Checking and killing processes using /dev/nvidia*..."
if fuser -v /dev/nvidia*; then
  echo "Killing processes using /dev/nvidia*..."
  fuser -k /dev/nvidia*
else
  echo "No processes are using /dev/nvidia*."
fi

#echo "Unbinding VTconsoles..."
#echo 0 > /sys/class/vtconsole/vtcon0/bind
#echo 0 > /sys/class/vtconsole/vtcon1/bind

#echo "Unbinding EFI-Framebuffer..."
#echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

echo "Sleeping for 5 seconds to avoid race conditions..."
sleep 5

echo "Unloading Nvidia drivers..."
modprobe -r nvidia_uvm
modprobe -r nvidia_drm
modprobe -r nvidia_modeset
modprobe -r i2c_nvidia_gpu
modprobe -r nvidia

echo "Detaching GPU devices..."
virsh nodedev-detach pci_0000_01_00_0
virsh nodedev-detach pci_0000_01_00_1

echo "Loading VFIO kernel modules..."
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1

echo "Starting coolercontrold.service..."
systemctl start coolercontrold.service

#echo "Set LGTV to input 2..."
#lgtv setInput HDMI_2