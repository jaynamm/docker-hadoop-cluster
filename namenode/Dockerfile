FROM hadoop-base:latest

RUN echo "dn1" > /opt/hadoop/hadoop-2.7.7/etc/hadoop/slaves \
    && echo "dn2" >> /opt/hadoop/hadoop-2.7.7/etc/hadoop/slaves \ 
    && echo "dn3" >> /opt/hadoop/hadoop-2.7.7/etc/hadoop/slaves

# Hadoop namenode format
RUN /opt/hadoop/hadoop-2.7.7/bin/hadoop namenode -format

# CMD ["start-all.sh"]