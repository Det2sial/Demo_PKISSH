clear
# On client side: Generate rev CA cert
read -p "We will generate Root CA cert for testing CRL revocation. Press enter to continue"
cd ~/project/ssh-demo/pki/
rm -rf revCA
mkdir revCA
cd revCA
mkdir certs conf private
chmod 700 private
echo '01' > serial
echo '00' >revca.crlnum
touch index.txt
# export config file
cd ~/project/ssh-demo/pki/revCA
cp ~/project/ssh-demo/pki/openssl_revca.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/revCA/conf/openssl_revca.cnf
# generate root CA for testing CRL revocation
cd ~/project/ssh-demo/pki/revCA
openssl req -x509 -newkey rsa:2048 -keyout revcakey.pem -passout pass:Sweetroll -out revcacert.pem -outform PEM -days 3650 \
-subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=Rev Root"
cp revcakey.pem ./private
cp revcacert.pem ./certs
openssl x509 -in revcacert.pem -text
cd ~/project/ssh-demo/pki/revCA
openssl req -x509 -newkey rsa:2048 -keyout revcakey.pem -passout pass:Sweetroll -out revcacert.pem -outform PEM -days 3650 \
-subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=Rev Root"
cp revcakey.pem ./private
cp revcacert.pem ./certs
openssl x509 -in revcacert.pem -text
read -p "Press enter to continue"
cd ~/project/ssh-demo/pki/revCA
# Generate empty CRL for CA cert
read -p "Now we need to generate an empty CRL for Root CA. Press enter to continue"
mkdir crl
export OPENSSL_CONF=~/project/ssh-demo/pki/revCA/conf/openssl_revca.cnf
openssl ca -gencrl -out crl/revcacert.crl -key Sweetroll
cd ~/project/ssh-demo/pki/revCA
openssl crl -in crl/revcacert.crl -noout -text
read -p "Press enter to continue"
# Generate Rev Peer cert folder
read -p "We need to generate identity for SSH client. Press enter to continue"
cd ~/project/ssh-demo/pki
rm -rf revpeer
mkdir revpeer
cd revpeer
mkdir certs conf private
chmod 700 private
# Generate SSH key
ssh-keygen -t rsa -b 2048 -m PEM -f id_rsa_ssh_revpeer -N ""
# Export the CA config file
cp ~/project/ssh-demo/pki/openssl_revusr.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/revpeer/conf/openssl_revusr.cnf
cd ~/project/ssh-demo/pki/revpeer
openssl req -new -key id_rsa_ssh_revpeer -out revpeer.csr \
-subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=Rev Peer"
openssl req -text -noout -in revpeer.csr
openssl x509 -req -days 1825 -in revpeer.csr -out revpeer.crt -CA ~/project/ssh-demo/pki/revCA/revcacert.pem -CAkey ~/project/ssh-demo/pki/revCA/revcakey.pem -passin pass:Sweetroll -CAcreateserial
openssl x509 -in revpeer.crt >> id_rsa_ssh_revpeer
ssh-keygen -y -f id_rsa_ssh_revpeer > id_rsa_ssh_revpeer.pub
cp id_rsa_ssh_revpeer ~/.ssh/
read -p "Below will show the updated identity key file. Press enter to continue"
less id_rsa_ssh_revpeer
read -p "Once Server is running, send the CA cert"
sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid ~/project/ssh-demo/pki/revCA/revcacert.pem pi@192.168.0.153:~/project/ssh-demo/pki
