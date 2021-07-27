clear
# config
read -p "We will config of the ssh server for enabling PAM. Press enter to continue"
CONFIG="/opt/etc/sshd_config"
sudo sed -i "s/.*\bVAType\b.*/VAType none/" $CONFIG
sudo sed -i "s/.*\bPasswordAuthentication\b.*/PasswordAuthentication no/" $CONFIG
less $CONFIG
sudo cp /etc/pam.d/sshd.yes /etc/pam.d/sshd
PAM_CONFIG="/etc/pam.d/sshd"
less $PAM_CONFIG
# start ssh server
sudo kill -9 `sudo lsof -t -i:22`
sudo /opt/sbin/sshd -d
exit 0