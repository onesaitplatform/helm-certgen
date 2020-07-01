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

```
> helm certgen --domain *.example.com --host onesaitplatform.example.com
```
