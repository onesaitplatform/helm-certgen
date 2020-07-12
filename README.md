## Helm plugin for self signed certificates generation

This plugin allows to generate self signed certificates, additionally generates and deploys Openshift route manifest file including complete certificate chain and private key.


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

### Plugin usage:

- Available flags:
  - domain: proper domain or the wildcard to generate certificate
  - host: name of the dns that is going to use in the Openshift route

```
> helm certgen --domain *.example.com --host onesaitplatform.example.com
```
