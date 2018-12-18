RHOS Smoke
==========

A quick utility to set up networking and launch a single instance on a
fresh Infrared deployment. I use this as a quick sanity test, which I
find faster than setting up Tempest.

Usage
-----
	
	$ smoke.sh [-i image] [-p provider-network]
    Populates the overcloud with an image and an instance. Boot an instance. Assign a floating IP.
    
    Arguments:
      -h, --help: Print this help message and exits.
      -i, --image: Defines the image used in the guest (default: cirros)
      -p, --provider-network: Defines the name of the provider network (default: public)
      
