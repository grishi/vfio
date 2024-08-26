#!/bin/bash
set -x

echo "Stopping coolercontrold.service..."
systemctl stop coolercontrold.service

echo "Unloading VFIO-PCI Kernel Drivers..."
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

echo "Re-Binding GPU to our display drivers..."
virsh nodedev-reattach pci_0000_01_00_0
virsh nodedev-reattach pci_0000_01_00_1

#echo "Rebinding VT consoles..."
#echo 1 > /sys/class/vtconsole/vtcon0/bind
#echo 1 > /sys/class/vtconsole/vtcon1/bind

#echo "Rebinding EFI-Framebuffer..."
#echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind

echo "Reading NVIDIA configuration..."
nvidia-xconfig --query-gpu-info > /dev/null 2>&1

echo "Loading NVIDIA drivers..."
modprobe nvidia_drm
modprobe nvidia_modeset
modprobe nvidia_uvm
modprobe i2c_nvidia_gpu
modprobe nvidia

echo "Mounting filesystems..."
mount -a
echo "Starting services..."
# Restart Display Manager
#systemctl start sddm.service
echo "Starting nvidia-persistenced.service..."
systemctl start nvidia-persistenced.service
#nvidia-smi -pl 360
echo "Starting coolercontrold.service..."
systemctl start coolercontrold.service
echo "Starting ollama.service..."
systemctl start ollama.service
echo "Starting comfyui.service..."
systemctl start comfyui.service

#echo "Move back to workspace 1 on Hyprland..."
#hyprctl dispatch workspace 1

#echo "Set LGTV to input 1..."
#lgtv setInput HDMI_1