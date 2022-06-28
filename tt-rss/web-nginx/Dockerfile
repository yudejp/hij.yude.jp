FROM nginx:alpine

HEALTHCHECK CMD curl --fail http://localhost/tt-rss/index.php || exit 1

COPY nginx.conf /etc/nginx/nginx.conf
