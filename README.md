# Voting App

A simple distributed application running across multiple Docker containers.
The purpose of this app is to know what is the most preferred way to learn by: Listening or Practising.


## Architecture

![Architecture diagram](architecture.png)

* A front-end web app in [Python](/vote) which lets you vote between two options
* A [Redis](https://hub.docker.com/_/redis/) which collects new votes
* A [.NET](/worker/) worker which consumes votes and stores them in…
* A [Postgres](https://hub.docker.com/_/postgres/) database backed by a Docker volume
* A [Node.js](/result) web app which shows the results of the voting in real time

## Challenge
The goal of the challenge is to deploy this distributed application into AWS cloud provider, using:
- Use [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started) for create the azure infrastructure.
- Use ACR (https://learn.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest) for container image private registry managers
- Use AKS (https://azure.microsoft.com/en-us/products/kubernetes-service/) for hosting Kuberntes.
## AWS Architecture solution

This solution is created in location "eastus":
- ACR as docker images repository.
- AKS for orchestration docker images.
## Implement solution
## Prepare application for AKS
1. Cloning this repository in local machine: https://github.com/Azure-Samples/azure-voting-app-redis.git
## Create container images
2. Enter de folder zure-voting-app-redis, run docker-compose up -d
3. test application locally http://localhost:8080/
## Create container registry ACR
4. For this case you can use az cli or terraform, its necesary first create a resource group
```shell
az group create --name squad-infra --location eastus
```
5. Create an acr instance
```shell
az acr create --resource-group squad-infra --name voteapp01 --sku Basic
```
6. Login in to container registry
```shell
az acr login --name voteapp01
```
7. tag and push container image 
```shell
docker tag mcr.microsoft.com/azuredocs/azure-vote-front:v1 voteapp01/azure-vote-front:v1
```
```shell
docker push voteapp01/azure-vote-front:v1 
```
## Azure Kubernetes Service cluster AKS
8. Create a kubernetes cluster, this cluster use teh acr voteaoo01
```shell
az aks create -g squad-infra -n myAKSCluster --enable-managed-identity --node-count 1 --enable-addons monitoring --enable-msi-auth-for-monitoring  --generate-ssh-keys --attach-acr voteapp01
```
9. Connect to aks cluster 
```shell
az aks get-credentials --resource-group squad-infra  --name myAKSCluster
```
For comprobate the connection you can use 
```shell
kubectl get nodes
```
## Run application
10. Create deployment manifest, ooen the file azure-vote.yaml and add the following code section of YAML.
11. Apply a deployment file 
```shell
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azure-vote-back
        image: voteapp01.azurecr.io/back:v1
        env:
        - name: ALLOW_EMPTY_PASSWORD
          value: "yes"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 6379
          name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azure-vote-front
        image: voteapp01.azurecr.io/front:v1
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 80
        env:
        - name: REDIS
          value: "azure-vote-back"
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front

```
9. Deploy the application
```shell
kubectl apply -f azure-vote.yaml
```
## Test the application
10. To monitor progress, use the kubectl get service command with the --watch argument.
```shell
kubectl get service azure-vote-front --watch
```
11. Initially the EXTERNAL-IP for the azure-vote-front service shows as pending. When the EXTERNAL-IP address changes from pending to an actual public IP address, use CTRL-C to stop the kubectl watch process. The following example output shows a valid public IP address assigned to the service:
<img width="632" alt="image" src="https://user-images.githubusercontent.com/116659371/225756173-abe33860-4110-42cc-af3a-7221d30ff948.png">
12. To see the application in action, open a web browser to the external IP address of your service.
![image](https://user-images.githubusercontent.com/116659371/225756487-f25dc962-8dfb-4ff0-acd1-d13066962e16.png)

12. To see the application in action, open a web browser to the external IP address of your service.
