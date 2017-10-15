# Quick and easy way to get a homey pet container.

FROM fedora:26
MAINTAINER Jonathan Lebon <jlebon@redhat.com>

RUN dnf install -y \
		vim \
		git \
		sudo \
		findutils && \
	dnf clean all

COPY . /files

# we install in /usr/local
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd --groups wheel --uid 1000 jlebon && \
    chown -R jlebon:jlebon /files

USER jlebon

RUN cd /files && \
    utils/git-setup && \
    utils/install-all

CMD ["/bin/bash"]

LABEL RUN="/usr/bin/docker run -ti --rm --privileged \
            -v /:/host --workdir \"/host/\$PWD\" \${OPT1} \
            \${IMAGE}"
