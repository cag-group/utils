## Various helpers, tools and utilities for Node.js

### API authorization

Used to implement basic authentication.

```javascript
const {BasicAuthChecker} = require('@cag-group/utils')
const credentials = require('../secrets/api-credentials/basic-auth-checker-credentials.json')
...
const checker = new BasicAuthChecker(credentials)
const username = checker.getValidUser(req)
if (!username) {
  console.log('Missing/invalid auth')
  return res.sendStatus(401)
}
```
Skapa fil `basic-auth-checker-credentials.json` i katalog `secrets/api-credentials` med konton som ska användas för lokala tester:
```
[
  { "name": "u1", "pass": "somepass" },
  { "name": "u1", "pass": "changedpass" },
  { "name": "u2", "pass": "anotherpass" }
]
```

Exemplet ovan finns user "u1" med två gånger med olika passwords. basic-auth-checker stöder
detta och supportar på så vis uppdatering av API-lösenord utan nedtid.

## Skapa api-credentials

Scriptet

```bash
bash basic-auth-checker-credentials-generate.sh
```
genererar en credentials fil på standard output med users som anges i scriptet och slumpade lösenord. Den är användbar första gången.

Scriptet

```bash
bash create-secret-api-credentials.sh
```
använder scriptet ovan för att generera credentials-filen och sedan skapar den en kubernetes secret med denna.

## Uppdatera användarnamn/lösenord för befintlig api-credentials i Kubernetes

1. Hämta existerande fil `basic-auth-checker-credentials.json` från driftens hemligheter och lägg den i rotkatalogen.
2. Generera ett nytt lösenord: `dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 | rev | cut -b 2- | rev | tr -dc _A-Z-a-z-0-9 | head -c15;`
3. Lägg till en ny rad med samma användarnamn och det genererade lösenordet. Användaren ska alltså finnas på två rader både med nya och med gamla lösenordet 
4. Skapa om secret med det nya innehållet:
```bash
namespace=<your-namespace>
kubectl -n ${namespace} delete secret api-credentials
kubectl -n ${namespace} create secret generic api-credentials --from-file=basic-auth-checker-credentials.json
```
Starta om poden för att den ska läsa in den ändrade secreten:
```
kubectl -n ${namespace} delete pod <podname>
```
