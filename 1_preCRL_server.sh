sudo kill -9 `sudo lsof -t -i:22`
sudo /opt/sbin/sshd -d
exit 0