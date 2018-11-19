FROM centos:7 as builder

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install \
	automake \
	boost-devel \
	gcc \
	gcc-c++ \
	git \
	libcap-devel \
	libdb4-cxx-devel \
	libevent-devel \
	libseccomp-devel \
	make \
	miniupnpc-devel \
	openssl-devel \
	patch \
	protobuf-devel \
	;

ARG VERSION

COPY build_fix.patch /root/build_fix.patch

RUN set -ex; \
	git clone --depth 1 -b ${VERSION} --recurse-submodules https://github.com/vergecurrency/VERGE.git /root/verge; \
	cd /root/verge; \
	patch -p1 < /root/build_fix.patch; \
	./autogen.sh; \
	CPPFLAGS=-I/usr/include/libdb4 ./configure --disable-tests --with-daemon --with-gui=no --prefix=/root/prefix; \
	make -j$(nproc); \
	make install



FROM centos:7

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install \
	boost-chrono \
	boost-filesystem \
	boost-program-options \
	boost-system \
	boost-thread \
	libdb4-cxx \
	libevent \
	libpcap \
	libseccomp \
	miniupnpc \
	openssl \
	;

COPY --from=builder /root/prefix/* /

RUN useradd -m -u 1000 -s /bin/bash runner
USER runner

ENTRYPOINT ["VERGEd"]
