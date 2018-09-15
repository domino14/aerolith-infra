Note - this is now (hopefully) automated!

How?
- Installed Helm and Tiller, then `cert-manager`
- created `clusterissuer.yaml` and `certificate.yaml` in the deploy-configs directory
- renamed the secret in the `webolith-ingress.yaml` file to match the one in `certificate.yaml` (note I think it causes downtime if I don't do this...)
- `kubectl -f apply` the newly created/edited files.