*******
Docker driver installation guide
*******

Requirements
============

* Docker Engine

Install
=======

Please refer to the `Virtual environment`_ documentation for installation best
practices. If not using a virtual environment, please consider passing the
widely recommended `'--user' flag`_ when invoking ``pip``.

.. _Virtual environment: https://virtualenv.pypa.io/en/latest/
.. _'--user' flag: https://packaging.python.org/tutorials/installing-packages/#installing-to-the-user-site

.. code-block:: bash

    $ python3 -m pip install 'molecule[docker]'


Test CMDs
=========

ldapsearch -h localhost -x -D "cn=Directory Manager" -w molecule1234
ldapsearch -h localhost -b "dc=devops,dc=local" -x -D "cn=Directory Manager" -w molecule1234
dsidm -b "dc=devops,dc=local" -D "cn=Directory Manager" -w molecule1234 ldap://localhost:389  user list

