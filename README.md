# Creating the Azure Infrastructure using Terraform

## Pre-requisites:
In order Terraform can work, please fill the AZURE SubscriptionID and TenantID inside the `terraform.tfvars` file.

Also for AzureDevOps, you need to download from the DevOps Marketplace 2 Terraform plugins:

https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks

https://marketplace.visualstudio.com/items?itemName=JasonBJohnson.azure-pipelines-tasks-terraform



## TERRAFORM 1st Phase (the Kubernetes infrastructure): 
We built using Terraform in 2 phases the "tf infra", and latesr "tf apps":We built using Terraform in 2 phases the "tf infra" module, and later "tf apps":

Please use: `terraform apply -target=module.infra`

So only apply the AKS cluster now. Skip the rest for now.


then:
```
az aks get-credentials \
  --resource-group aks-prod-rg \
  --name aks-prod \
  --admin \
  --file ~/.kube/aks-config
```

later:
kubectl config get-contexts --kubeconfig ~/.kube/aks-config

export KUBECONFIG=~/.kube/aks-config

kubectl get nodes


## Terraform 2nd Phase (Installing apps: ArgoCD & Traefik): 
Please use: `terraform apply -target=module.apps`

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


# Setting up the Azure DevOps and can work correctly with Terraform & Azure Portal

## Creating new Service Connection via Azure Portal (using Service Principal will make work the task `TerraformCLI@0`)
➡ Go to Azure Active Directory > App registrations

Click New registration

Give it a name (currently in the pipeline we use the name `aks-serviceconnection`)

Register it

Go to Certificates & secrets → New client secret

Copy the secret immediately

*Until this part you can follow this video guide: https://www.youtube.com/watch?v=BX2WF9SOmyw


Later, go to Subscriptions > [your subscription] > Access control (IAM) → Add Role Assignment

Role: Contributor

Assign access to: User, group, or service principal

Select your App (e.g., terraform-sp)



## Add to Azure DevOps Service Connection
➡ Go to Azure DevOps:

Project Settings → Service Connections

Create new → Azure Resource Manager

Choose "App registration or Managed Identity (manual)"

Onde there, Fill in:

- Subscription ID

- Subscription Name

- Tenant ID

- Service Principal ID (Client ID)

- Service Principal Key (Client Secret)


# Terraform Backend

Currently we are creating the backend with a bash file called `backend_creation.sh`

Notice the the backend we are calling it `tfdevbackend2024pidant`, and this name is used in the pipeline config so far.
