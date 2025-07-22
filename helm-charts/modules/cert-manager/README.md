# Cert Manager Module

This module deploys the Cert Manager on a Kubernetes cluster.

## Inputs

| Name                        | Description                                                  | Type   | Default | Required |
|-----------------------------|--------------------------------------------------------------|--------|---------|----------|
| `cert_manager_chart_version`| The version of the Cert Manager Helm chart to install.      | string | `""`    | yes      |
| `cert_manager_namespace`    | The Kubernetes namespace to install Cert Manager into.      | string | `""`    | yes      |
| `cert_manager_values`       | Custom values to pass to the Cert Manager Helm chart.       | map    | `{}`    | no       |

## Outputs

| Name                        | Description                                                  |
|-----------------------------|--------------------------------------------------------------|
| `cert_manager_installation` | The installation status of the Cert Manager.                |
