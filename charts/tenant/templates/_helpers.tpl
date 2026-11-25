{{- define "tenant.name" -}}
{{- required "name is required" .Values.name -}}
{{- end -}}

{{- define "tenant.namespace" -}}
tenant-{{ include "tenant.name" . }}
{{- end -}}

{{- define "tenant.tier" -}}
{{- $tier := index .Values.tiers .Values.tier -}}
{{- if not $tier -}}
{{- fail (printf "unknown tier: %s" .Values.tier) -}}
{{- end -}}
{{- toYaml $tier -}}
{{- end -}}

{{- define "tenant.labels" -}}
app.kubernetes.io/name: tenant
app.kubernetes.io/instance: {{ include "tenant.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
phantom.cloud/tier: {{ .Values.tier }}
{{- end -}}

{{- define "tenant.selectorLabels" -}}
app.kubernetes.io/name: tenant
app.kubernetes.io/instance: {{ include "tenant.name" . }}
{{- end -}}
