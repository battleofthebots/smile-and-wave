FROM ubuntu:20.04 as builder

# Compile
RUN apt-get update &&\
    apt-get install -y patch make gcc libcap-dev libssl-dev libwrap0-dev &&\
    ldconfig
COPY vsftpd-2.3.4.tar.gz vsftpd-2.3.4.tar.gz
COPY smiley.patch smiley.patch
RUN tar -xvf vsftpd-2.3.4.tar.gz && patch -s -p0 < smiley.patch
WORKDIR vsftpd-2.3.4
RUN make

# Run
FROM ubuntu:20.04
RUN apt-get update &&\
    apt-get install -y libcap2
COPY --from=builder /vsftpd-2.3.4/vsftpd /sbin/vsftpd
COPY vsftpd.conf /etc/vsftpd.conf
RUN useradd -u 1000 vsftpd &&\
    mkdir /var/ftp/ &&\
    useradd -d /var/ftp ftp &&\
    mkdir /usr/share/empty &&\
    chown vsftpd:vsftpd /sbin/vsftpd &&\
    chown vsftpd:vsftpd /etc/vsftpd.conf

USER vsftpd
ENTRYPOINT /sbin/vsftpd
HEALTHCHECK --interval=1s --retries=1 CMD cat /proc/net/tcp | tr -s ' ' | cut -d ' ' -f 3 | grep ":0015" || exit 1
