clear
read -p "Add the CA cert to client's CA path"
cd ~/project/ssh-demo/pki/CA
sudo cp ~/project/ssh-demo/pki/revCA/revcacert.pem /opt/etc/ca/crt
cd /opt/etc/ca/crt
sudo ln -s revcacert.pem `openssl x509 -in revcacert.pem -noout -hash`.0
ls
sudo /opt/bin/ssh -i ~/.ssh/id_rsa_ssh_revpeer -p 22 pi@192.168.0.153 -v
exit 0