## Helm plugin for self signed certificates generation

This plugin allows to generate self signed certificates, additionally generates and deploys Openshift route manifest file including complete certificate chain and private key.

Requirements:

- Helm v3 installed
- oc cli installed
- OpenSSL installed

### Plugin installation

```
> helm plugin install https://github.com/onesaitplatform/helm-certgen.git
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

Once the plugin execution is finished, it generates two folders in the same directory that the plugin had been executed:

- ssl: it includes all the files necessary to generate self signed certificates (CA, server certificate, private key...)
- route-template: it includes **Route.yml** Openshift manifest file that had been deployed to an existing cluster

```
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: loadbalancer-route
spec:
  host: testing.apps.private-cluster.es
  path: /
  to:
    kind: Service
    name: loadbalancer
  port:
    targetPort: http
  tls:
    termination: edge
    key: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEp...
    certificate: |
      -----BEGIN CERTIFICATE-----
      MIIDf...

```
