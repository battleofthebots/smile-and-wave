# Smile and Wave
### VSFTPD 2.3.4 smiley face backdoor

This is a recreation of the smiley ftp backdoor.

The Dockerfile
- Installs the necessary build packages
- Extracts the vsftpd 2.3.4 source code from its tarball
- Applies a patch file which inserts the backdoor and makes updates the makefile
- Creates/installs all the necessary things to configure and run vsftpd

## Building
```sh
docker build . -t smile-and-wave
```

## Running
```sh
docker run --cpus=1 -p 21:21 -p 6200:6200 smile-and-wave
```

## Exploiting
```sh
python3 poc.py localhost
```
