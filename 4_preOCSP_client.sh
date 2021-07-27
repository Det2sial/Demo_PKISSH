clear
sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid pi@192.168.0.153:~/project/ssh-demo/pki/OCSP/client.pem ~/project/ssh-demo/pki/OCSP/
# create identity key
read -p "We will generate the identity file for testing OCSP. Press enter to continue"
cd /home/grimer/project/ssh-demo/pki/OCSP
openssl x509 -in client.pem >> id_rsa_ssh_ocsp
ssh-keygen -y -f id_rsa_ssh_ocsp > id_rsa_ssh_ocsp.pub
cp ~/project/ssh-demo/pki/OCSP/id_rsa_ssh_ocsp ~/.ssh/
read -p "Below will show the updated identity key file. Press enter to continue"
less id_rsa_ssh_ocsp
exit 0