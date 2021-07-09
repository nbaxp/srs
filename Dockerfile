#https://github.com/ossrs/srs-docker/tree/dev 
FROM ossrs/srs:dev as build

RUN yum install -y git 
RUN git clone --depth 1 -b feature/gb28181 https://github.com/ossrs/srs.git
RUN cd srs/trunk && ./configure && make

FROM ubuntu:18.04

LABEL org.opencontainers.image.authors="76527413@qq.com"

RUN sed -i s/archive.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
    sed -i s/security.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
    apt update -qqy && \
    apt install -y --fix-missing libxml2-dev liblzma-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/srs
EXPOSE 1935 1985 8080

COPY --from=build /tmp/srs/srs/trunk/objs/srs ./objs/srs
COPY --from=build /tmp/srs/srs/trunk/objs/nginx/html/index.html ./objs/nginx/html/index.html
COPY --from=build /tmp/srs/srs/trunk/research/players/crossdomain.xml ./objs/nginx/html/crossdomain.xml
COPY --from=build /tmp/srs/srs/trunk/conf/docker.conf ./conf/srs.conf
COPY --from=build /tmp/srs/srs/trunk/etc ./etc
COPY --from=build /tmp/srs/srs/trunk/usr ./usr
COPY --from=build /tmp/srs/srs/trunk/research/api-server/static-dir  ./objs/nginx/html
COPY --from=build /tmp/srs/srs/trunk/research/console  ./objs/nginx/html/console
COPY --from=build /tmp/srs/srs/trunk/research/players  ./objs/nginx/html/players
COPY --from=build /tmp/srs/srs/trunk/3rdparty/signaling/www/demos  ./objs/nginx/html/demos
COPY --from=build /usr/local/bin/ffmpeg ./objs/ffmpeg/bin/ffmpeg
COPY ./conf/srs.conf ./conf/srs.example.conf

CMD ./objs/srs -c ./conf/srs.conf
