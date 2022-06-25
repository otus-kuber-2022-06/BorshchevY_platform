FROM nginx:1.23
RUN groupadd -r -g 1001 app && useradd -r -u 1001 -g app app
WORKDIR app
COPY app/ .
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/
RUN touch /var/run/nginx.pid && \
    chown -R app:app /var/run/nginx.pid && \
    chown -R app:app /app && \
    chown -R app:app /var/cache/nginx
EXPOSE 8000
USER app
CMD ["nginx", "-g", "daemon off;"]
