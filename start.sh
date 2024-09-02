#!/bin/bash
# Helpful to read output when debugging
#set -x

echo "Stopping nvidia-persistenced.service..."
systemctl stop nvidia-persistenced.service
echo "Stopping coolercontrold.service..."
systemctl stop coolercontrold.service
echo "Stopping ollama.service..."
systemctl stop ollama.service
echo "Stopping comfyui.service..."
systemctl stop comfyui.service

echo "Checking for processes using /dev/nvidia*..."
# Use lsof to find processes using /dev/nvidia* and extract their PIDs
pids=$(lsof -t /dev/nvidia* /dev/dri/card0* /proc/driver/nvidia* 2>/dev/null)

if [ -n "$pids" ]; then
  echo "Found processes using /dev/nvidia*: $pids"
  echo "Attempting to kill these processes..."
  # Try to kill the processes gracefully first
  for pid in $pids; do
    if kill $pid; then
      echo "Process $pid terminated successfully."
    else
      echo "Failed to terminate process $pid. Trying a forceful kill..."
      kill -9 $pid
    fi
  done
  echo "All processes using /dev/nvidia* have been terminated."
else
  echo "No processes are using /dev/nvidia*."
fi

echo "Unbinding VTconsoles..."
#echo 0 > /sys/class/vtconsole/vtcon0/bind
#echo 0 > /sys/class/vtconsole/vtcon1/bind

echo "Unbinding EFI-Framebuffer..."
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
