clear
# revoke OCSP client cert
read -p "We will revoke OCSP client cert. Press enter to continue"
export OPENSSL_CONF=~/project/ssh-demo/pki/OCSP/conf/openssl_ocspca.cnf
cd /home/pi/project/ssh-demo/pki/OCSP
openssl ca -revoke client.pem -keyfile ocspcakey.pem -passin pass:Sweetroll -cert ocspcacert.pem
read -p "Press enter to continue"
# test OCSP
read -p "We will test OCSP revocation. Press enter to continue"
sudo kill -9 `sudo lsof -t -i:22`
sudo /opt/sbin/sshd -d
exit 0