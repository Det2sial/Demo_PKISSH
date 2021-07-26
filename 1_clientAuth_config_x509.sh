#! This Bash is used for configuring X509 mutual authentication for SSH client
#! premises: already installed PKIXSSH on client machine
clear
# Create CA DIR
read -p "We will create CA dir. Press enter to continue"
cd ~/project/ssh-demo/pki
rm -rf CA
mkdir ./CA
cd ./CA
mkdir certs conf private
chmod 700 private
echo '01' > serial
touch index.txt
pwd
ls -l
read -p "Press enter to continue"
# Export the CA config file
read -p "We will generate Root CA cert. Press enter to continue"
cp ~/project/ssh-demo/pki/openssl_ca.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/CA/conf/openssl_ca.cnf
# Generate Root CA Cert
cd ~/project/ssh-demo/pki/CA
openssl req -x509 -newkey rsa:2048 -keyout cakey.pem -passout pass:Sweetroll -out cacert.pem -outform PEM -days 3650 \
-subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=Root"
cp cakey.pem ./private
cp cacert.pem ./certs
openssl x509 -in cacert.pem -text
read -p "The Root CA cert has been created."
read -p "Below will show the subject names of the Root CA cert. Press enter to continue"
openssl x509 -noout -subject -in cacert.pem
read -p "Press enter to continue"
# Create peer dir
read -p "We will create peer dir. Press enter to continue"
cd ~/project/ssh-demo/pki
rm -rf peer
mkdir peer
cd peer
mkdir certs conf private
chmod 700 private
pwd
ls -l
read -p "Press enter to continue"
# Generate SSH key
read -p "We will use ssh-keygen to create SSH private key. Press enter to continue"
ssh-keygen -t rsa -b 2048 -m PEM -f id_rsa_ssh_valid -N ""
# Export the CA config file
# You need to change path in this config file
cp ~/project/ssh-demo/pki/openssl_usr.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/peer/conf/openssl_usr.cnf
# Generate SSH key pair that can be used by PKIXSSH
read -p "We will generate .CSR using the previous private key. Press enter to continue"
cd ~/project/ssh-demo/pki/peer
openssl req -new -key id_rsa_ssh_valid -out usrvalid.csr \
-subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=Peer"
openssl req -text -noout -in usrvalid.csr
read -p "We will generate peer cert with the generated .CSR. Press enter to continue"
openssl x509 -req -days 1825 -in usrvalid.csr -out usrvalid.crt -CA ~/project/ssh-demo/pki/CA/cacert.pem -CAkey ~/project/ssh-demo/pki/CA/cakey.pem -passin pass:Sweetroll -CAcreateserial
read -p "Below will show the subject names of the peer cert. Press enter to continue"
openssl x509 -noout -subject -in usrvalid.crt
read -p "We will concatenate the peer cert to the SSH private key as the identity file. Press enter to continue"
openssl x509 -in usrvalid.crt >> id_rsa_ssh_valid
ssh-keygen -y -f id_rsa_ssh_valid > id_rsa_ssh_valid.pub
cp id_rsa_ssh_valid ~/.ssh/
read -p "Below will show the updated identity key file. Press enter to continue"
less id_rsa_ssh_valid
read -p "The client config for client Auth is completed. Press enter to exit"
exit 0