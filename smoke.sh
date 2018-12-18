#!/bin/bash

# Author: Joe Hakim Rahme <jhakimra@redhat.com>
# Past authors: Gabriel Szasz <gszasz@redhat.com>, Archit Modi <amodi@redhat.com>
# Description:

# This script can be run on a fresh Infrared install to validate that
# an instance can be spawned and connect to it.
#
# Tested on: RHOS13, RHOS14

set -x -o pipefail

OPTS=$(getopt -o hi:p: --long "help,image:,provider-network:" -n "$0" -- "$@")
eval set -- "$OPTS"
source /home/stack/overcloudrc.v3
function usage {
    echo "Usage: $0 [-i image] [-p provider-network]
Populates the overcloud with an image and an instance. Boot an instance. Assign a floating IP.

Arguments:
  -h, --help: Print this help message and exits.
  -i, --image: Defines the image used in the guest (default: cirros)
  -p, --provider-network: Defines the name of the provider network (default: public)"
}

while true; do
    case "$1" in
        -h | --help ) usage; exit 0;;
        -i | --image ) image="$2"; shift 2;;
        -p | --provider-network) provider_network="$2"; shift 2;;
        * ) break;;
    esac
done
RELEASE=$(</etc/yum.repos.d/latest-installed awk '{print $1}')

# Redirect output to smoke.log
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>smoke.log 2>&1

# Right now, only cirros is supported.
if [ -z $(echo "$image" | grep -Ew 'cirros') ]; then
    echo "Wrong image value. Supported value(s): 'cirros'"
    usage
    exit 1
fi

# Check that the provider network exists.
if [ -z $(openstack network list | grep "$provider_network") ]; then
    echo "Provider network $provider_network does not exist."
    usage
    exit 2
fi


if [ -z "$(openstack network list | grep private)" ]; then
    openstack network create private
    openstack subnet create --gateway 192.168.100.1 --dhcp --network private --subnet-range 192.168.100.0/24 private
    openstack subnet set --dns-nameserver 10.34.32.1 --dns-nameserver 10.34.32.3 private
    echo "****************************************Private network created****************************************************"
fi

SID=$(openstack network list -c ID -c Name -f value | awk '/private/ {print $1}')
if [ -z "$(openstack router list | grep testrouter)" ];then
    openstack router create testrouter
    openstack router set --external-gateway "$provider_network" testrouter
    openstack router add subnet testrouter private
    echo "****************************************Router and subnet created*************************************************"
fi

SECID=$(openstack security group list | grep $(openstack project show admin -f value -c id) | head -n 2 | awk '{print $2}')
openstack security group rule create $SECID --protocol tcp --dst-port 22 --remote-ip 0.0.0.0/0 2>/dev/null
openstack security group rule create $SECID --protocol icmp --dst-port -1 --remote-ip 0.0.0.0/0 2>/dev/null

if [ -z "$(openstack image list | grep cirros)" ];then
    if [ ! -f cirros-0.3.5-x86_64-disk.img ]; then
        wget http://rhos-qe-mirror-tlv.usersys.redhat.com/images/cirros-0.3.5-x86_64-disk.img
    fi
    IMGNAME=cirros
    openstack image create $IMGNAME --disk-format qcow2 --container-format bare --file cirros-0.3.5-x86_64-disk.img
    echo "****************************************Image uploaded to glance**************************************************"
else
    IMGNAME=$(openstack image list -f value -c Name | grep cirros | head -n 1)
fi

if [ -z "$(openstack flavor list | grep m1.smoke)" ]; then
    openstack flavor create --public m1.smoke --id auto --ram 512 --disk 1 --vcpus 1
fi

COUNTVAR=$RANDOM
openstack server create --image $IMGNAME --flavor m1.smoke test-$COUNTVAR --nic net-id=$SID --wait
IP=$(openstack floating ip create "$provider_network" -f value -c floating_ip_address)
openstack server add floating ip test-$COUNTVAR $IP
openstack server list
