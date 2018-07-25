FROM alpine:3.8

RUN apk add --update --no-cache bash fish mdocml-apropos openssh openssh-client gcc libc-dev python3-dev py3-pip libxslt-dev libxml2-dev libxml2-utils ansible \
 && rm -f /etc/ssh/ssh_host_*

RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd \
 && echo "KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1" >> /etc/ssh/sshd_config

RUN pip3 install junos-eznc jxmlease

ADD docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

VOLUME [ "/etc/ssh" ]
VOLUME [ "/home" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD netstat -an | grep -q :22 || exit 1

ENV ANSIBLE_USERS=ansible

EXPOSE 22
CMD ["/docker-entrypoint.sh"]