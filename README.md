## Various helpers, tools and utilities for Node.js

### API authorization

Use in a server application to implement basic authentication in it's REST API.

The class `BasicAuthChecker` is used in code the do authorization. Credentials are read from the local directory
 `secrets` which when running locally contains uncommitted credentials for development,
 and in Kubernetes a ecret containing the credentials are mounted at `secrets` so the application always reach it by:
```javascript
const credentials = require('../secrets/api-credentials/api-credentials.json')
``` 
disregarding if running on a local laptop, in cloud stage or cloud prod.

Use in code like this:
```javascript
const {BasicAuthChecker} = require('@cag-group/utils')
const credentials = require('../secrets/api-credentials/api-credentials.json')
...
const checker = new BasicAuthChecker(credentials)
const username = checker.getValidUser(req)
if (!username) {
  console.log('Missing/invalid auth')
  return res.sendStatus(401)
}
```
Create file `api-credentials.json` in the folder `secrets/api-credentials` with accounts for local tests:
```
[
  { "name": "u1", "pass": "somepass" },
  { "name": "u1", "pass": "changedpass" },
  { "name": "u2", "pass": "anotherpass" }
]
```
do not commit files in `/secrets`, these are for local tests.

In the example above user "u1" is present twice with different passwords. basic-auth-checker supports
this in order to support change of API-passwords without downtime.

## Create api-credentials secret

Create a local file `api-credentials.json` in the root directory with the intended users and generated passwords (see command below).

Create the secret:

```bash
kubectl -n your-namespace create secret generic api-credentials --from-file=api-credentials.json
```

## Use api-credentials secret in Kubernetes

1. Define a volume in server.yaml on the same level as `containers:`:
```yaml
      volumes:
        - name: api-credentials
          secret:
            secretName: api-credentials

```
2. Mount the secret volume in the server container
```yaml
        volumeMounts:
        - name: api-credentials
          mountPath: /server/secrets/api-credentials/
          readOnly: true
```

## Update existing usernames/passwords in existing kubernetes secret

1. Get existing credentials `api-credentials.json` from your secrets vault and save it in the root folder.
2. Generate a new password, for example with: `dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 | rev | cut -b 2- | rev | tr -dc _A-Z-a-z-0-9 | head -c15;`
3. Edit the file and add a new row with same username and the generated password 
4. Create a new secret with the updated content:
```bash
kubectl -n your-namespace delete secret api-credentials
kubectl -n your-namespace create secret generic api-credentials --from-file=api-credentials.json
```
Restart the pod in order for it to read the changed secret:
```
kubectl -n your-namespace delete pod <podname>
```
5. Save the new credentials in the secrets vault and delete the local file
