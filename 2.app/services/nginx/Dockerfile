FROM nginx:1.15.0-alpine

RUN rm /etc/nginx/conf.d/default.conf
COPY /prod.conf /etc/nginx/conf.d
RUN sed "s|web|${swarm_stack}web|g" /etc/nginx/conf.d/prod.conf
