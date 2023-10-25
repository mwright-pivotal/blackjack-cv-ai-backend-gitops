{{/*
Expand the name of the chart.
*/}}
{{- define "wallaroo-engine.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wallaroo-engine.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "wallaroo-engine.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wallaroo-engine.labels" -}}
helm.sh/chart: {{ include "wallaroo-engine.chart" . }}
{{ include "wallaroo-engine.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wallaroo-engine.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wallaroo-engine.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wallaroo-engine.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wallaroo-engine.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
    Creates a base64 encoded docker registry json blob for use in a image pull
    secret, just like the `kubectl create secret docker-registry` command does
    for the generated secrets data.dockerconfigjson field. The output is
    verified to be exactly the same even if you have a password spanning
    multiple lines as you may need to use a private GCR registry.

    - https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod
*/}}

{{- define "makeSecret.dockerconfigjson" -}}
{{ include "makeSecret.dockerconfigjson.yaml" . | b64enc }}
{{- end }}

{{- define "makeSecret.dockerconfigjson.yaml" -}}
{{- with .Values.ociRegistry -}}
{
  "auths": {
    {{ .registry | quote }}: {
      "username": {{ .username | quote }},
      "password": {{ .password | quote }},
      "auth": {{ (print .username ":" .password) | b64enc | quote }}
    }
  }
}
{{- end }}
{{- end }}
