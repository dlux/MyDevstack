# Development OpenStack environment

[![Build Status](https://travis-ci.com/dlux/MyDevstack.svg?branch=master)](https://travis-ci.com/dlux/MyDevstack)


Different Methods:
------------------

* install_devstack.sh - Devstack all-in-one installation via shell script

* Vagrant - Devstack all-in-one installation with Vagrant


Notes:
------

.. block-code:: bash

  Inspect services:
  $ sudo systemctl status "devstack@*"

  Inspect logs:
  $ sudo journalctl --unit devstack@*


See also: https://docs.openstack.org/devstack/latest/development.html
