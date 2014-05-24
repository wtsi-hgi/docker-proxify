# 
# Docker-proxify Dockerfile
#
# https://github.com/wtsi-hgi/docker-proxify

FROM jrandall/redsocks
MAINTAINER "Joshua C. Randall" <jcrandall@alum.mit.edu>

# Install git tree
ADD . /docker-proxify
WORKDIR /docker-proxify

