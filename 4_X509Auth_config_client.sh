# Make sure cacert.pem is on client side
read -p "Add the CA cert to client's CA path"
cd /opt/etc/ca/
sudo rm -rf crt
ls
sudo mkdir crt
cd ~/project/ssh-demo/pki/CA
sudo cp ~/project/ssh-demo/pki/CA/cacert.pem /opt/etc/ca/crt
cd /opt/etc/ca/crt
sudo ln -s cacert.pem `openssl x509 -in cacert.pem -noout -hash`.0
ls
# Test
read -p "Once Server is running, send the CA cert"
sudo rm /root/.ssh/known_hosts
sudo /opt/bin/ssh -i ~/.ssh/id_rsa_ssh_valid -p 22 pi@192.168.0.153 -v

exit 0