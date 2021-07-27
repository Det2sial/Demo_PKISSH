# After received CA, create CA folder on teh server
clear
read -p "We will create CA dir. Press enter to continue"
cd /home/pi/project/ssh-demo/pki
rm -rf CA
mkdir ./CA
cd ./CA
mkdir certs conf private
chmod 700 private
echo '01' > serial
touch index.txt
cd /home/pi/project/ssh-demo/pki
ls
read -p "Press enter to continue"
# copy CA cert
cd /home/pi/project/ssh-demo/pki/CA
cp ~/project/ssh-demo/pki/cacert.pem ./
cp ~/project/ssh-demo/pki/cakey.pem ./
# install CA cert
read -p "We will install CA cert to the assigned CA path. Press enter to continue"
cd /opt/etc/ca
sudo rm -rf crt
sudo mkdir crt
cd ~/project/ssh-demo/pki/CA
sudo cp cacert.pem /opt/etc/ca/crt
cd /opt/etc/ca/crt
sudo ln -s cacert.pem `openssl x509 -in cacert.pem -noout -hash`.0
ls -l
# config authorized_keys
read -p "We will add subject names to the authorized_keys file. Press enter to continue"
cd /home/pi/project/ssh-demo/pki
less ~/.ssh/authorized_keys
# generate server cert using the received CA cert
read -p "We will generate server cert using the received CA cert. Press enter to continue"
cd ~/project/ssh-demo/pki/server
ssh-keygen -t rsa -b 2048 -m PEM -f server_rsa_ssh_valid -N ""
cd ~/project/ssh-demo/pki/server
cp ~/project/ssh-demo/pki/openssl_server.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/server/conf/openssl_server.cnf
cd ~/project/ssh-demo/pki/server
openssl req -new -key server_rsa_ssh_valid -out servervalid.csr
openssl req -text -noout -in servervalid.csr
openssl x509 -req -days 1825 -in servervalid.csr -out servervalid.crt -CA ~/project/ssh-demo/pki/CA/cacert.pem -CAkey ~/project/ssh-demo/pki/CA/cakey.pem -passin pass:Sweetroll -CAcreateserial

read -p "Below will show the subject names of the server cert. Press enter to continue"
openssl x509 -noout -subject -in servervalid.crt
read -p "We will concatenate the server cert to the SSH private key as the identity file. Press enter to continue"
cd ~/project/ssh-demo/pki/server
openssl x509 -in servervalid.crt >> server_rsa_ssh_valid
ssh-keygen -y -f server_rsa_ssh_valid > server_rsa_ssh_valid.pub
cd ~/project/ssh-demo/pki/server
sudo cp server_rsa_ssh_valid /opt/etc/ssh_host_rsa_key
cd /opt/etc/
ls
cd ~/project/ssh-demo/pki/server
read -p "Below will show the updated identity key file. Press enter to continue"
less server_rsa_ssh_valid

# test mutual auth
read -p "We will test . Press enter to continue"
sudo kill -9 `sudo lsof -t -i:22`
sudo /opt/sbin/sshd -d

exit 0
