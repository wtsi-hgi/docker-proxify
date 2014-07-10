# 
# Docker-proxify Dockerfile
#
# https://github.com/wtsi-hgi/docker-proxify

FROM jrandall/redsocks
MAINTAINER "Joshua C. Randall" <jcrandall@alum.mit.edu>

# Install docker-within-docker requirements
RUN apt-get update && apt-get install -qqy ca-certificates lxc aufs-tools git 
ADD https://get.docker.io/builds/Linux/x86_64/docker-latest /usr/local/bin/docker
RUN chmod +x /usr/local/bin/docker
VOLUME /var/lib/docker

# Install docker-proxify
ADD ./docker-proxify /usr/local/bin/docker-proxify
ADD ./docker-proxify-daemon /usr/local/bin/docker-proxify-daemon
ADD ./docker-in-docker-setup /usr/local/bin/docker-in-docker-setup
ADD ./docker-proxify-entrypoint /usr/local/bin/docker-proxify-entrypoint
RUN chmod +x /usr/local/bin/docker-*

RUN mkdir /docker
WORKDIR /docker
CMD ["bash"]
ENTRYPOINT ["/usr/local/bin/docker-proxify-entrypoint"]
