os-smoke.sh
===========

A quick utility to set up networking and launch a single instance on a
fresh OpenStack deployment. I use this as a quick sanity test, which I
find much faster than setting up Tempest. Internally, `os-smoke` uses
the `python-openstackclient`[1], so make sure you have this installed.

Usage
-----

os-smoke provides 2 scripts:

* `./os-smoke.sh` will create the artifacts (server, networks,
  subnets, router, floating IP)
* `./os-unsmoke.sh` will tear down the artifacts

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


Testing
-------

Not much testing for now, but I do use a stylechecker[2], to support a
few shell formats:

* bash
* dash
* ksh
* sh

A Makefile is provided to run the tests. It can be executed like this:

    $ make test

[1]: https://docs.openstack.org/python-openstackclient/latest/
[2]: https://www.shellcheck.net
