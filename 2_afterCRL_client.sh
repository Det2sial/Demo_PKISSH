# Revoke the peer cert
read -p "We will revoke peer cert. Press enter to continue"
cd ~/project/ssh-demo/pki/revCA
cp ~/project/ssh-demo/pki/openssl_revca.cnf ./conf
export OPENSSL_CONF=~/project/ssh-demo/pki/revCA/conf/openssl_revca.cnf
cd ~/project/ssh-demo/pki/revCA
openssl ca -revoke ~/project/ssh-demo/pki/revpeer/revpeer.crt -crl_reason keyCompromise -keyfile revcakey.pem -passin pass:Sweetroll -cert revcacert.pem
cd ~/project/ssh-demo/pki/revCA
openssl ca -gencrl -out crl/revcacert.crl -keyfile revcakey.pem -passin pass:Sweetroll -cert revcacert.pem
read -p "The peer cert now is revoked, let us verify. Press enter to continue"
cd ~/project/ssh-demo/pki/revCA
openssl crl -in crl/revcacert.crl -outform pem -out cacrl.pem
cat revcacert.pem cacrl.pem > revcacrl.pem
openssl verify -extended_crl -verbose -CAfile revcacrl.pem -crl_check ~/project/ssh-demo/pki/revpeer/revpeer.crt
# update CRL
read -p "The crl needs to be updated and sent to the server. Press enter to continue"
sudo /opt/bin/scp -P 22 -i ~/.ssh/id_rsa_ssh_valid ~/project/ssh-demo/pki/revCA/crl/revcacert.crl pi@192.168.0.153:~/project/ssh-demo/pki
