# Create OCSP folder
read -p "We will create OCSP CA cert. Press enter to continue"
cd /home/pi/project/ssh-demo/pki
rm -rf OCSP
mkdir OCSP
cd OCSP
mkdir certs conf private
chmod 700 private
echo '01' > serial
touch index.txt
# Change VAType to none (turn off the OCSP check for now)
CONFIG="/opt/etc/sshd_config"
sudo sed -i "s/.*\bVAType\b.*/VAType none/" $CONFIG
less "/opt/etc/sshd_config"
# Export CA config file
cd /home/pi/project/ssh-demo/pki/OCSP
cp ~/project/ssh-demo/pki/openssl_ocspca.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/OCSP/conf/openssl_ocspca.cnf
# Create a new key for the CA
cd /home/pi/project/ssh-demo/pki/OCSP
openssl req -new -x509 -keyout ocspcakey.pem -passout pass:Sweetroll -out ocspcacert.pem -days 365
openssl x509 -in ocspcacert.pem -text
read -p "Press enter to continue"
# Create OCSP responder cert
read -p "We will generate OCSP responder cert. Press enter to continue"
cd /home/pi/project/ssh-demo/pki/OCSP
export OPENSSL_CONF=~/project/ssh-demo/pki/OCSP/conf/openssl_ocspca.cnf
openssl req -new -nodes -out ocsp.csr -keyout ocspkey.pem -passout pass:Sweetroll -subj "/C=US/ST=Colorado/O=Grimer Softwork/OU=R&D/CN=OCSP Responder"
cd /home/pi/project/ssh-demo/pki/OCSP
export OPENSSL_CONF=~/project/ssh-demo/pki/OCSP/conf/openssl_ocspca.cnf
openssl ca -extensions ocspsign_ext -days 1825 -in ocsp.csr -out ocsp.pem -keyfile ocspcakey.pem -passin pass:Sweetroll -cert ocspcacert.pem
openssl x509 -in ocsp.pem -text
read -p "Press enter to continue"
openssl verify -CAfile ocspcacert.pem ocsp.pem
read -p "Press enter to continue"
sudo kill -9 `sudo lsof -t -i:22`
sudo /opt/sbin/sshd -d
exit 0