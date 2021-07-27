clear
# After received CSR, install CA to CA path
read -p "We will sign the CSR and generate OCSP client cert (for testing CRL) to the assigned CA path. Press enter to continue"
cd /home/pi/project/ssh-demo/pki/OCSP
cp ~/project/ssh-demo/pki/openssl_ocspca.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/OCSP/conf/openssl_ocspca.cnf
cd /home/pi/project/ssh-demo/pki/OCSP
openssl ca -extensions usr_cert -days 1825 -in client.csr -out client.pem -keyfile ocspcakey.pem -passin pass:Sweetroll -cert ocspcacert.pem
read -p "Press enter to continue"
# send OCSP client cert
read -p "We will send the sigend OCSP client cert to the client. Press enter to continue"
sudo kill -9 `sudo lsof -t -i:22`
sudo /opt/sbin/sshd -d
exit 0