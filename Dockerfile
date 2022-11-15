FROM nginx:alpine
#Copy /etc source to container fs
COPY /etc /etc
COPY bootstrap.sh .
RUN chmod +x /bootstrap.sh \
 && apk update \
 && apk add --update certbot \
 && apk add --update openssl
CMD /bootstrap.sh