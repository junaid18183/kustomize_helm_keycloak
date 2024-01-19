# Keycloak

This repository deploys the keycloak with demo realm in the `keycloak` namespace. 

The `admin` password is set already to `admin` and there is a sample user named `juned@ijuned.com` with Password `junedm` is added to the demo realm.

The `demo` realm, has configured with a client authenticator.

```
CLIENT_SECRET: "rzap7hjeepSxiXsmEXqQNaY9uwvPqOb1"
COOKIE_SECRET: "d3c1VGxTZmtwQzBURUFMZklVMXZUakZ2"
```

The installation also uses custom theme. See [theme.css](theme.css)

# How to deploy

```
kustomize  build . --enable-helm  | kubectl apply -f -
```


# How to acces the UI

Since the keycloak is deployed as ClusterIP, you can use port-forward to access the UI

```
kubectl port-forward svc/keycloak-keycloakx-http -n keycloak 30080:80
```

# Sample Client UI

http://localhost:30080/auth/realms/demo/account/#/security/signingin
