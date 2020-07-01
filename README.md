## Plugin for self signed certificates generation

### Plugin installation

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

### Plugin usage

- If you only want to create self signed certificates

```
> helm certgen *.example.com
```

- Or generate cert at the same time you install Chart on k8s cluster

```
> helm certgen *.example.com install onesaitplatform/onesait-platform-chart \
               --namespace onesait-platform \
               --generate-name \
               --version 2
```

- Also you can deploy Route on Openshift

```
> helm certgen *.example.com --route-deploy install onesaitplatform/onesait-platform-chart \
               --namespace onesait-platform \
               --generate-name \
               --version 2
```
