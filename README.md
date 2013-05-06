==============
=======
# Zend Server 6 Vagrant Box

This Vagrant setup configures an Ubuntu 12.04 (Precise) 64-bit box with Zend
Server 6, PHP 5.4, SSL & PHPUnit

## Quick Start

Run `vagrant up` from the `vagrant` directory, eg

    (cd vagrant; vagrant up)
    
## Forwarded Ports

* 8080 => 80 (Webapp)
* 8443 => 443 (Webapp HTTPS)
* 10081 => 10081 (Zend Server Console)
* 10082 => 10082 (Zend Server HTTPS Console)

## Shared Folders

The `/var/www/html` directory on the host is shared as `/home/vagrant/app` on the VM

## Apache

Apache is configured with the MPM-ITK module with document root set to
`/home/vagrant/app`

## Chrome on Mountain Lion (OS-X 10.8.3)

If an "Invalid Server Certificate" message is displayed when trying to view pages over https in Chrome on Mountain Lion (OS-X 10.8.3), restart Chrome using the following
from a terminal `open -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --ignore-certificate-errors` 



