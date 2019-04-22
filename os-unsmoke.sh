#!/bin/bash

. common.sh

if [ -n "$(openstack server list -c Name -f value)" ]; then
    openstack server delete "$SMK_INSTANCE_NAME"
fi

if [ -n "$(openstack port list -c ID -f value)" ]; then
    if openstack router list -c Name -f value | grep -q "$SMK_ROUTER_NAME"; then
	openstack router remove subnet "$SMK_ROUTER_NAME" "$SMK_DEVSTACK_SUBNET"
	openstack router remove subnet "$SMK_ROUTER_NAME" "$SMK_PRIVATE_SUBNET"
	openstack router delete "$SMK_ROUTER_NAME"
    fi
fi

openstack subnet delete "$SMK_PRIVATE_SUBNET"
openstack subnet delete "$SMK_DEVSTACK_SUBNET"

openstack network delete "$SMK_PRIVATE_NETWORK"
openstack network delete "$SMK_DEVSTACK_NETWORK"
