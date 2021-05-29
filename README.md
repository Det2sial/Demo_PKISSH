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
cd ~/Project/pkixssh-demo/pki
rm -rf peer
mkdir peer
cd peer
mkdir certs conf private
chmod 700 private
```
2. Generate SSH key
```Shell
ssh-keygen -t rsa -b 2048 -m PEM -f id\_rsa\_ssh\_valid -N ""
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
1. On Server side: Input:
```Shell
sudo /opt/sbin/sshd -d
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
vi ~/.ssh/authorized_keys
```
7. On Server side: Type subject names (Same as in your user cert)
```Shell
x509v3-sign-rsa subject= /C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=Peer
```
8. On Server side: Enable ssh service
```Shell
ps aux| grep sshd
sudo kill -9 xxxx #if sshd is running, type this command with sshd's PID
sudo /opt/sbin/sshd -d
```
#### Test: Client use peer cert to authenticate to server
1. On Client side: Clean the known hosts (delete the content)
```Shell
vi ~/.ssh/known_hosts
```

2. On Client side: Connect with peer cert
```Shell
sudo /opt/bin/ssh -i ~/.ssh/id_rsa_ssh_valid -p 22 pi@192.168.0.153 -v
```

### Server Authentication
#### Server set-up
1. On Client side: copy CA key and config (make sure ssh deamon is running on the server side)
```shell
sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid ~/project/ssh-demo/pki/CA/cakey.pem pi@192.168.0.153:~/project/ssh-demo/pki

sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid ~/project/ssh-demo/pki/openssl_server.cnf pi@192.168.0.153:~/project/ssh-demo/pki

sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid ~/project/ssh-demo/pki/openssl_ca.cnf pi@192.168.0.153:~/project/ssh-demo/pki
```
2.  On Server side: Generate server cert
```Shell
cd ~/project/ssh-demo/pki
rm -rf CA
mkdir ./CA
cd ./CA
mkdir certs conf private
chmod 700 private
echo '01' > serial
touch index.txt

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
vi ~/project/ssh-demo/pki/openssl_server.cnf # or open in notebook

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
