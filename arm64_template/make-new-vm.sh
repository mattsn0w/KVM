#!/bin/bash

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
