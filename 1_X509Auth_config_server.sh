clear
# Confirm settings
CONFIG="/opt/etc/sshd_config"
# Change VAType to none (turn off the OCSP check for now)
sudo sed -i "s/.*\bVAType\b.*/VAType none/" $CONFIG
sudo sed -i "s/.*\bPasswordAuthentication\b.*/PasswordAuthentication yes/" $CONFIG
# sudo less /opt/etc/sshd_config
# also remove host key
cd /opt/etc/
sudo rm /opt/etc/ssh_host_rsa_key
sudo ssh-keygen -f /opt/etc/ssh_host_rsa_key -N '' -t rsa
# start ssh server
sudo kill -9 `sudo lsof -t -i:22`
sudo /opt/sbin/sshd -d

exit 0


