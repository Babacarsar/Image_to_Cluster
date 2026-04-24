# Image to Cluster — Déploiement Nginx custom avec Packer, Ansible et K3d

## 1. Objectif du projet

Ce projet montre comment construire une image Docker personnalisée avec **Packer**, puis la déployer automatiquement dans un cluster Kubernetes local **K3d** à l’aide de **Ansible**.

L’application déployée est un simple serveur **Nginx** contenant une page `index.html` personnalisée.

---

## 2. Architecture de la solution

Le fonctionnement général est le suivant :

1. travaille dans **GitHub Codespaces**.
2. **Packer** construit une image Docker personnalisée à partir de `nginx:alpine`.
3. L’image générée contient notre fichier `index.html`.
4. L’image est importée dans le cluster **K3d**.
5. **Ansible** déploie l’application dans Kubernetes.
6. Le service est exposé et testé avec `kubectl port-forward`.

---

## 3. Technologies utilisées

- **GitHub Codespaces** : environnement de développement cloud.
- **Docker** : création et gestion des images.
- **Packer** : automatisation de la construction de l’image Docker.
- **K3d** : cluster Kubernetes local basé sur K3s dans Docker.
- **Kubernetes** : orchestration des conteneurs.
- **Ansible** : automatisation du déploiement Kubernetes.
- **Nginx** : serveur web utilisé pour afficher la page HTML.

---

## 4. Structure du projet

```bash
.
├── index.html
├── nginx.pkr.hcl
├── deploy-nginx.yml
├── README.md
└── Architecture_cible.png


---

## 5. Guide d'exécution - Ligne de commande

### 5.1 Initialisation et configuration

**Étape 1 : Initialiser Packer**
```bash
packer init .
```
Cela télécharge les plugins nécessaires (ici le plugin Docker) définis dans `nginx.pkr.hcl`.

**Étape 2 : Construire l'image Docker personnalisée**
```bash
packer build nginx.pkr.hcl
```
Cette commande :
- Récupère l'image `nginx:alpine`
- Copie `index.html` dans le conteneur
- Génère une nouvelle image Docker nommée `nginx-custom:1.0`

**Étape 3 : Vérifier la création de l'image**
```bash
docker images | grep nginx-custom
```
Vous devriez voir : `nginx-custom    1.0    <IMAGE_ID>    <SIZE>`

---

### 5.2 Configuration du cluster K3d

**Étape 4 : Créer un cluster K3d** (si nécessaire)
```bash
k3d cluster create lab
```
Crée un cluster Kubernetes local nommé "lab" basé sur K3s.

**Étape 5 : Importer l'image Docker dans le cluster K3d**
```bash
k3d image import nginx-custom:1.0 -c lab
```
Rend l'image Docker disponible pour le cluster K3d sans la pousser vers un registre.

**Étape 6 : Vérifier la connexion au cluster**
```bash
kubectl cluster-info
kubectl get nodes
```
Confirme que vous êtes connecté au cluster K3d correct.

---

### 5.3 Déploiement avec Ansible

**Étape 7 : Déployer l'application Nginx**
```bash
ansible-playbook deploy-nginx.yml
```
Cette commande crée :
- Un **Deployment** avec 2 replicas du pod Nginx
- Un **Service** de type NodePort pour exposer l'application

**Étape 8 : Vérifier le déploiement**
```bash
kubectl get pods
kubectl get svc
kubectl get deployment
```
Vous devriez voir :
- 2 pods `web-*` en état `Running`
- 1 service `web` de type `NodePort`

---

### 5.4 Tests et accès à l'application

**Étape 9 : Exposer le service localement**
```bash
kubectl port-forward svc/web 8080:80
```
Crée un tunnel pour accéder au service Nginx local via `http://localhost:8080`

**Étape 10 : Tester l'application** (dans un autre terminal)
```bash
curl http://localhost:8080
```
Affiche le contenu de votre `index.html`.

**Alternative - Accès via le port NodePort direct :**
```bash
kubectl get svc web
# Prendre le port assigné (ex: 31234)
curl http://localhost:31234
```

---

## 6. Commandes de nettoyage (optionnel)

**Supprimer le déploiement :**
```bash
kubectl delete deployment web
kubectl delete svc web
```

**Arrêter le cluster K3d :**
```bash
k3d cluster stop lab
```

**Supprimer complètement le cluster :**
```bash
k3d cluster delete lab
```

**Supprimer l'image Docker :**
```bash
docker rmi nginx-custom:1.0
```

---

## 7. Résumé des commandes complètes (ordre d'exécution)

```bash
# Étapes de construction
packer init .
packer build nginx.pkr.hcl
docker images | grep nginx-custom

# Configuration du cluster
k3d cluster create lab
k3d image import nginx-custom:1.0 -c lab

# Déploiement
ansible-playbook deploy-nginx.yml

# Vérification
kubectl get pods
kubectl get svc
kubectl get nodes

# Tests