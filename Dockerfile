FROM ubuntu:20.04 as builder

# Compile
RUN apt-get update &&\
    apt-get install -y patch make gcc libcap-dev libssl-dev libwrap0-dev &&\
    ldconfig
COPY vsftpd-2.3.4.tar.gz vsftpd-2.3.4.tar.gz
COPY smiley.patch smiley.patch
RUN tar -xvf vsftpd-2.3.4.tar.gz && patch -s -p0 < smiley.patch
WORKDIR /vsftpd-2.3.4
RUN make

# Run
FROM ghcr.io/battleofthebots/botb-base-image:ubuntu-defcon-2023
RUN apt-get update &&\
    apt-get install -y libcap2
COPY --from=builder /vsftpd-2.3.4/vsftpd /sbin/vsftpd
COPY vsftpd.conf /etc/vsftpd.conf
RUN mkdir /var/ftp/ &&\
    useradd -d /var/ftp ftp &&\
    mkdir /usr/share/empty &&\
    chown 1000:1000 /sbin/vsftpd &&\
    chown 1000:1000 /etc/vsftpd.conf

USER 1000
ENTRYPOINT /sbin/vsftpd
HEALTHCHECK --interval=1s --retries=1 CMD cat /proc/net/tcp | tr -s ' ' | cut -d ' ' -f 3 | grep ":0015" || exit 1
