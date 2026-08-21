{{- define "boutique-services.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "boutique-services.labels" -}}
app: {{ include "boutique-services.name" . }}
app.kubernetes.io/name: {{ include "boutique-services.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
