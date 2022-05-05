FROM dock.mau.dev/mautrix/instagram

MAINTAINER Fabian Kaindl <gitlab-docker@fabiankaindl.de>
LABEL org.opencontainers.image.description This is the mautrix-instagram Container Image provided by Kaindl Network with added Healthcheck and higher security

# Copy Script into the container
HEALTHCHECK --interval=30s --timeout=3s --retries=5 --start-period=10s \
  CMD code_http=$(curl -sI -o /dev/null -w %{http_code} http://localhost:80); if [ $code_http != 404 ];then exit 1;else exit 0; fi
# This makes the build inconsistent in term of reproduceability but it provides every security update needed until the developer updates the main repository

# Get latest Security Updates
# --no-cache does produce an error when you try to later delete packages
RUN apk -U upgrade && \

# Remove not needed packages to make it distroless
# iputils = ping command and co
# apk-tools alpine-tools alpine-keys libc-utils -> remove apk command
# Nobudy should be able to install software inside an image!!!
# bash = We dont need a shell inside a production container
# Curl is needed for healthcheck and is a dependency from the application!
# Bash is a Dependency of the Application Developer but should not be in the production enviroment -> Could be blacklisted from the removal list

apk del iputils apk-tools alpine-keys libc-utils wget bash && \

# Remove apk-tools entirely and every related files
rm -rf /var/cache/apk /lib/apk /etc/apk && \
# Remove any folders that are not needed to further shrink down image size and make the image simplified 
rm -rf /home /srv /media /root && \
# Remove commands that should not exist in this image -> This commands depends if the software what build nativly for Containers or if it is just ported
rm /sbin/reboot /sbin/poweroff /sbin/arp /sbin/fdisk /sbin/ifconfig
