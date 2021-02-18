#!/bin/bash
# This can obviously be improved upon.  This handles basic clean up of the VM.

VM_NAME=armvm01
IMAGE_NAME=${VM_NAME}_Ubuntu-Focal-server.img


virsh destroy --domain ${VM_NAME}
virsh undefine --nvram ${VM_NAME}
rm -f ${IMAGE_NAME}
