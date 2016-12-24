# Quick and easy way to get a homey pet container.

FROM fedora:25
MAINTAINER Jonathan Lebon <jlebon@redhat.com>

RUN dnf remove -y \
		vim-minimal && \
	dnf install -y \
		vim \
		git \
		sudo \
		findutils && \
	dnf clean all

COPY . /files

WORKDIR /files

RUN utils/git-setup

RUN utils/install-all

CMD ["/bin/bash"]

LABEL RUN="/usr/bin/docker run -ti --rm --privileged \
            -v /:/host --workdir \"/host/\$PWD\" \${OPT1} \
            \${IMAGE}"