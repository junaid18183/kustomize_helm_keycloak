# Install modules
npm i

# Update the keycloak settings in `src/KeycloakLogin.js` file 

```
const Config = {
    url: 'http://localhost:49953/',
    realm: 'enbuild',
    clientId: 'enbuild-ui',
    onLoad: 'login-required'
}
```

# start the app
```
npm start
```