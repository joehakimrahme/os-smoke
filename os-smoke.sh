#!/bin/bash

# Author: Joe Hakim Rahme <jhakimra@redhat.com>
# Past authors: Gabriel Szasz <gszasz@redhat.com>, Archit Modi <amodi@redhat.com>
#
# Description:
#
# This script provides a minimal opinionated smoke test to run on a
# fresh openstack deployment. Resources created:
# * 2 networks with one subnet each
# * A router
# * An image (if doesn't exist)
# * A flavor (if doesn't exist)
# * (optional) a keypair to inject in the instance
# * A security group allowing ssh and http connections
# * A floating ip from the provider network
# * An instance using all of the above


. common.sh

# Check that the provider network exists.
if ! openstack network list -c Name -f value | grep -q "$SMK_PROVIDER_NETWORK"; then
    echo "Provider network $SMK_PROVIDER_NETWORK does not exist."
    exit 2
fi

if ! openstack network list | grep -q "$SMK_PRIVATE_NETWORK"; then
    openstack network create "$SMK_PRIVATE_NETWORK"
fi

if ! openstack network list | grep -q "$SMK_DEVSTACK_NETWORK"; then
    openstack network create "$SMK_DEVSTACK_NETWORK"
fi

if ! openstack subnet list | grep -q "$SMK_DEVSTACK_SUBNET"; then
    openstack subnet create --gateway 192.168.100.1 --dhcp --network "$SMK_DEVSTACK_NETWORK" --subnet-range 192.168.100.0/24 "$SMK_DEVSTACK_SUBNET"
    openstack subnet set --dns-nameserver 10.34.32.1 --dns-nameserver 10.34.32.3 "$SMK_DEVSTACK_SUBNET"
fi

if ! openstack subnet list | grep -q "$SMK_PRIVATE_SUBNET"; then
    openstack subnet create --gateway 192.168.200.1 --dhcp --network "$SMK_PRIVATE_NETWORK" --subnet-range 192.168.200.0/24 "$SMK_PRIVATE_SUBNET"
    openstack subnet set --dns-nameserver 10.34.32.1 --dns-nameserver 10.34.32.3 "$SMK_PRIVATE_SUBNET"
fi

if ! openstack router list | grep "$SMK_ROUTER_NAME"; then
    openstack router create "$SMK_ROUTER_NAME"
    openstack router set --external-gateway "$SMK_PROVIDER_NETWORK" "$SMK_ROUTER_NAME"
    openstack router add subnet "$SMK_ROUTER_NAME" "$SMK_DEVSTACK_SUBNET"
    openstack router add subnet "$SMK_ROUTER_NAME" "$SMK_PRIVATE_SUBNET"
fi

if ! openstack image list | grep -w "$SMK_IMG_NAME"; then
    if [ -n "$SMK_IMG_FILE" ]; then
	openstack image create --disk-format qcow2 --container-format bare --file "$SMK_IMG_FILE" "$SMK_IMG_NAME"
    else
	echo "Image $SMK_IMG_NAME doesn't exist. os-smoke can create one if provided with the SMK_IMG_FILE environment variable"
	exit
    fi
fi

devstack_network_id=$(openstack network list -c ID -c Name -f value | grep "$SMK_DEVSTACK_NETWORK" | cut -d ' ' -f 1)
private_network_id=$(openstack network list -c ID -c Name -f value | grep "$SMK_PRIVATE_NETWORK" | cut -d ' ' -f 1)

openstack server create --flavor "$SMK_FLAVOR_NAME" --image "$SMK_IMG_NAME" --nic net-id="$devstack_network_id" --nic net-id="$private_network_id" "$SMK_INSTANCE_NAME" --wait

# SECID=$(openstack security group list | grep $(openstack project show admin -f value -c id) | head -n 2 | awk '{print $2}')
# openstack security group rule create $SECID --protocol tcp --dst-port 22 --remote-ip 0.0.0.0/0 2>/dev/null
# openstack security group rule create $SECID --protocol icmp --dst-port -1 --remote-ip 0.0.0.0/0 2>/dev/null


SMK_START_TIME=$(date +%s)
if [ "$1" = "init" ]; then
    init
elif [ "$1" = "cleanup" ]; then
    cleanup
fi
SMK_END_TIME=$(date +%s)

set +o xtrace
echo "Total execution time: $(( SMK_END_TIME - SMK_START_TIME )) seconds."
