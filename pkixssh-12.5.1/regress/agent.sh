#	$OpenBSD: agent.sh,v 1.17 2019/12/21 02:33:07 djm Exp $
#	Placed in the Public Domain.

tid="simple agent test"

SSH_AUTH_SOCK=/nonexistent ${SSHADD} -l > /dev/null 2>&1
if [ $? -ne 2 ]; then
	fail "ssh-add -l did not fail with exit code 2"
fi

trace "start agent, args ${EXTRA_AGENT_ARGS} -s"
eval `${SSHAGENT} ${EXTRA_AGENT_ARGS} -s` > /dev/null
r=$?
if [ $r -ne 0 ]; then
	fatal "could not start ssh-agent: exit code $r"
fi

eval `${SSHAGENT} ${EXTRA_AGENT_ARGS} -s | sed 's/SSH_/FW_SSH_/g'` > /dev/null
r=$?
if [ $r -ne 0 ]; then
	fatal "could not start second ssh-agent: exit code $r"
fi

${SSHADD} -l > /dev/null 2>&1
if [ $? -ne 1 ]; then
	fail "ssh-add -l did not fail with exit code 1"
fi

rm -f $OBJ/user_ca_key $OBJ/user_ca_key.pub
${SSHKEYGEN} -q -N '' -t ed25519 -f $OBJ/user_ca_key \
	|| fatal "ssh-keygen failed"

trace "overwrite authorized keys"
printf '' > $OBJ/authorized_keys_$USER

for t in ${SSH_KEYTYPES}; do
	# generate user key for agent
	rm -f $OBJ/$t-agent $OBJ/$t-agent.pub*
	${SSHKEYGEN} -q -N '' -t $t -f $OBJ/$t-agent ||\
		 fatal "ssh-keygen for $t-agent failed"
	# Make a certificate for each too.
	${SSHKEYGEN} -qs $OBJ/user_ca_key -I "$t cert" \
		-n estragon $OBJ/$t-agent.pub || fatal "ca sign failed"

	# add to authorized keys
	cat $OBJ/$t-agent.pub >> $OBJ/authorized_keys_$USER
	# add private key to agent
	${SSHADD} $OBJ/$t-agent > /dev/null 2>&1
	retval=$?
	if test $retval -ne 0 ; then
		fail "ssh-add failed exit code $retval"
	fi
	# add private key to second agent
	SSH_AUTH_SOCK=$FW_SSH_AUTH_SOCK ${SSHADD} $OBJ/$t-agent #> /dev/null 2>&1
	if [ $? -ne 0 ]; then
		fail "ssh-add failed exit code $?"
	fi
	# Remove private key to ensure that we aren't accidentally using it.
	rm -f $OBJ/$t-agent
done

# Remove explicit identity directives from ssh_proxy
mv $OBJ/ssh_proxy $OBJ/ssh_proxy_bak
grep -vi identityfile $OBJ/ssh_proxy_bak > $OBJ/ssh_proxy

${SSHADD} -l > /dev/null 2>&1
r=$?
if [ $r -ne 0 ]; then
	fail "ssh-add -l failed: exit code $r"
fi
# the same for full pubkey output
${SSHADD} -L > /dev/null 2>&1
r=$?
if [ $r -ne 0 ]; then
	fail "ssh-add -L failed: exit code $r"
fi

trace "simple connect via agent"
${SSH} -F $OBJ/ssh_proxy somehost exit 52
r=$?
if [ $r -ne 52 ]; then
	fail "ssh connect with failed (exit code $r)"
fi

for t in ${SSH_KEYTYPES}; do
	trace "connect via agent using $t key"
	${SSH} -F $OBJ/ssh_proxy -i $OBJ/$t-agent.pub -oIdentitiesOnly=yes \
		somehost exit 52
	r=$?
	if [ $r -ne 52 ]; then
		fail "ssh connect with failed (exit code $r)"
	fi
done

trace "agent forwarding"
${SSH} -A -F $OBJ/ssh_proxy somehost ${SSHADD} -l > /dev/null 2>&1
r=$?
if [ $r -ne 0 ]; then
	fail "ssh-add -l via agent fwd failed (exit code $r)"
fi
${SSH} "-oForwardAgent=$SSH_AUTH_SOCK" -F $OBJ/ssh_proxy somehost ${SSHADD} -l > /dev/null 2>&1
r=$?
if [ $r -ne 0 ]; then
	fail "ssh-add -l via agent path fwd failed (exit code $r)"
fi
${SSH} -A -F $OBJ/ssh_proxy somehost \
	"${SSH} -F $OBJ/ssh_proxy somehost exit 52"
r=$?
if [ $r -ne 52 ]; then
	fail "agent fwd failed (exit code $r)"
fi

trace "agent forwarding different agent"
${SSH} "-oForwardAgent=$FW_SSH_AUTH_SOCK" -F $OBJ/ssh_proxy somehost ${SSHADD} -l > /dev/null 2>&1
r=$?
if [ $r -ne 0 ]; then
	fail "ssh-add -l via agent path fwd of different agent failed (exit code $r)"
fi
${SSH} '-oForwardAgent=$FW_SSH_AUTH_SOCK' -F $OBJ/ssh_proxy somehost ${SSHADD} -l > /dev/null 2>&1
r=$?
if [ $r -ne 0 ]; then
	fail "ssh-add -l via agent path env fwd of different agent failed (exit code $r)"
fi

# Remove keys from forwarded agent, ssh-add on remote machine should now fail.
SSH_AUTH_SOCK=$FW_SSH_AUTH_SOCK ${SSHADD} -D > /dev/null 2>&1
r=$?
if [ $r -ne 0 ]; then
	fail "ssh-add -D failed: exit code $r"
fi
${SSH} '-oForwardAgent=$FW_SSH_AUTH_SOCK' -F $OBJ/ssh_proxy somehost ${SSHADD} -l > /dev/null 2>&1
r=$?
if [ $r -ne 1 ]; then
	fail "ssh-add -l with different agent did not fail with exit code 1 (exit code $r)"
fi

(printf 'cert-authority,principals="estragon" '; cat $OBJ/user_ca_key.pub) \
	> $OBJ/authorized_keys_$USER
for t in ${SSH_KEYTYPES}; do
	trace "connect via agent using $t key"
	${SSH} -F $OBJ/ssh_proxy -i $OBJ/$t-agent.pub \
		-oCertificateFile=$OBJ/$t-agent-cert.pub \
		-oIdentitiesOnly=yes somehost exit 52
	r=$?
	if [ $r -ne 52 ]; then
		fail "ssh connect with failed (exit code $r)"
	fi
done

trace "delete all agent keys"
${SSHADD} -D > /dev/null 2>&1
r=$?
if [ $r -ne 0 ]; then
	fail "ssh-add -D failed: exit code $r"
fi

trace "kill agent"
${SSHAGENT} -k > /dev/null
SSH_AGENT_PID=$FW_SSH_AGENT_PID ${SSHAGENT} -k > /dev/null
