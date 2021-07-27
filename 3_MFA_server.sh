sudo cp /etc/pam.d/sshd.no /etc/pam.d/sshd
PAM_CONFIG="/etc/pam.d/sshd"
less $PAM_CONFIG
# start ssh server
sudo kill -9 `sudo lsof -t -i:22`
sudo /opt/sbin/sshd -d
exit 0