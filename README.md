# Azure Infrastructure Tools

Azure Infrastructure Tools (terraform, az cli, az devops cli, etc) 

> Client en ligne de commande pour Azure / Azure DevOps

## Préparation (manuelle)

```bash
# Tagguer l'image
docker build -t ghcr.io/laveracloudsolutions/azure-infrastructure-tools:latest .
docker push ghcr.io/laveracloudsolutions/azure-infrastructure-tools:latest
```

## Utilisation (Exemple)

```bash
# Créer un PAT Azure DevOps > https://dev.azure.com/petrolavera/_usersSettings/tokens
export AZURE_DEVOPS_EXT_PAT="xxxxxxxxxxxxxxxxxxxxxxxx"

# Lancer une commande de type "az devops"
docker run --rm -e AZURE_DEVOPS_EXT_PAT "ghcr.io/laveracloudsolutions/azure-infrastructure-tools:latest" //bin/bash -c "az devops --help"

```

## Docker Image | GHCR.IO | Github Action
___
> [Voir Wiki](https://dev.azure.com/petrolavera/ArchitectureApplicative/_wiki/wikis/Architecture%20applicative/340/Images-Docker-(-GitHub))
___