SHELL=/bin/bash
srcdir=.
SSH_OCSP=yes
#SSH_OCSP=no
RSAKEYBITS=2048


all:


clean: ldap_clean
	-rm -f testhostkey_*
	-rm -f testid_*
	-rm -f selfid_*
	-rm -f testocsp_*
	-rm -fr ca-test/
	-rm -f ca-?.log
	-rm -f ca-3.*.log
	-rm -f va-*.log
	-rm -f sshd_x509.log

distclean: clean
	-rm -f env
	-rm -f Makefile

# ===

check-certs: ca_files hostkeys identities selfidentities ocsp_certs crl_files ldap_files
	@echo
	$(SHELL) $(srcdir)/ssh_x509tests.sh

# ===
ca_files: ca-test/catest.config ca-test/catest-bundle.crt

#user is responsible to recreate X.509 tests files !!!
#ca-test/catest.config: $(srcdir)/config
ca-test/catest.config:
	@echo
	SSH_OCSP=$(SSH_OCSP) \
	$(SHELL) $(srcdir)/1-cre_cadb.sh

ca-test/catest-bundle.crt: ca-test/catest.config
	@echo
	$(SHELL) $(srcdir)/2-cre_cakeys.sh

# ===
#some versions of ksh fail to expand ${1+"$@"} if last argument is
#empty string. so use ... -N "" -f $@ instead ... -f $@ -N ""


hostkeys: testhostkey_rsa.certstamp testhostkey_dsa.certstamp

testhostkey_rsa:
	@echo
	@echo "generating RSA 'hostkey'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t rsa -b $(RSAKEYBITS) -N "" -f $@

testhostkey_rsa.certstamp: testhostkey_rsa ca-test/catest-bundle.crt
	@echo
	@echo "generating RSA server certificates, keys, etc."
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testhostkey_rsa -t server -n "localhost RSA"

testhostkey_dsa:
	@echo
	@echo "generating DSA 'hostkey'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t dsa -N "" -f $@

testhostkey_dsa.certstamp: testhostkey_dsa ca-test/catest-bundle.crt
	@echo
	@echo "generating DSA server certificates, keys, etc."
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testhostkey_dsa -t server -n "localhost DSA"

hostkeys: testhostkey_eccnistp256.certstamp
hostkeys: testhostkey_eccnistp384.certstamp
hostkeys: testhostkey_eccnistp521.certstamp

testhostkey_eccnistp256:
	@echo
	@echo "generating ECDSA(nistp256) 'Identity'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t ecdsa -b 256 -N "" -f $@

testhostkey_eccnistp256.certstamp: testhostkey_eccnistp256 ca-test/catest-bundle.crt
	@echo
	@echo "generating ECDSA(nistp256) server certificates, keys, etc."
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testhostkey_eccnistp256 -t server -n "localhost ECDSA(nistp256)"

testhostkey_eccnistp384:
	@echo
	@echo "generating ECDSA(nistp384) 'Identity'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t ecdsa -b 384 -N "" -f $@

testhostkey_eccnistp384.certstamp: testhostkey_eccnistp384 ca-test/catest-bundle.crt
	@echo
	@echo "generating ECDSA(nistp384) server certificates, keys, etc."
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testhostkey_eccnistp384 -t server -n "localhost ECDSA(nistp384)"

testhostkey_eccnistp521:
	@echo
	@echo "generating ECDSA(nistp521) 'Identity'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t ecdsa -b 521 -N "" -f $@

testhostkey_eccnistp521.certstamp: testhostkey_eccnistp521 ca-test/catest-bundle.crt
	@echo
	@echo "generating ECDSA(nistp521) server certificates, keys, etc."
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testhostkey_eccnistp521 -t server -n "localhost ECDSA(nistp521)"


# ===
identities: testid_rsa.certstamp testid_dsa.certstamp

testid_rsa:
	@echo
	@echo "generating RSA 'Identity'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t rsa -b $(RSAKEYBITS) -N "" -f $@

testid_rsa.certstamp: testid_rsa ca-test/catest-bundle.crt
	@echo
	@echo "generating RSA client certificates, keys, etc."
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testid_rsa -t client -n "SSH RSA test certificate"

testid_dsa:
	@echo
	@echo "generating DSA 'Identity'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t dsa -N "" -f $@

testid_dsa.certstamp: testid_dsa ca-test/catest-bundle.crt
	@echo
	@echo "generating DSA client certificates, keys, etc."
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testid_dsa -t client -n "SSH DSA test certificate"

identities: testid_eccnistp256.certstamp
identities: testid_eccnistp384.certstamp
identities: testid_eccnistp521.certstamp

testid_eccnistp256:
	@echo
	@echo "generating ECDSA(nistp256) 'Identity'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t ecdsa -b 256 -N "" -f $@

testid_eccnistp256.certstamp: testid_eccnistp256 ca-test/catest-bundle.crt
	@echo
	@echo "generating ECDSA(nistp256) client certificates, keys, etc."
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testid_eccnistp256 -t client -n "SSH ECDSA(nistp256) test certificate"

testid_eccnistp384:
	@echo
	@echo "generating ECDSA(nistp384) 'Identity'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t ecdsa -b 384 -N "" -f $@

testid_eccnistp384.certstamp: testid_eccnistp384 ca-test/catest-bundle.crt
	@echo
	@echo "generating ECDSA(nistp384) client certificates, keys, etc."
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testid_eccnistp384 -t client -n "SSH ECDSA(nistp384) test certificate"

testid_eccnistp521:
	@echo
	@echo "generating ECDSA(nistp521) 'Identity'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t ecdsa -b 521 -N "" -f $@

testid_eccnistp521.certstamp: testid_eccnistp521 ca-test/catest-bundle.crt
	@echo
	@echo "generating ECDSA(nistp521) client certificates, keys, etc."
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testid_eccnistp521 -t client -n "SSH ECDSA(nistp521) test certificate"


# ===
selfidentities: selfid_rsa.certstamp selfid_dsa.certstamp

selfid_rsa.certstamp: selfid_rsa
	@echo
	@echo "generating RSA client self-signed certificates, keys, etc."
	$(SHELL) $(srcdir)/3-cre_certs.sh -f selfid_rsa -t self -n "SSH RSA test self-signed certificate"

selfid_rsa:
	@echo
	@echo "generating RSA 'Identity' for self-signed"
	$(SHELL) $(srcdir)/2-cre_key.sh -t rsa -b $(RSAKEYBITS) -N "" -f $@

selfid_dsa.certstamp: selfid_dsa
	@echo
	@echo "generating DSA client self-signed certificates, keys, etc."
	$(SHELL) $(srcdir)/3-cre_certs.sh -f selfid_dsa -t self -n "SSH DSA test self-signed certificate"

selfid_dsa:
	@echo
	@echo "generating DSA 'Identity' for self-signed"
	$(SHELL) $(srcdir)/2-cre_key.sh -t dsa -N "" -f $@


# ===
#ocsp_certs:
ocsp_certs: testocsp_rsa.certstamp testocsp_dsa.certstamp

testocsp_rsa.certstamp: testocsp_rsa ca-test/catest-bundle.crt
	@echo; echo "generating RSA ocsp responder certificates."
	SSH_OCSP=$(SSH_OCSP) \
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testocsp_rsa -t ocsp -n "validator RSA"

testocsp_rsa:
	@echo; echo "generating RSA 'ocspkey'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t rsa -b $(RSAKEYBITS) -N "" -f $@

testocsp_dsa.certstamp: testocsp_dsa ca-test/catest-bundle.crt
	@echo; echo "generating DSA ocsp responder certificates."
	SSH_OCSP=$(SSH_OCSP) \
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testocsp_dsa -t ocsp -n "validator DSA"

testocsp_dsa:
	@echo; echo "generating DSA 'ocspkey'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t dsa -N "" -f $@

ocsp_certs: testocsp_eccnistp256.certstamp
ocsp_certs: testocsp_eccnistp384.certstamp
ocsp_certs: testocsp_eccnistp521.certstamp

testocsp_eccnistp256.certstamp: testocsp_eccnistp256 ca-test/catest-bundle.crt
	@echo; echo "generating RSA ocsp responder certificates."
	SSH_OCSP=$(SSH_OCSP) \
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testocsp_eccnistp256 -t ocsp -n "validator ECDSA(nistp256)"

testocsp_eccnistp256:
	@echo; echo "generating ECDSA(nistp256) 'ocspkey'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t ecdsa -b 256 -N "" -f $@

testocsp_eccnistp384.certstamp: testocsp_eccnistp384 ca-test/catest-bundle.crt
	@echo; echo "generating RSA ocsp responder certificates."
	SSH_OCSP=$(SSH_OCSP) \
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testocsp_eccnistp384 -t ocsp -n "validator ECDSA(nistp384)"

testocsp_eccnistp384:
	@echo; echo "generating ECDSA(nistp384) 'ocspkey'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t ecdsa -b 384 -N "" -f $@

testocsp_eccnistp521.certstamp: testocsp_eccnistp521 ca-test/catest-bundle.crt
	@echo; echo "generating RSA ocsp responder certificates."
	SSH_OCSP=$(SSH_OCSP) \
	$(SHELL) $(srcdir)/3-cre_certs.sh -f testocsp_eccnistp521 -t ocsp -n "validator ECDSA(nistp521)"

testocsp_eccnistp521:
	@echo; echo "generating ECDSA(nistp521) 'ocspkey'"
	$(SHELL) $(srcdir)/2-cre_key.sh -t ecdsa -b 521 -N "" -f $@


# ===
crl_files: ca-test/catest-bundle.crl

ca-test/catest-bundle.crl: testid_rsa-rsa_sha1 testid_dsa-rsa_sha1
	@echo
	$(SHELL) $(srcdir)/4-cre_crls.sh

# ===
ldap_files:
#ldap_files: ldap/slapd.conf.tmpl

#ldap/slapd.conf.tmpl: env
#	@echo
#	$(SHELL) $(srcdir)/5-cre_ldap.sh

ldap_clean:
#ldap_clean:
#	-rm -f ldap_setup.log
#	-rm -fr ldap
