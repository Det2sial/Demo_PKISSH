clear
# copy CA to path
read -p "We will install CA cert (for testing OCSP) to the assigned CA path. Press enter to continue"
cd /home/pi/project/ssh-demo/pki/OCSP
ls
sudo cp ocspcacert.pem /opt/etc/ca/crt
cd /opt/etc/ca/crt
sudo ln -s ocspcacert.pem `openssl x509 -in ocspcacert.pem -noout -hash`.0
ls -l
# config (turn on OCSP checking)
CONFIG="/opt/etc/sshd_config"
sudo sed -i "s/.*\bVAType\b.*/VAType ocspspec/" $CONFIG
less "/opt/etc/sshd_config"
# config authorized\_keys
read -p "We will add subject names to the authorized_keys file. Press enter to continue"
cd /home/pi/project/ssh-demo/pki
less ~/.ssh/authorized_keys
# generate ca buldle
cd /home/pi/project/ssh-demo/pki/OCSP
cat ocspcacert.pem ocspcacert.pem > bundle.pem
# run OCSP server
read -p "We will start an OCSP server. Press enter to continue"
cd ~/project/ssh-demo/pki/OCSP
openssl ocsp -index index.txt -port 9999 -rsigner ocsp.pem -rkey ocspkey.pem -CA ocspcacert.pem
#read -p "We will test OCSP with no revocation. Press enter to continue"
#sudo kill -9 `sudo lsof -t -i:22`
#sudo /opt/sbin/sshd -d
exit 0