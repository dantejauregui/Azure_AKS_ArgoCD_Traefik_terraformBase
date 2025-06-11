# Creating the Azure Infrastructure using Terraform

We built using Terraform in 2 phases the tf infra:

## 1st command (the Kubernetes infrastructure): 
```
terraform apply \
  -target=azurerm_resource_group.main \
  -target=azurerm_virtual_network.main \
  -target=azurerm_subnet.aks \
  -target=azurerm_log_analytics_workspace.main \
  -target=azurerm_recovery_services_vault.main \
  -target=azurerm_kubernetes_cluster.aks \
  -target=azurerm_backup_policy_vm.aks
```
So only apply the AKS cluster now. Skip the rest for now.


then:
```
az aks get-credentials \
  --resource-group aks-prod-rg \
  --name aks-prod-cluster \
  --admin \
  --file ~/.kube/aks-config
```

later:
kubectl config get-contexts --kubeconfig ~/.kube/aks-config

export KUBECONFIG=~/.kube/aks-config

kubectl get nodes


## 2nd command (Installing ArgoCD & Traefik): 
Please use: `terraform apply`

With this 2nd command, the other resources that are inside the phase2.tf file will be added (like Helm/Kubernetes ones), they depend on the AKS cluster being ready (used the phase1 command).


Finally: to visit Argo UI and Traefik Dashboard, you have to find the External-IP using `kubectl get svc -n traefik`, and later add in your `/etc/hosts` file like:

14.33.146.195  argocd.aks-prod.eastus.cloudapp.azure.com

14.33.146.195  traefik.aks-prod.eastus.cloudapp.azure.com

for production purposes you need to create a DNS record in Azure DNS.

## Login to ArgoCD:
To login to ArgoCD, the default User is `admin`,

### to find the password to login use this command:
This retrieves the auto-generated password:
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode; echo
```

### or recreate a new bcrypt encrypted password using Htpasswd `sudo apt install apache2-utils`:
```
htpasswd -nbBC 10 "" "admin123" | tr -d ': ' 
```

later Patch the secret in the ArgoCD namespace:
```
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {"admin.password": "<YOUR-NEW-PASSWORD>"}}'
```

Finally, restart the ArgoCD Server Pod:
```
kubectl delete pod -n argocd -l app.kubernetes.io/name=argocd-server
```



# Steps to Destroy all the infrastructure from Azure:

first delete manually the logs:
```
az resource delete \
  --resource-group aks-prod-rg \
  --name "ContainerInsights(aks-logs)" \
  --resource-type "Microsoft.OperationsManagement/solutions"
```

finally:
`terraform destroy`