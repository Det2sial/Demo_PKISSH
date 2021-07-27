# create folder for OCSP client cert
read -p "We will create OCSP dir. Press enter to continue"
cd /home/grimer/project/ssh-demo/pki
rm -rf OCSP
mkdir OCSP
cd OCSP
mkdir certs conf private
chmod 700 private
read -p "We will generate CSR for OCSP client cert. Press enter to continue"
cd /home/grimer/project/ssh-demo/pki/OCSP
ssh-keygen -t rsa -b 2048 -m PEM -f id_rsa_ssh_ocsp -N ""
cp ~/project/ssh-demo/pki/openssl_ocspusr.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/OCSP/conf/openssl_ocspusr.cnf
openssl req -new -key id_rsa_ssh_ocsp -out client.csr -keyout clientkey.pem  -passin pass:Sweetroll -subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=OCSP Client"
read -p "We will send the CSR to server for signing. Press enter to continue"
cd /home/grimer/project/ssh-demo/pki/OCSP
sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid ./id_rsa_ssh_ocsp.pub ./client.csr pi@192.168.0.153:~/project/ssh-demo/pki/OCSP/
exit 0