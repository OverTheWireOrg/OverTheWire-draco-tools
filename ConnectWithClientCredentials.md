How to connect as a client
==========================

In this guide, we'll assume your username is ```anna```.


1. Create a public/private key pair
-----------------------------------

All authentication and authorization is based on SSL inside the warzone.
Use the script ```make-user-csr.sh``` to generate a private key and accompanying [Certificate Signing Request (CSR)](http://en.wikipedia.org/wiki/Certificate_signing_request).
```
./make-user-csr.sh anna
```
Upload (or otherwise transfer) this CSR (e.g. anna.csr), together with a chosen username (e.g. anna), to be warzone
registration server. There, your account will be registered.

2. Generate your OpenVPN and browser credentials
------------------------------------------------

Upon successful registration, you receive a tarball with credentials for both the OpenVPN server
and the warzone registry website.
Use the script ```consume-client-credentials.sh``` to combine these credentials with your private key as follows:
```
./consume-client-credentials.sh client-anna.tar anna.key
```

This script will create two files: a tarball (e.g. client-anna-openvpn.tar.gz) with OpenVPN credentials
which you can unpack in /etc/openvpn, and a PKCS12 files (e.g. client-anna-registry.p12) which you should register
in your browser.

3. Connect to the warzone and test your account
-----------------------------------------------

Connect to the warzone and try to ping the registry server at 172.27.0.1:
```
ping 172.27.0.1
```

Next, connect to https://172.27.0.1/
This website should prompt your browser to send the correct SSL certificate, identifying you
as a registered user. If the website knows your username, it will display it in the top left.
