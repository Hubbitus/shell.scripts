# Proxy grabs and check

Simple solution to grab proxy lists from varouse places and then check its liveness.

For the lists handled you may look into directory [getters]().

## Entrypoint

Simple start:

```bash
mkdir proxies && cd proxies
{path}/proxy.GET-AND-CHECK
```

## Requirements:

- Python >= 3.11
- wget
- curl
- parallel
- dos2unix
- moreutils

