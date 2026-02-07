instance:
  distribution:
    version: ${flux_version}
    registry: ${flux_registry}
    artifact: "oci://ghcr.io/controlplaneio-fluxcd/flux-operator-manifests:v0.38.1"
  components:
    - source-controller
    - kustomize-controller
    - helm-controller
    - notification-controller
    - image-reflector-controller
    - image-automation-controller
  cluster:
    type: ${cluster_type}
    size: ${cluster_size}
    multitenant: false
    networkPolicy: true
    domain: "cluster.local"
  commonMetadata:
    labels:
      app.kubernetes.io/name: flux
      app.kubernetes.io/managed-by: terraform
    annotations:
      fluxcd.controlplane.io/reconcile: "enabled"
      fluxcd.controlplane.io/reconcileEvery: "1h"
      fluxcd.controlplane.io/reconcileTimeout: "3m"
  healthcheck:
    enabled: true
    timeout: 5m
  sync:
    interval: 1m
    kind: ${sync_kind}
    url: ${git_url}
    ref: ${git_ref}
    path: ${git_path}
    pullSecret: "flux-system"
    provider: ${sync_provider}
  kustomize:
    patches:
      - target:
          kind: Deployment
          labelSelector: "app.kubernetes.io/part-of=flux"
        patch: |
          - op: add
            path: /spec/template/spec/nodeSelector
            value:
              kubernetes.io/os: linux
          - op: add
            path: /spec/template/spec/tolerations
            value:
              - key: "CriticalAddonsOnly"
                operator: "Exists"
      - target:
          kind: ServiceAccount
          name: source-controller
        patch: |
          apiVersion: v1
          kind: ServiceAccount
          metadata:
            name: source-controller
            annotations:
              azure.workload.identity/client-id: ${client_id}
              azure.workload.identity/tenant-id: ${tenant_id}
            labels:
              azure.workload.identity/use: "true"
      - target:
          kind: Deployment
          name: source-controller
        patch: |
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: source-controller
          spec:
            template:
              metadata:
                labels:
                  azure.workload.identity/use: "true"
                    