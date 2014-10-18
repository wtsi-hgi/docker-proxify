Docker-proxify
==============

Provides a docker container in which outgoing network traffic is transparently proxied over one or more proxy servers. Uses [redsocks](https://github.com/wtsi-hgi/redsocks) and supports standard HTTP proxy (http_proxy), HTTP CONNECT (https_proxy), SOCKS4 (socks4_proxy), or SOCKS5 (socks5_proxy) proxies. It is also configured to support running docker within the container so that it can be used to build docker container images from behind a corporate firewall (assuming you have a proxy to traverse it). 

I developed this because many of my machines are stuck behind a corporate firewall, and there is not currently any good way to support running or building containers in that environment without baking the proxy information into the Dockerfile (which would break portability of the containers). There is a discussion of this issue on [docker repository issue 4962](https://github.com/dotcloud/docker/issues/4962). 

By default the docker-proxify container will route port 80 over the specified HTTP proxy and port 443 over the specified CONNECT proxy, both for the container itself and for any other docker containers running inside it (including `docker build` jobs). This default can be overridden by supplying a port_spec environment variable containing a comma-separated list of port:proxy pairs. For example, the default is: "80:HTTP,443:CONNECT"
One could add a forwarding of port 8000 also over HTTP by setting port_spec to: "80:HTTP,443:CONNECT,8000:HTTP"

Usage
-----
Because the docker daemon is run inside the container, you need to run it with the `--privileged` flag. Proxy settings are passed in as environment variables (http_proxy, https_proxy, socks4_proxy, socks5_proxy). 

The entrypoint defaults to an interactive bash shell from which docker can be run:
```bash
$ docker run -i -t --privileged -e http_proxy -e https_proxy jrandall/docker-proxify
Waiting for docker daemon to start......... ready.
root@3014a04166fb:/docker# docker run -i -t ubuntu bash
Unable to find image 'ubuntu' locally
Pulling repository ubuntu
a7cf8ae4e998: Download complete
3db9c44f4520: Download complete
316b678ddf48: Download complete
99ec81b80c55: Download complete
5e019ab7bf6d: Download complete
74fe38d11401: Download complete
511136ea3c5a: Download complete
5e66087f3ffe: Download complete
4d26dd3ebc1c: Download complete
d4010efcfd86: Download complete
f10ebce2c0e1: Download complete
ef519c9ee91a: Download complete
e2aa6665d371: Download complete
02dae1c13f51: Download complete
6cfa4d1f33fb: Download complete
07302703becc: Download complete
e7206bfc66aa: Download complete
cb12405ee8fa: Download complete
cf8dc907452c: Download complete
f0ee64c4df74: Download complete
82cdea7ab5b5: Download complete
2209cbf9dcd3: Download complete
5dbd9cb5a02f: Download complete
root@3a57fc8ec405:/# apt-get update
Ign http://archive.ubuntu.com trusty InRelease
Ign http://archive.ubuntu.com trusty-updates InRelease
Ign http://archive.ubuntu.com trusty-security InRelease
Get:1 http://archive.ubuntu.com trusty Release.gpg [933 B]
Get:2 http://archive.ubuntu.com trusty-updates Release.gpg [933 B]
Get:3 http://archive.ubuntu.com trusty-security Release.gpg [933 B]
Get:4 http://archive.ubuntu.com trusty Release [58.5 kB]
Get:5 http://archive.ubuntu.com trusty-updates Release [58.5 kB]
Get:6 http://archive.ubuntu.com trusty-security Release [58.5 kB]
Get:7 http://archive.ubuntu.com trusty/main Sources [1064 kB]
Get:8 http://archive.ubuntu.com trusty/restricted Sources [5433 B]
Get:9 http://archive.ubuntu.com trusty/universe Sources [6399 kB]
Get:10 http://archive.ubuntu.com trusty/main amd64 Packages [1350 kB]
Get:11 http://archive.ubuntu.com trusty/restricted amd64 Packages [13.0 kB]
Get:12 http://archive.ubuntu.com trusty/universe amd64 Packages [5859 kB]
Get:13 http://archive.ubuntu.com trusty-updates/main Sources [41.4 kB]
Get:14 http://archive.ubuntu.com trusty-updates/restricted Sources [14 B]
Get:15 http://archive.ubuntu.com trusty-updates/universe Sources [26.6 kB]
Get:16 http://archive.ubuntu.com trusty-updates/main amd64 Packages [98.0 kB]
Get:17 http://archive.ubuntu.com trusty-updates/restricted amd64 Packages [14 B]
Get:18 http://archive.ubuntu.com trusty-updates/universe amd64 Packages [67.1 kB]
Get:19 http://archive.ubuntu.com trusty-security/main Sources [15.6 kB]
Get:20 http://archive.ubuntu.com trusty-security/restricted Sources [14 B]
Get:21 http://archive.ubuntu.com trusty-security/universe Sources [4212 B]
Get:22 http://archive.ubuntu.com trusty-security/main amd64 Packages [49.4 kB]
Get:23 http://archive.ubuntu.com trusty-security/restricted amd64 Packages [14 B]
Get:24 http://archive.ubuntu.com trusty-security/universe amd64 Packages [17.7 kB]
Fetched 15.2 MB in 5s (2706 kB/s)
Reading package lists... Done
root@3a57fc8ec405:/# 
```

You can also run docker within docker all in one command: 
```bash
$ docker run -i -t --privileged -e http_proxy -e https_proxy jrandall/docker-proxify docker run -i -t ubuntu bash
Waiting for docker daemon to start........................................ ready.
Unable to find image 'ubuntu' locally
Pulling repository ubuntu
99ec81b80c55: Download complete
a7cf8ae4e998: Download complete
316b678ddf48: Download complete
5e019ab7bf6d: Download complete
3db9c44f4520: Download complete
74fe38d11401: Download complete
511136ea3c5a: Download complete
5e66087f3ffe: Download complete
4d26dd3ebc1c: Download complete
d4010efcfd86: Download complete
ef519c9ee91a: Download complete
6cfa4d1f33fb: Download complete
e2aa6665d371: Download complete
f10ebce2c0e1: Download complete
02dae1c13f51: Download complete
82cdea7ab5b5: Download complete
e7206bfc66aa: Download complete
07302703becc: Download complete
f0ee64c4df74: Download complete
5dbd9cb5a02f: Download complete
cf8dc907452c: Download complete
2209cbf9dcd3: Download complete
cb12405ee8fa: Download complete
root@14119cc449d7:/# 
```

And, of course, you can also perform builds: 
```bash
$ docker run -i -t --privileged -e http_proxy -e https_proxy jrandall/docker-proxify
Waiting for docker daemon to start........................................ ready.
root@cfe1d7f50ae7:/docker# docker build -q github.com/dockerfile/ubuntu
Uploading context 179.7 kB
Uploading context
Step 0 : FROM ubuntu:14.04
Pulling repository ubuntu
99ec81b80c55: Download complete
511136ea3c5a: Download complete
5e66087f3ffe: Download complete
4d26dd3ebc1c: Download complete
d4010efcfd86: Download complete
 ---> 99ec81b80c55
Step 1 : RUN  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list &&  apt-get update &&  apt-get -y upgrade &&  apt-get install -y build-essential &&  apt-get install -y software-properties-common &&  apt-get install -y byobu curl git htop man unzip vim wget
 ---> Running in 962eb069652b
  ---> 22da5f7ea962
Removing intermediate container 962eb069652b
Step 2 : ADD root/.bashrc /root/.bashrc
 ---> 88e1fd9d0b6b
Removing intermediate container 3914e9c5dff9
Step 3 : ADD root/.gitconfig /root/.gitconfig
 ---> ab4287ac0538
Removing intermediate container 16a46d7b93e3
Step 4 : ADD root/scripts /root/scripts
 ---> 064e5b50317b
Removing intermediate container 793dc91e2dee
Step 5 : ENV HOME /root
 ---> Running in c9861ddb3b83
 ---> b0733c094c91
Removing intermediate container c9861ddb3b83
Step 6 : WORKDIR /root
 ---> Running in cf95cf89c834
 ---> b359db7cbd41
Removing intermediate container cf95cf89c834
Step 7 : CMD ["bash"]
 ---> Running in 7d0ded16cc56
 ---> afcd247466a7
Removing intermediate container 7d0ded16cc56
Successfully built afcd247466a7
root@4ad182e3a976:/docker# docker run -i -t afcd247466a7
[ root@5556a3ca0a17:~ ]$
```

Local Proxy Servers
-------------------
If you are trying to access a proxy server running on localhost (for example, cntlm as a pass-through to an NTLM proxy requiring authentication, or a local squid cache), please note that you will not be able to access a daemon listening on the host from within the container. For example, setting `http_proxy = '127.0.0.1:3128'` will not allow docker-proxify to access a proxy server running on the container host listening on 3128. To work around this problem, you can either run the proxy server from within docker-proxify or you will need to bind the daemon to an interface with a real IP address. To run a proxy server from within docker-proxify, you'd need to first run docker-proxify and install the proxy server software and any configuration you need, and then commit those changes to a new image from the changes you made to the container, and then run that image in place of 'jrandall/docker-proxify'.
