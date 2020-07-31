FROM nginx:1.18
RUN rm -f /etc/nginx/conf.d/*

ENV TZ Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD ./docker/nginx/app.conf /etc/nginx/conf.d/app.conf

EXPOSE 80

CMD sed -i -e s/RAILS_HOST/$RAILS_HOST/g /etc/nginx/conf.d/app.conf && \
    /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf