# After received CRL
read -p "We will put CRL in the assigned CRL path. Press enter to continue"
cd /opt/etc/ca/
sudo rm -rf crl
sudo mkdir crl
cd /home/pi/project/ssh-demo/pki
sudo cp revcacert.crl /opt/etc/ca/crl
cd /opt/etc/ca/crl
sudo ln -s revcacert.crl `openssl crl -in revcacert.crl -noout -hash`.r0
ls -l
read -p "Press enter to continue"
sudo kill -9 `sudo lsof -t -i:22`
sudo /opt/sbin/sshd -d
exit 0