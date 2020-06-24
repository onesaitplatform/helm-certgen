## Plugin for self signed certificates generation

### Installation

```
> helm plugin install https://cicd.onesaitplatform.com/gitlab/onesait-platform/helm-certgen.git
```

### Uninstall

```
> helm plugin uninstall certgen
```

### List plugins

```
> helm plugin list
```

### Usage

- If Only you want to create self signed certificates

```
> helm certgen
```

- Or generate cert at the same time you install Chart on k8s cluster

```
> helm certgen install onesaitplatform/onesait-platform-chart \
               --namespace onesait-platform \
               --generate-name \
               --version 2
```
