FROM nginx:alpine
#Copy /etc source to container fs
COPY /etc /etc
COPY bootstrap.sh .
RUN chmod +x /bootstrap.sh
CMD /bootstrap.sh