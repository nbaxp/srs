ARG BUILD_IMAGE=ossrs/srs:dev
ARG DIST_IMAGE=ubuntu:18.04
ARG BTANCH=4.0release

FROM $BUILD_IMAGE as build

RUN yum install -y git 

##release 4.0
RUN git clone --depth 1 -b 4.0release https://github.com/ossrs/srs.git
RUN cd srs/trunk && ./configure && make

##gb28181:https://github.com/ossrs/srs/issues/1500#issue-528623588
#RUN git clone --depth 1 -b feature/gb28181 https://github.com/ossrs/srs.git
#RUN cd srs/trunk && ./configure --with-gb28181 && make

##h265:https://github.com/ossrs/srs/issues/2053
#RUN git clone --depth 1 -b feature/h265 https://github.com/ossrs/srs.git
#RUN cd srs && sed -i '1455s#vcodec->NAL_unit_length#nal_len_size#' ./trunk/src/kernel/srs_kernel_codec.cpp
#RUN cd srs/trunk && ./configure && make

FROM $DIST_IMAGE

LABEL org.opencontainers.image.authors="76527413@qq.com"

RUN sed -i s/archive.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
    sed -i s/security.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
    apt update -y && \
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

CMD ./objs/srs -c ./conf/srs.conf

