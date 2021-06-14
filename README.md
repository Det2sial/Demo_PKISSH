# Device set-up
## Pi4 OS install & set up
1. Download SD card formatter and rasbian imager：
[Raspberry Pi OS](https://www.raspberrypi.org/software/operating-systems/) - For example, if you uses Windows for SD card set-up, chose Windows version.
[SD Card Formatter](https://www.sdcard.org/downloads/formatter/)
2. Plug in SD card to SD card reader and connect to PC,  use SD card formatter to format SD card. Then double click Raspberry Imager, chose path for SD card and click "write"
3. Once the write is down, insert SD card to pi and boot-up. Finish the system set-up by following the system guidance.
## Set up remote control from PC to Pi4
1. Input the following command on Pi4
```Shell
sudo raspi-config
```
2. Chose "interface options"
3. Chose "VNC"
4. Make sure VNC is enabled, save and exit. Input the following commands:
```Shell
sudo reboot
```
5. Input the following commands to get ip address of Pi4:
```Shell
ifconfig
```
7. Use remote control software in win10, input the IP address of Pi4
8. In the pomped-up window, input password and username of Pi4
9. You should now be able to access to your Pi4
# PKIXSSH set-up
## For Pi 4 (SSH server)
1. Set up PI4 SSH for accessing to your Github repo via SSH：[Github guidance](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
2. Source code：https://roumenpetrov.info/secsh/download.html or https://gitlab.com/secsh/pkixssh  Then input following commands
```Shell
cd ~/project/ssh-demo
git init
git remote add ssh-client git@github.com:Det2sial/pkixssh-demo.git
git pull ssh-client master
git branch
git pull ssh-client peer
git checkout peer

```
3. Install packages
```Shell
sudo apt install build-essential
sudo apt install zlib1g-dev
sudo apt-get install libssl-dev
sudo apt-get install libpam0g-dev 
# install pam
```
4. Install PKIXSSH
```Shell
cd ~/project/ssh-demo/pkixssh-13.1
./configure --prefix=/opt --with-pam
```
The result will look like:
```Shell
Example PAM control files can be found in the contrib/ 
subdirectory
```
Input following commands:
```Shell
sudo make
sudo make install
```
The result will look like (the error is ignored):
```Shell
Privilege separation user sshd does not exist
make: [Makefile:356: check-config] Error 255 (ignored)
```
## For VM (SSH client)
1. Set up VM using Ubuntu image & Vmware
2. Set up VM for accessing to your Github repo：[Github guidance](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
3. Source code：https://roumenpetrov.info/secsh/download.html or https://gitlab.com/secsh/pkixssh  Then input following commands
```Shell
cd ~/project/ssh-demo
git init
git remote add ssh-client git@github.com:Det2sial/pkixssh-demo.git
git pull ssh-client master
git branch
git pull ssh-client peer
git checkout peer

```
4.  Install packages
```Shell
sudo apt install build-essential
sudo apt install zlib1g-dev
sudo apt-get install libssl-dev
sudo apt-get install libpam0g-dev 
# install pam
```
5. Install PKIXSSH
```Shell
cd ~/project/ssh-demo/pkixssh-13.1
./configure --prefix=/opt --with-pam
```
The result will look like:
```Shell
Example PAM control files can be found in the contrib/ 
subdirectory
```
Input following commands:
```Shell
sudo make
sudo make install
```
The result will look like (the error is ignored):
```Shell
Privilege separation user sshd does not exist
make: [Makefile:356: check-config] Error 255 (ignored)
```

## Perform X.509 Mutual Authentication
#### Generate CA cert
1. Create CA dir
```Shell
cd ~/project/ssh-demo/pki
rm -rf CA
mkdir ./CA
cd ./CA
mkdir certs conf private
chmod 700 private
echo '01' > serial
touch index.txt
```
2. Export the CA config file
You need to change path in this config file 
```Shell
cp ~/project/ssh-demo/pki/openssl_ca.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/CA/conf/openssl_ca.cnf
```
3. Generate Root CA Cert
You need to change subject name
```Shell
# default value is not used since I use 'openssl req' instead of 'openssl ca'

cd ~/project/ssh-demo/pki/CA
openssl req -x509 -newkey rsa:2048 -keyout cakey.pem -passout pass:Sweetroll -out cacert.pem -outform PEM -days 3650 \
-subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=Root"
cp cakey.pem ./private
cp cacert.pem ./certs
openssl x509 -in cacert.pem -text
```
#### Generate Peer cert
1. Create peer dir
```Shell
cd ~/project/ssh-demo/pki
rm -rf peer
mkdir peer
cd peer
mkdir certs conf private
chmod 700 private
```
2. Generate SSH key
```Shell
ssh-keygen -t rsa -b 2048 -m PEM -f id_rsa_ssh_valid -N ""
```
3.  Export the CA config file
You need to change path in this config file
```Shell
cp ~/project/ssh-demo/pki/openssl_usr.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/peer/conf/openssl_usr.cnf
```
4. Generate SSH key pair that can be used by PKIXSSH
You need to change subject name
```Shell
cd ~/project/ssh-demo/pki/peer
openssl req -new -key id_rsa_ssh_valid -out usrvalid.csr \
-subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=Peer"
openssl req -text -noout -in usrvalid.csr
openssl x509 -req -days 1825 -in usrvalid.csr -out usrvalid.crt -CA ~/project/ssh-demo/pki/CA/cacert.pem -CAkey ~/project/ssh-demo/pki/CA/cakey.pem -passin pass:Sweetroll -CAcreateserial
openssl x509 -in usrvalid.crt >> id_rsa_ssh_valid
ssh-keygen -y -f id_rsa_ssh_valid > id_rsa_ssh_valid.pub
cp id_rsa_ssh_valid ~/.ssh/
```
5. Check subject names
```Shell
openssl x509 -noout -subject -in usrvalid.crt
```
### Client Authentication
#### Server set-up
1. On Server side: 

Confirm settings

```shell
sudo nano /opt/etc/sshd_config
```

Make sure it is

```shell
VAType none
```

also remove host key
```Shell
cd /opt/etc/
sudo rm /opt/etc/ssh_host_rsa_key
```

Then input
```Shell
sudo /opt/sbin/sshd -d

#sudo kill -9 `sudo lsof -t -i:22`

```


2. Copy CA cert to the server and creat authorized.keys file
You may need to change hostname in the following command
```Shell
sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid ~/project/ssh-demo/pki/CA/cacert.pem pi@192.168.0.153:~/project/ssh-demo/pki
```
3. On Server side: Once receievd CA cert, input:
```Shell
cd /home/pi/project/ssh-demo/pki
ls
```

```shell
cd /home/pi/project/ssh-demo/pki
rm -rf CA
mkdir ./CA
cd ./CA
mkdir certs conf private
chmod 700 private
echo '01' > serial
touch index.txt
```

```shell
cd /home/pi/project/ssh-demo/pki/CA
cp ~/project/ssh-demo/pki/cacert.pem ./
```

5. On Server side: Bind hash value and check
```Shell
cd /opt/etc/ca
sudo rm -rf crt
sudo mkdir crt
cd ~/project/ssh-demo/pki
sudo cp cacert.pem /opt/etc/ca/crt
cd /opt/etc/ca/crt
sudo ln -s cacert.pem `openssl x509 -in cacert.pem -noout -hash`.0
ls -l
```
6. On Server side: config authorized_keys
```Shell
cd /home/pi/project/ssh-demo/pki
sudo nano ~/.ssh/authorized_keys
```
7. On Server side: Type subject names (Same as in your user cert)
```Shell
x509v3-sign-rsa subject= /C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=Peer
```
8. On Server side: Enable ssh service

Confirm settings

```shell
sudo nano /opt/etc/sshd_config
```

Make sure it is

```shell
VAType none
```

Then run sshd

```shell
sudo /opt/sbin/sshd -d
```

#### Test: Client use peer cert to authenticate to server
1. On Client side: Clean the known hosts (delete the content)
```Shell
sudo su
rm ~/.ssh/known_hosts
exit
```

2. On Client side: Connect with peer cert
```Shell
sudo /opt/bin/ssh -i ~/.ssh/id_rsa_ssh_valid -p 22 pi@192.168.0.153 -vvv
```

### Server Authentication
#### Server set-up
1. On Client side: copy CA key and config (make sure ssh deamon is running on the server side)
```shell
sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid ~/project/ssh-demo/pki/CA/cakey.pem pi@192.168.0.153:~/project/ssh-demo/pki

sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid ~/project/ssh-demo/pki/{openssl_server,openssl_ca}.cnf pi@192.168.0.153:~/project/ssh-demo/pki

```
2.  On Server side: Generate server cert
```Shell
cd ~/project/ssh-demo/pki/CA
cp ~/project/ssh-demo/pki/cacert.pem ./
cp ~/project/ssh-demo/pki/cakey.pem ./


cd ~/project/ssh-demo/pki
rm -rf ./server
mkdir server
cd server
mkdir certs conf private
chmod 700 private

```

#### Generate Server cert
1. On Server side: Generate ssh key
```Shell
cd ~/project/ssh-demo/pki/server
ssh-keygen -t rsa -b 2048 -m PEM -f server_rsa_ssh_valid -N ""
```

2. Export the server cert config file
	You need to change path in this config file

```Shell
cd ~/project/ssh-demo/pki/server

cp ~/project/ssh-demo/pki/openssl_server.cnf ./conf

export OPENSSL_CONF=~/project/ssh-demo/pki/server/conf/openssl_server.cnf

```

3. Generate Server cert

```Shell
cd ~/project/ssh-demo/pki/server
openssl req -new -key server_rsa_ssh_valid -out servervalid.csr
openssl req -text -noout -in servervalid.csr
openssl x509 -req -days 1825 -in servervalid.csr -out servervalid.crt -CA ~/project/ssh-demo/pki/CA/cacert.pem -CAkey ~/project/ssh-demo/pki/CA/cakey.pem -passin pass:Sweetroll -CAcreateserial
```

4.  Generate SSH key pair that can be used by PKIXSSH  
    You need to change subject name
```Shell
cd ~/project/ssh-demo/pki/server
openssl x509 -in servervalid.crt >> server_rsa_ssh_valid
ssh-keygen -y -f server_rsa_ssh_valid > server_rsa_ssh_valid.pub
```

5. Copy key to host key path and **remove other host keys**

```Shell
cd ~/project/ssh-demo/pki/server
sudo cp server_rsa_ssh_valid /opt/etc/ssh_host_rsa_key
cd /opt/etc/
sudo rm XXX XXX.pub # remove other host keys
```

#### Client Set-up
1. On client side: delete know_hosts file!
```Shell
sudo su
cd ~/.ssh
ls
rm known_hosts
exit
```
2. Make sure cacert.pem is on client side
```Shell
cd /opt/etc/ca/
sudo rm -rf crt
ls
sudo mkdir crt

cd ~/project/ssh-demo/pki/CA
sudo cp ~/project/ssh-demo/pki/CA/cacert.pem /opt/etc/ca/crt
cd /opt/etc/ca/crt
sudo ln -s cacert.pem `openssl x509 -in cacert.pem -noout -hash`.0
ls
```

3. Connect to SSH server
```Shell
sudo /opt/bin/ssh -i ~/.ssh/id_rsa_ssh_valid -p 22 pi@192.168.0.153 -v
```


## Revocation
### Pre-CRL revocation (client cert is valid)
#### Generate rev CA cert
1. On client side: Generate SSH key
```Shell
cd ~/project/ssh-demo/pki/
rm -rf revCA
mkdir revCA
cd revCA
mkdir certs conf private
chmod 700 private
echo '01' > serial
echo '00' >revca.crlnum
touch index.txt
```

2.  Export the CA config file  
    You need to change path in this config file

```shell
cd ~/project/ssh-demo/pki/revCA
cp ~/project/ssh-demo/pki/openssl_revca.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/revCA/conf/openssl_revca.cnf
```

3.  Generate rev CA Cert  
    You need to change subject name

```shell
# default value is not used since I use 'openssl req' instead of 'openssl ca'

cd ~/project/ssh-demo/pki/revCA

openssl req -x509 -newkey rsa:2048 -keyout revcakey.pem -passout pass:Sweetroll -out revcacert.pem -outform PEM -days 3650 \
-subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=Rev Root"

cp revcakey.pem ./private
cp revcacert.pem ./certs
openssl x509 -in revcacert.pem -text
```

4. Generate empty CRL for CA cert
```Shell
cd ~/project/ssh-demo/pki/revCA
mkdir crl
export OPENSSL_CONF=~/project/ssh-demo/pki/revCA/conf/openssl_revca.cnf
openssl ca -gencrl -out crl/revcacert.crl -key Sweetroll
```

5. check the content of the crl
```Shell
cd ~/project/ssh-demo/pki/revCA
openssl crl -in crl/revcacert.crl -noout -text
```

#### Generate Rev Peer cert
1.  Create rev peer dir
```shell
cd ~/project/ssh-demo/pki
rm -rf revpeer
mkdir revpeer
cd revpeer
mkdir certs conf private
chmod 700 private
```
2.  Generate SSH key
```shell
ssh-keygen -t rsa -b 2048 -m PEM -f id_rsa_ssh_revpeer -N ""
```

3.  Export the CA config file  
    You need to change path in this config file

```shell
cp ~/project/ssh-demo/pki/openssl_revusr.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/revpeer/conf/openssl_revusr.cnf
```

4.  Generate SSH key pair that can be used by PKIXSSH  
    You need to change subject name

```shell
cd ~/project/ssh-demo/pki/revpeer
openssl req -new -key id_rsa_ssh_revpeer -out revpeer.csr \
-subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=Rev Peer"
openssl req -text -noout -in revpeer.csr

openssl x509 -req -days 1825 -in revpeer.csr -out revpeer.crt -CA ~/project/ssh-demo/pki/revCA/revcacert.pem -CAkey ~/project/ssh-demo/pki/revCA/revcakey.pem -passin pass:Sweetroll -CAcreateserial

openssl x509 -in revpeer.crt >> id_rsa_ssh_revpeer

ssh-keygen -y -f id_rsa_ssh_revpeer > id_rsa_ssh_revpeer.pub
cp id_rsa_ssh_revpeer ~/.ssh/
```

5.  Check subject names
```shell
openssl x509 -noout -subject -in revpeer.crt
```

6. Verify root cert
```Shell
cd ~/project/ssh-demo/pki/revCA
openssl verify -verbose -CAfile revcacert.pem ~/project/ssh-demo/pki/revpeer/revpeer.crt
```

#### Server Set-up
1.  On Server side: Input:

```shell
sudo /opt/sbin/sshd -d
```

2.  Copy rev CA cert to the server and creat authorized.keys file  
    You may need to change hostname in the following command

```shell
sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid ~/project/ssh-demo/pki/revCA/revcacert.pem pi@192.168.0.153:~/project/ssh-demo/pki
```

3.  On Server side: Once receievd CA cert, input:

```shell
cd /home/pi/project/ssh-demo/pki
ls
```

5.  On Server side: Bind hash value and check

```shell
cd ~/project/ssh-demo/pki
sudo cp revcacert.pem /opt/etc/ca/crt
cd /opt/etc/ca/crt
sudo ln -s revcacert.pem `openssl x509 -in revcacert.pem -noout -hash`.0
ls -l
```

remove crl

```shell
cd /opt/etc/ca
ls -l
sudo rm -rf crl
ls -l
```

6.  On Server side: config authorized\_keys

```shell
cd /home/pi/project/ssh-demo/pki
sudo nano ~/.ssh/authorized_keys
```

7.  On Server side: Type subject names (Same as in your user cert)

```shell
x509v3-sign-rsa subject= /C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=Rev Peer
```

8.  On Server side: Enable ssh service

```shell
sudo /opt/sbin/sshd -d
```


#### Test: before revocation
1. You should be able to login with rev peer cert
```shell
sudo /opt/bin/ssh -i ~/.ssh/id_rsa_ssh_revpeer -p 22 pi@192.168.0.153 -v
```

### CRL revocation (client cert is revoked)
1. Revocation ( you will see \*.crlnum.old and root-ca.crl in crl)

```Shell
cd ~/project/ssh-demo/pki/revCA
openssl ca -revoke ~/project/ssh-demo/pki/revpeer/revpeer.crt -crl_reason keyCompromise -keyfile revcakey.pem -passin pass:Sweetroll -cert revcacert.pem
```


2. Refresh the Certificate Revocation List (CRL) every time after revoking a certificate:

```Shell
cd ~/project/ssh-demo/pki/revCA
openssl ca -gencrl -out crl/revcacert.crl -keyfile revcakey.pem -passin pass:Sweetroll -cert revcacert.pem
```

3. Verify crl, it should show error 23: cert is revoked
```Shell
cd ~/project/ssh-demo/pki/revCA
openssl crl -in crl/revcacert.crl -outform pem -out cacrl.pem
cat revcacert.pem cacrl.pem > revcacrl.pem
openssl verify -extended_crl -verbose -CAfile revcacrl.pem -crl_check ~/project/ssh-demo/pki/revpeer/revpeer.crt
```

4. send crl (with VALID!)
```Shell
sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid ~/project/ssh-demo/pki/revCA/crl/revcacert.crl pi@192.168.0.153:~/project/ssh-demo/pki
```

#### Server Set-up
1. On server side: Once receievd CA crl, input:

```shell
cd /home/pi/project/ssh-demo/pki
ls
```

2. On server side: copy CA crl to ca:

```Shell
cd /opt/etc/ca/
sudo rm -rf crl
sudo mkdir crl
cd /home/pi/project/ssh-demo/pki
sudo cp revcacert.crl /opt/etc/ca/crl
cd /opt/etc/ca/crl
sudo ln -s revcacert.crl `openssl crl -in revcacert.crl -noout -hash`.r0
ls -l
```

#### Test: after revocation
1. On the Server side: should report revocation error
```shell
sudo /opt/bin/ssh -i ~/.ssh/id_rsa_ssh_revpeer -p 22 pi@192.168.0.153 -v
```


### Pre-OCSP Revocation (client cert)
#### Generate CA cert
1. On server side: Create OCSP folder
```shell
cd /home/pi/project/ssh-demo/pki
rm -rf OCSP
mkdir OCSP
cd OCSP
mkdir certs conf private
chmod 700 private
echo '01' > serial
touch index.txt
```

2. On server side: Export CA config file
```shell
cd /home/pi/project/ssh-demo/pki/OCSP
cp ~/project/ssh-demo/pki/openssl_ocspca.cnf ./conf

*change the path and check this cnf before exportation*
# nano ~/project/ssh-demo/pki/OCSP/conf/openssl_ocspca.cnf


export OPENSSL_CONF=~/project/ssh-demo/pki/OCSP/conf/openssl_ocspca.cnf
```

3. On server side: Create a new key for the CA 

```shell
cd /home/pi/project/ssh-demo/pki/OCSP

openssl req -new -x509 -keyout ocspcakey.pem -passout pass:Sweetroll -out ocspcacert.pem -days 365
```

#### Generate OCSP cert

4. On server side: Create a new key and CSR for the OCSP  

```shell

cd /home/pi/project/ssh-demo/pki/OCSP

export OPENSSL_CONF=~/project/ssh-demo/pki/OCSP/conf/openssl_ocspca.cnf

openssl req -new -nodes -out ocsp.csr -keyout ocspkey.pem -passout pass:Sweetroll -subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=OCSP Responder"
```

5. On server side: Sign the OCSP CSR with the CA key

```shell

cd /home/pi/project/ssh-demo/pki/OCSP

export OPENSSL_CONF=~/project/ssh-demo/pki/OCSP/conf/openssl_ocspca.cnf

openssl ca -extensions ocspsign_ext -days 1825 -in ocsp.csr -out ocsp.pem -keyfile ocspcakey.pem -passin pass:Sweetroll -cert ocspcacert.pem
 
 ```
 
 6. On server side: Verify
 ```shell
openssl verify -CAfile ocspcacert.pem ocsp.pem
 ```
 
 #### Generate OCSP Client cert

7. On client side: create OCSP folder

```shell
cd /home/grimer/project/ssh-demo/pki
rm -rf OCSP
mkdir OCSP
cd OCSP
```


Generate a client key and CSR 

```shell

cd /home/grimer/project/ssh-demo/pki/OCSP

ssh-keygen -t rsa -b 2048 -m PEM -f id_rsa_ssh_ocsp -N ""

openssl req -new -key id_rsa_ssh_ocsp -out client.csr -keyout clientkey.pem  -passin pass:Sweetroll -subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=OCSP Client"

```

8. On server side: Confirm settings

```shell
sudo nano /opt/etc/sshd_config
```

Make sure it is
```shell
VAType none
```

Then run sshd

```shell
sudo /opt/sbin/sshd -d
```

9. On client side: Send public key and CSR to server
```shell
cd /home/grimer/project/ssh-demo/pki/OCSP

sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid ./id_rsa_ssh_ocsp.pub ./client.csr pi@192.168.0.153:~/project/ssh-demo/pki/OCSP/
```


8. On server side: Sign the client CSR with the CA key 

```shell

cd /home/pi/project/ssh-demo/pki/OCSP
openssl ca -extensions usr_cert -days 1825 -in client.csr -out client.pem -keyfile ocspcakey.pem -passin pass:Sweetroll -cert ocspcacert.pem

```

9. On server side: Verify
 ```shell
openssl verify -CAfile ocspcacert.pem client.pem
```


#### Test: Valid OCSP status on Server side (local)

10. On server side: Start the OCSP responder  

```shell

cd /home/pi/project/ssh-demo/pki/OCSP
openssl ocsp -index index.txt -port 9999 -rsigner ocsp.pem -rkey ocspkey.pem -CA ocspcacert.pem

```

11. Validate the client certificate 

```shell

cd /home/pi/project/ssh-demo/pki/OCSP
openssl ocsp -CAfile ocspcacert.pem -issuer ocspcacert.pem -cert client.pem -url http://localhost:9999 -resp_text

```

#### Test: Valid OCSP status on client side (PKIXSSH)

1. On server side: confirm `VAType none`
```shell
sudo nano /opt/etc/sshd_config
```

2. Run sshd
```shell
sudo /opt/sbin/sshd -d
```

3. On client side: Get OCSP client certificate from the server
```shell
sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid pi@192.168.0.153:~/project/ssh-demo/pki/OCSP/client.pem ~/project/ssh-demo/pki/OCSP/

```

10. On client side: Generate public key (with cert)
```shell
cd /home/grimer/project/ssh-demo/pki/OCSP
openssl x509 -in client.pem >> id_rsa_ssh_ocsp
ssh-keygen -y -f id_rsa_ssh_ocsp > id_rsa_ssh_ocsp.pub
```


Copy private key to ~/.ssh
```shell
cp ~/project/ssh-demo/pki/OCSP/id_rsa_ssh_ocsp ~/.ssh/
# gedit ~/.ssh/id_rsa_ssh_ocsp
```

4. On server side: copy ocspca to ca path
```shell
cd /home/pi/project/ssh-demo/pki/OCSP
ls

sudo cp ocspcacert.pem /opt/etc/ca/crt
cd /opt/etc/ca/crt
sudo ln -s ocspcacert.pem `openssl x509 -in ocspcacert.pem -noout -hash`.0
ls -l
```

5. On server side: add public key
```shell
cd /home/pi/project/ssh-demo/pki
nano ~/.ssh/authorized_keys
```

```shell
x509v3-sign-rsa subject= /C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=OCSP Client
```

6. On server side: Generate ca bundle 
```shell
cd /home/pi/project/ssh-demo/pki/OCSP
cat ocspcacert.pem ocspcacert.pem > bundle.pem
```

Confirm settings
```shell
sudo nano /opt/etc/sshd_config
```


Change from
```shell
VAType none
```
to
```shell
VAType ocspspec
VAOCSPResponderURL http://localhost:9999
VACertificateFile /home/pi/project/ssh-demo/pki/OCSP/bundle.pem
```

7. On server side: Run OCSP responder

```shell
cd ~/project/ssh-demo/pki/OCSP
openssl ocsp -index index.txt -port 9999 -rsigner ocsp.pem -rkey ocspkey.pem -CA ocspcacert.pem
```
Then run sshd
```shell
sudo /opt/sbin/sshd -d

#sudo killall sshd
```

8. On client side: 

```shell
sudo /opt/bin/ssh -i ~/.ssh/id_rsa_ssh_ocsp -p 22 pi@192.168.0.153 -vvv
```


### OCSP Revocation (client cert)
#### Revoke OCSP client cert
1. On server side: Revoke the original client certificate 

```shell

export OPENSSL_CONF=~/project/ssh-demo/pki/OCSP/conf/openssl_ocspca.cnf

cd /home/pi/project/ssh-demo/pki/OCSP
openssl ca -revoke client.pem -keyfile ocspcakey.pem -passin pass:Sweetroll -cert ocspcacert.pem

```

#### Test: revoked OCSP status on Client side (local)

10.  On client side: Start the OCSP responder

```shell

cd /home/pi/project/ssh-demo/pki/OCSP
openssl ocsp -index index.txt -port 9999 -rsigner ocsp.pem -rkey ocspkey.pem -CA ocspcacert.pem

```

11.  Validate the client certificate

```shell

cd /home/pi/project/ssh-demo/pki/OCSP
openssl ocsp -CAfile ocspcacert.pem -issuer ocspcacert.pem -cert client.pem -url http://localhost:9999 -resp_text
```

#### Test: Valid OCSP status on Server side (PKIXSSH)

1.  On server side: Run OCSP responder

```shell
cd /home/pi/project/ssh-demo/pki/OCSP
openssl ocsp -index index.txt -port 9999 -rsigner ocsp.pem -rkey ocspkey.pem -CA ocspcacert.pem
```

Then run sshd

```shell
sudo /opt/sbin/sshd -d

#sudo killall sshd
```

2.  On client side:

```shell
sudo /opt/bin/ssh -i ~/.ssh/id_rsa_ssh_ocsp -p 22 pi@192.168.0.153 -vvv
```

### MFA (with DUO)
Reference: https://duo.com/docs/duounix

0. sign in to the DUO admin panel and choose 'protect an application', then click `unix application` and get api key.

1.  On server side: install duo_unix

```shell
cd ~/project/ssh-demo/
rm -rf MFA
mkdir MFA
cd MFA
wget https://dl.duosecurity.com/duo_unix-latest.tar.gz
tar zxf duo_unix-latest.tar.gz
cd duo_unix-1.11.4
```

2. Build and install `duo_unix` with PAM support ( `pam_duo`).
```shell
cd /home/pi/project/ssh-demo/MFA/duo_unix-1.11.4
./configure --with-pam --prefix=/usr && make && sudo make install
```

3. Once `duo_unix` is installed, edit `/etc/duo/pam_duo.conf` (in `/etc/duo` or `/etc/security`) to add the integration key, secret key, and API hostname from your Duo Unix application.

```shell
sudo nano /etc/duo/pam_duo.conf
```


```shell
[duo]
; Duo integration key
ikey = INTEGRATION_KEY
; Duo secret key
skey = SECRET_KEY
; Duo API hostname
host = API_HOSTNAME
```

4. make the following changes to your `sshd_config` file

```shell
sudo nano /opt/etc/sshd_config
```


```shell
PubkeyAuthentication yes
PasswordAuthentication no
```

```shell
UsePAM yes
ChallengeResponseAuthentication yes
UseDNS no
```

5. set up PAM for SSH pub key
```Shell
sudo nano /etc/pam.d/sshd
```
confirm
```Shell
#@include common-auth
auth  [success=1 default=ignore] pam_duo.so
auth  requisite pam_deny.so
auth  required pam_permit.so
```
6. open ssh server
```shell
sudo /opt/sbin/sshd -d
```

7. on client side
```shell
sudo /opt/bin/ssh -p 22 pi@192.168.0.153 -vvv
```

### NETCONF (subsystem)
#### Installation
1. check and install external libraries
```shell
sudo apt-get install libxml2-dev
sudo apt-get install libssh2-1 
sudo apt-get install libncurses5-dev libncursesw5-dev
sudo apt install zlib1g-dev
sudo apt-get install libreadline-dev
```
