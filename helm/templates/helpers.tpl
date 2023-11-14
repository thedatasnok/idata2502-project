{{- define "chart.labels" -}}
chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end -}}

{{- define "backend.name" -}}
{{- printf "%s-%s" .Chart.Name "backend" -}}
{{- end -}}

{{- define "backend.port" -}}
{{- 4000 -}}
{{- end -}}

{{- define "frontend.name" -}}
{{- printf "%s-%s" .Chart.Name "frontend" -}}
{{- end -}} 

{{- define "frontend.port" -}}
{{- 80 -}}
{{- end -}}

{{- define "postgres.name" -}}
{{- printf "%s-%s" .Chart.Name "postgres" -}}
{{- end -}}

{{- define "postgres.port" -}}
{{- 5432 -}}
{{- end -}}

{{- define "postgres.database" -}}
{{- printf "idata" -}}
{{- end -}}
