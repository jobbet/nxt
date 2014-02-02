nxt
===

  ----------------------------------------------------------------------------
  "THE NXT-WARE LICENSE" NXT: 13570469120032392161 (Revision: 25519)
  j0b <gemeni@gmail.com> wrote this file. As long as you retain this notice you
  can do whatever you want with this stuff. IF you think this stuff is worth it, 
  you can send me NXT, my public key is above.
  ----------------------------------------------------------------------------



Simple install and update script for NXT-Client on GNU/Linux (Debian and Ubuntu).

INSTALL

1. git clone https://github.com/jobbet && cd jobbet/nxt

2. ./nxt_install install (this will install the latest version of NXT-Client
   If you want a different version, specify that as second argument, e.g.
   ./nxt_install install 0.5.7

   If package dependencies are missing you will be asked if you want to install these,
   or do it manually.

   The client is downloaded from the public source for nxt-client software.
   During install the client software validates against known sha256sum hash.


UPDATE

1. cd jobbet/nxt && ./nxt_install update (this will update to the latest client version)
   For a different version, ./nxt_install update 0.5.7

   If package dependencies are missing you will be asked if you want to install these,
   or do it manually.

   Be sure to stop you client before updating. If you already have an installation of this software,
   the script will issue an /etc/init.d/nxtclient stop. So you do not have to think about in that case.

CONFIGURATION

   The nxt client java process can be configured with several parameters. This is done in /etc/nxt/nxt.conf
   Issue an /etc/init.d/nxtclient restart after changes is made.

j0b

13570469120032392161
