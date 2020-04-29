FROM alpine:latest
RUN apk update && \
    apk add curl && \
    apk add bash && \
    apk add ssmtp

COPY ssmtp.conf /etc/ssmtp/ssmtp.conf
COPY url_monitor.sh /root/url_monitor.sh
COPY url_list.conf /root/url_list.conf
COPY email.conf /root/email.conf

ENTRYPOINT ["bash"]
CMD ["/root/url_monitor.sh"]

