FROM amazon/aws-cli:2.0.6
COPY update-ip.sh .

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["./update-ip.sh"]