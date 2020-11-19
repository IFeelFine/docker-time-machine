FROM ifeelfine/iff-base-alpine:latest

# Variable Init
ARG BUILD_DATE
ARG VERSION
LABEL build_version="I Feel Fine version: ${VERSION}, Build-date: ${BUILD_DATE}
LABEL maintainer="imbebating"

# (i)   Install Samba & Avahi, 
# (ii)  Define time machine share, 
# (iii) Remove default config files
RUN  apk add --update --no-cache	\
      samba-server			\
      samba-client			\
      samba-common-tools		\
      avahi 				\
 && mkdir /timemachine  		\
 && rm -rf /etc/samba/	 		\
           /etc/avahi/

# Do final system cleanup
RUN rm -rf				\
      /tmp/*				\
      /var/lib/apk/*			\
      /var/tmp/*				

# Copy default config and service files
COPY root/ /

# Export volumes
VOLUME /config /timemachine

# Export Avahi and Samba ports
EXPOSE 5353/udp 445/tcp

HEALTHCHECK --interval=5m --timeout=3s	\
        CMD    (avahi-daemon -c		\
            && smbclient -L '\\localhost' -U '%' -m SMB3 &>/dev/null) || exit 1
