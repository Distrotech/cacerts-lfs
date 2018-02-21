SSLDIR = /etc/ssl
URL = http://mxr.mozilla.org/mozilla/source/security/nss/lib/ckfw/builtins/certdata.txt?raw=1


all: ca-certificates.crt cacerts

certdata.txt:
	wget --output-document certdata.txt $(URL)

ca-certificates.crt: certdata.txt
	./make-ca.sh
	./remove-expired-certs.sh certs

clean:
	rm -rf certs certdata.txt ca-certificates.crt cacerts

distclean: clean

cacerts: ca-certificates.crt
	./mkcacerts -f ca-certificates.crt -o cacerts -k keytool -s openssl

install: all
	install -d $(DESTDIR)$(SSLDIR)/certs/java 
	install -m 0644 -t $(DESTDIR)$(SSLDIR)/certs certs/*.pem
	./remove-expired-certs.sh $(DESTDIR)$(SSLDIR)/certs
	rm -f $(DESTDIR)$(SSLDIR)/certs/*.[0-9]*
	c_rehash $(DESTDIR)$(SSLDIR)/certs
	cat ca-certificates.crt |grep -vE "(^$|^SHA1 Fingerprint=)" ca-certificates.crt > $(DESTDIR)$(SSLDIR)/certs/ca-certificates.crt
	if [ -d "./cacerts" ]; then \
	    install -m 0644 -t $(DESTDIR)$(SSLDIR)/certs/java cacerts; \
	fi
