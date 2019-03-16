os-smoke.sh
===========

A quick utility to set up networking and launch a single instance on a
fresh OpenStack deployment. I use this as a quick sanity test, which I
find much faster than setting up Tempest.

Usage
-----

	$ ./os-smoke.sh
	Usage: ./os-smoke.sh (init|cleanup)

`os-smoke.sh` is a script that takes an action argument:

* `./os-smoke.sh init` will create resources and spawn an instance
* `./os-smoke.sh cleanup` will destroy the instance and free the resources


Configuration
-------------

The behavior of the script can be configured by defining environment
variables, either in the shell or by defining them in a `local.conf`
file.

* `SMK_RCFILE`: a path to the cloud's rc file
* `SMK_IMG_NAME`: the name of the image to use on the instance
* `SMK_IMG_URL`: (optional) path to a qcow2 image to upload to the
  cloud, in case the image `SMK_IMG_NAME` isn't available.

A `local.conf.sample` has been provided with this script and can serve
as a starting point for configuration. The file comments go more in
details in the description of each variable, and show each variable
default value.
