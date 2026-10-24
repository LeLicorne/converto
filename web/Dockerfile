FROM nginx:alpine

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY index.html confidentialite.html accessibilite.html mentions-legales.html /opt/templates/
COPY style.css lang.js test.html test.js test-logic.js /usr/share/nginx/html/
COPY assets /usr/share/nginx/html/assets
COPY docker/40-site-config.sh /docker-entrypoint.d/40-site-config.sh
RUN chmod +x /docker-entrypoint.d/40-site-config.sh

EXPOSE 80
