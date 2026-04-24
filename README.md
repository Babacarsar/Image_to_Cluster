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


## Vérification

```bash
packer build nginx.pkr.hcl
docker images | grep nginx-custom
k3d image import nginx-custom:1.0 -c lab
ansible-playbook deploy-nginx.yml
kubectl get pods
kubectl get svc
kubectl port-forward svc/web 8080:80
curl http://localhost:8080