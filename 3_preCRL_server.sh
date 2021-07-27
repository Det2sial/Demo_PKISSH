clear
# After received CA, install CA to CA path
read -p "We will install CA cert (for testing CRL) to the assigned CA path. Press enter to continue"
cd ~/project/ssh-demo/pki
sudo cp revcacert.pem /opt/etc/ca/crt
cd /opt/etc/ca/crt
sudo ln -s revcacert.pem `openssl x509 -in revcacert.pem -noout -hash`.0
ls -l
read -p "Press enter to continue"
cd /opt/etc/ca
ls -l
sudo rm -rf crl
ls -l
# config authorized\_keys
read -p "We will add subject names to the authorized_keys file. Press enter to continue"
cd /home/pi/project/ssh-demo/pki
less ~/.ssh/authorized_keys
# test CRL
read -p "We will test pre-CRL revocation. Press enter to continue"
sudo kill -9 `sudo lsof -t -i:22`
sudo /opt/sbin/sshd -d

exit 0