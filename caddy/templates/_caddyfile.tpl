{{- define "caddyfile" -}}
hog.willett.io {
  # direct all api endpoints to the backend
  reverse_proxy /api/* {
    dynamic a witw-backend.default 8000
  }
  reverse_proxy /_health {
    dynamic a witw-backend.default 8000
  }
  # anything else, direct to the frontend
  # reverse_proxy {
  #   dynamic a witw-frontend.default 3000
  # }
}
{{- end -}}
