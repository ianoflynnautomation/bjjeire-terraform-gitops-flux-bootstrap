output "namespace" {
  description = "The Flux system namespace"
  value       = kubernetes_namespace_v1.flux_system.metadata[0].name
}

output "flux_operator_status" {
  description = "Status of the Flux operator Helm release"
  value = {
    name      = helm_release.flux_operator.name
    namespace = helm_release.flux_operator.namespace
    status    = helm_release.flux_operator.status
    version   = helm_release.flux_operator.version
  }
}

output "flux_instance_status" {
  description = "Status of the Flux instance Helm release"
  value = {
    name      = helm_release.flux_instance.name
    namespace = helm_release.flux_instance.namespace
    status    = helm_release.flux_instance.status
    version   = helm_release.flux_instance.version
  }
}
