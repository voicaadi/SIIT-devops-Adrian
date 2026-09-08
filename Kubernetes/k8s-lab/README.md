# Group 5 - Local Kubernetes Deployment

This folder ports the current Docker Compose application to local Kubernetes while keeping the architecture easy to understand.

## HOW TO RUN 
cd k8s-lab

kubectl apply -f namespace.yaml
kubectl apply -R -f .

## Architecture

```text
Browser
   |
   | http://localhost:30083
   v
Nginx NodePort Service
   |
   v
Nginx Deployment
   |
   v
Backend ClusterIP Service
   |
   +-------------+-------------+
   |             |             |
   v             v             v
Backend Pod   Backend Pod   Backend Pod
   \             |             /
    \            |            /
          MySQL Service
                |
                v
        MySQL StatefulSet
                |
                v
              PVC
```

Nginx is the only service exposed outside the cluster. Flask and MySQL are internal-only services.

## Why port 30083 instead of 8083?

The Docker Compose version maps host port `8083` directly to Nginx.

Kubernetes `NodePort` Services normally use ports in the `30000-32767` range, so this version uses:

```text
NodePort: 30083
```

On a typical local desktop Kubernetes cluster, open:

```text
http://localhost:30083
```

No `kubectl port-forward` is required.

## Files

```text
k8s/
├── namespace.yaml
├── config/
│   ├── configmap.yaml
│   ├── secret.yaml
│   └── mysql-init-configmap.yaml
├── mysql/
│   ├── service.yaml
│   └── statefulset.yaml
├── backend/
│   ├── service.yaml
│   ├── deployment.yaml
│   ├── hpa.yaml
│   └── pdb.yaml
└── nginx/
    ├── configmap.yaml
    ├── deployment.yaml
    └── service.yaml
```

### `k8s/namespace.yaml`

Creates the `group5` namespace. All application resources are placed in this namespace.

### `k8s/config/configmap.yaml`

Stores non-sensitive Flask configuration:

```text
STORAGE=mysql
DB_HOST=mysql
DB_PORT=3306
DB_USER=group5
DB_NAME=group5
```

### `k8s/config/secret.yaml`

Stores the MySQL passwords as a Kubernetes Secret.

For this first lesson, the passwords are intentionally written directly in the manifest so the Kubernetes Secret mechanism is easy to understand.

This is **not** how we will keep secrets in Git later. See the `.env` section below.

### `k8s/config/mysql-init-configmap.yaml`

Stores the SQL that creates the `participants` table.

It is mounted into MySQL at:

```text
/docker-entrypoint-initdb.d
```

The MySQL image executes the initialization SQL only when it initializes a new/empty database data directory.

### `k8s/mysql/service.yaml`

Creates the internal Service named `mysql` on port `3306`.

The backend therefore connects with:

```text
DB_HOST=mysql
```

MySQL is not exposed outside the cluster.

### `k8s/mysql/statefulset.yaml`

Runs one MySQL Pod using a StatefulSet.

It includes:

- persistent storage
- readiness and liveness checks
- CPU and memory requests/limits
- Secret references for passwords
- the initialization SQL ConfigMap

The PVC does **not** specify a StorageClass. Kubernetes therefore uses the cluster's default StorageClass.

### `k8s/backend/service.yaml`

Creates the internal Service named `backend` on port `5000`.

Nginx sends traffic to:

```text
backend:5000
```

Kubernetes handles routing that traffic to the backend Pods.

### `k8s/backend/deployment.yaml`

Runs three Flask Pods.

It includes:

- `replicas: 3`
- ConfigMap values
- database password from the Kubernetes Secret
- readiness probe
- liveness probe
- CPU and memory requests/limits

There is intentionally **no explicit rollout strategy**. Kubernetes Deployments already use `RollingUpdate` by default.

The manifest assumes your Flask application provides:

```text
/health
/ready
```

If your current `app.py` does not contain those routes yet, add them before deploying this version.

### `k8s/backend/hpa.yaml`

Adds Horizontal Pod Autoscaling for the backend:

```text
minimum: 2 Pods
maximum: 5 Pods
target: 50% CPU utilization
```

Apply this only after the basic deployment is working.

CPU-based HPA also requires a working Kubernetes Metrics API.

### `k8s/backend/pdb.yaml`

Adds a PodDisruptionBudget with:

```text
minAvailable: 1
```

This protects the backend from voluntary Kubernetes operations disrupting every backend Pod at once.

### `k8s/nginx/configmap.yaml`

Contains `nginx.conf`.

Nginx proxies requests to:

```text
backend:5000
```

Here, `backend` is a Kubernetes Service rather than a Docker Compose service.

### `k8s/nginx/deployment.yaml`

Runs Nginx inside Kubernetes.

Nginx itself listens on port `80` inside its Pod.

### `k8s/nginx/service.yaml`

Exposes Nginx using a `NodePort` Service:

```text
service port: 80
container target port: 80
node port: 30083
```

This is the external entry point for the local lab.

---

# Prerequisites

Check that Kubernetes is running:

```bash
kubectl cluster-info
kubectl get nodes
```

Check the available StorageClasses:

```bash
kubectl get storageclass
```

For dynamic MySQL storage provisioning, the local cluster should have a default StorageClass.

---

# 1. Build the Flask image

Build the application image:

```bash
docker build -t group5-app:1.0.0 .
```

The Deployment expects:

```text
group5-app:1.0.0
```

Your local Kubernetes runtime must be able to access this image. Exactly how a locally built image is shared with Kubernetes depends on the local Kubernetes runtime/container engine being used.

---

# 2. Create the namespace

```bash
kubectl apply -f k8s/namespace.yaml
```

Verify:

```bash
kubectl get namespace group5
```

---

# 3. Create configuration

```bash
kubectl apply -f k8s/config/configmap.yaml
kubectl apply -f k8s/config/secret.yaml
kubectl apply -f k8s/config/mysql-init-configmap.yaml
```

Verify:

```bash
kubectl get configmap -n group5
kubectl get secret -n group5
```

---

# 4. Deploy MySQL

```bash
kubectl apply -f k8s/mysql/service.yaml
kubectl apply -f k8s/mysql/statefulset.yaml
```

Check the Pod:

```bash
kubectl get pods -n group5
```

Check persistent storage:

```bash
kubectl get pvc -n group5
```

The MySQL Pod should become `Running` and `Ready` before deploying the backend.

---

# 5. Deploy the backend

```bash
kubectl apply -f k8s/backend/service.yaml
kubectl apply -f k8s/backend/deployment.yaml
```

Verify:

```bash
kubectl get deployment backend -n group5
kubectl get pods -n group5 -l app=backend
kubectl get service backend -n group5
```

You should see three backend Pods.

---

# 6. Deploy Nginx

```bash
kubectl apply -f k8s/nginx/configmap.yaml
kubectl apply -f k8s/nginx/deployment.yaml
kubectl apply -f k8s/nginx/service.yaml
```

Verify:

```bash
kubectl get deployment nginx -n group5
kubectl get service nginx -n group5
```

The service should show:

```text
80:30083/TCP
```

---

# 7. Open the application

Use:

```text
http://localhost:30083
```

The request path is:

```text
Browser
   |
   v
NodePort 30083
   |
   v
Nginx Service
   |
   v
Nginx Pod
   |
   v
backend Service
   |
   v
Flask Pod
   |
   v
mysql Service
   |
   v
MySQL Pod
```

If your particular local Kubernetes runtime does not expose NodePort services through `localhost`, obtain the node address with:

```bash
kubectl get nodes -o wide
```

and access:

```text
http://<node-ip>:30083
```

---

# Useful checks

Show the main resources:

```bash
kubectl get all -n group5
```

Show Pods with their node/IP information:

```bash
kubectl get pods -n group5 -o wide
```

Backend logs:

```bash
kubectl logs -n group5 deployment/backend
```

Nginx logs:

```bash
kubectl logs -n group5 deployment/nginx
```

MySQL logs:

```bash
kubectl logs -n group5 mysql-0
```

Describe a failing Pod:

```bash
kubectl describe pod <pod-name> -n group5
```

---

# Test self-healing

List backend Pods:

```bash
kubectl get pods -n group5 -l app=backend
```

Delete one backend Pod:

```bash
kubectl delete pod <backend-pod-name> -n group5
```

Then watch Kubernetes create its replacement:

```bash
kubectl get pods -n group5 -w
```

---

# Add the HPA later

First verify that metrics work:

```bash
kubectl top pods -n group5
```

Then apply:

```bash
kubectl apply -f k8s/backend/hpa.yaml
```

Check:

```bash
kubectl get hpa -n group5
```

Watch scaling:

```bash
kubectl get hpa -n group5 -w
```

In another terminal:

```bash
kubectl get pods -n group5 -w
```

---

# Add the PodDisruptionBudget

```bash
kubectl apply -f k8s/backend/pdb.yaml
```

Check it:

```bash
kubectl get pdb -n group5
```

---

# Next lesson: move passwords to `.env`

The initial `secret.yaml` contains the passwords directly because this makes the first Kubernetes deployment easier to understand.

The next hardening step is to stop storing those values in the Kubernetes YAML.

Create a local file:

```text
.env
```

For example:

```env
DB_PASSWORD=group5password
MYSQL_ROOT_PASSWORD=rootpassword
```

`.gitignore` in this package already contains:

```gitignore
.env
```

Load the values into Bash:

```bash
set -a
source .env
set +a
```

Then create/update the Secret from those variables:

```bash
kubectl create secret generic group5-secret \
  -n group5 \
  --from-literal=DB_PASSWORD="$DB_PASSWORD" \
  --from-literal=MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -
```

After adopting this method, stop applying:

```text
k8s/config/secret.yaml
```

The learning progression is therefore:

```text
First lesson
Secret manifest with visible values
       |
       v
Understand Kubernetes Secret references
       |
       v
Next lesson
.env ignored by Git
       |
       v
Generate Kubernetes Secret at deployment time
       |
       v
Later cloud/production version
External secret manager
```

---

# Delete the environment

```bash
kubectl delete namespace group5
```

This deletes the namespace resources, including the MySQL PVC. Treat this as destructive for the local database.

The fate of the underlying PersistentVolume depends on the StorageClass reclaim policy.
