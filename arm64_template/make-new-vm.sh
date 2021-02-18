#!/bin/bash

# There are several assumptions for this script to work.
# 1) The required tools are installed on the hypervisor host. 
#    The following packages should be installed: libvirt-daemon, cloud-utils, libosinfo-bin, network-manager, net-tools
# 2) This script was run on Ubuntu 20.04 ARM64 on a RaspberryPi 4 w/ 8GB of RAM, ethernet port was bridged to br0 and the default network setup as a bridge.
# 3) each VM is stored in it's own directory as $VMNAME
# 4) the OS varient is found in the  output of `osinfo-query os` command
# 5) ARM64 cloud-images were downloaded from ubuntu and centos cloud image repos. 
# 6) After install and update is successful, run `poweroff` in the guest OS, then `virsh autostart armvm0N &&  virsh start armvm0N` to restart the VM.

VM_NAME=armvm01
VM_MAC='52:54:00:B3:3F:DD'
IMAGE_NAME=${VM_NAME}_Ubuntu-Focal-server.img
OS_VAR='ubuntu20.04'
RAM=2048
VCPUS=1

rm config.iso
cp /var/lib/libvirt/images/focal-server-cloudimg-arm64.img ${IMAGE_NAME}
qemu-img resize ${IMAGE_NAME} +15G

# create config/iso and network profile.
cloud-localds -v config.iso config.yaml --network-config network.yaml

if [[ $? -eq 0 && -e config.iso ]]; then
    echo "created config.iso successfully."
    sleep 5
    virt-install \
      --memory ${RAM} \
      --vcpus ${VCPUS} \
      --name ${VM_NAME} \
      --disk /var/lib/libvirt/images/hosts/${VM_NAME}/${IMAGE_NAME},device=disk \
      --disk /var/lib/libvirt/images/hosts/${VM_NAME}/config.iso,device=cdrom \
      --os-type Linux \
      --os-variant ${OS_VAR} \
      --virt-type kvm \
      --graphics none \
      --network network:default,mac=${VM_MAC},model.type=e1000 \
      --import
fi
