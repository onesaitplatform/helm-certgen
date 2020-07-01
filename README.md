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

- If you only want to create self signed certificates and OCP Route manifest

```
> helm certgen --domain *.example.com --host onesaitplatform.example.com
```
