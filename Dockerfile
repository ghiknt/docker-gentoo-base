##################################################################
# Base Gentoo image to use for other images
# License: AGPL 3.0+
##################################################################
From gentoo:latest-hardened
Maintainer whk <https://whk.name/about/me/>


# Set timezone to UTC
RUN /usr/sbin/zic -l Etc/UTC


###############################################################
# Create /usr/portage and populate
###############################################################
RUN emerge-webrsync

################################################################
# Set build to use packages signed by Gentoo keys
# Source: <https://wwwold.gentoo.org/proj/en/releng/index.xml>
#         <https://wiki.gentoo.org/wiki/Handbook:AMD64/Working/Features>
###############################################################
# Install GPG - Chicken and Egg - GPG must be installed to check signatures so it is installed without check
#  TODO: Find better solution
RUN emerge app-crypt/gnupg
# Create dir
RUN mkdir -p /etc/portage/gpg
RUN chmod go-rx /etc/portage/gpg
# Get the keys from pgp server
# Trust the snapshot signing keys
#    Expires 2016/07/01 Gentoo Portage Snapshot Signing Key (Automated Signing Key)
RUN gpg --homedir /etc/portage/gpg --keyserver pgp.mit.edu --recv-keys DCD05B71EAB94199527F44ACDB6B8C1F96D8BF6D
RUN echo "trusted-key DB6B8C1F96D8BF6D" >> /etc/portage/gpg/gpg.conf
#    Expires 2016/08/13 Gentoo Linux Release Engineering (Gentoo Linux Release Signing Key)
RUN gpg --homedir /etc/portage/gpg --keyserver pgp.mit.edu --recv-keys D99EAC7379A850BCE47DA5F29E6438C817072058
RUN echo "trusted-key 9E6438C817072058" >> /etc/portage/gpg/gpg.conf
#    Expires 2017/08/25 Gentoo Linux Release Engineering (Automated Weekly Release Key)
RUN gpg --homedir /etc/portage/gpg --keyserver pgp.mit.edu --recv-keys 13EBBDBEDE7A12775DFDB1BABB572E0E2D182910
RUN echo "trusted-key BB572E0E2D182910" >> /etc/portage/gpg/gpg.conf
###############################################################
# Only use webrsync with gpg verification
##############################################################
RUN mkdir -p /etc/portage/repos.conf
ADD websync.conf /etc/portage/repos.conf/websync.conf
ADD make.conf /etc/portage/make.conf


#############################################################
# Get the current list of packages
#############################################################
# Clear the timestamp so we get everything fresh
RUN rm -f /usr/portage/metadata/timestamp.x 
RUN emerge-webrsync


#############################################################
# Update to latest
#############################################################
RUN /usr/bin/emerge --update --deep --newuse --with-bdeps=y @world
RUN /usr/bin/emerge --depclean
RUN /usr/bin/emerge app-portage/gentoolkit
RUN revdep-rebuild

##############################################################
# Make sure package.accept_keywords directory exists
# for later containers
##############################################################
RUN mkdir -p /etc/portage/package.accept_keywords
