# Development OpenStack environment

Different Methods:
------------------

* install_devstack.sh - Devstack all-in-one installation via shell script

* Vagrant - Devstack all-in-one installation with Vagrant

* ansible_openstack - OpenStack all-in-one installation with ansible project

Notes:
------

.. block-code:: bash

  Inspect services:
  $ sudo systemctl status "devstack@*"

  Inspect logs:
  $ sudo journalctl --unit devstack@*


See also: https://docs.openstack.org/devstack/latest/development.html
