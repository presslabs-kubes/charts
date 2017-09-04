# vim: set ft=nginx:
{{- define "gs-proxy.config" -}}
gzip on;
server_tokens off;

upstream gs {
    server                 storage.googleapis.com:443;
    keepalive              128;
}

resolver                   8.8.8.8 valid=300s ipv6=off;
resolver_timeout           10s;

server {
    server_name _;
    listen 80 default_server;

    if ( $request_method !~ "GET|HEAD" ) {
        return 405;
    }

    set $bucket_name "{{ .Values.config.bucket }}";
    set $index_name  "{{ .Values.config.index }}";

    location / {
        rewrite /$ $uri$index_name;

        proxy_set_header    Host storage.googleapis.com;
        proxy_pass          https://gs/$bucket_name$uri;
        proxy_http_version  1.1;
        proxy_set_header    Connection "";

        proxy_intercept_errors on;
        proxy_hide_header       alt-svc;
        proxy_hide_header       X-GUploader-UploadID;
        proxy_hide_header       alternate-protocol;
        proxy_hide_header       x-goog-hash;
        proxy_hide_header       x-goog-generation;
        proxy_hide_header       x-goog-metageneration;
        proxy_hide_header       x-goog-stored-content-encoding;
        proxy_hide_header       x-goog-stored-content-length;
        proxy_hide_header       x-goog-storage-class;
        proxy_hide_header       x-xss-protection;
        proxy_hide_header       accept-ranges;
        proxy_hide_header       Set-Cookie;
        proxy_ignore_headers    Set-Cookie;
    }
}
{{- end -}}
