# TL Image Scaler

Transient Labs config for our hosted instance of [weserv/images](https://github.com/weserv/images)
(this fork). Everything here is layered on top of the upstream image by the
"Transient Labs overrides" block in [`docker/Dockerfile`](../docker/Dockerfile):

| Path                          | Installed to                          |
| ----------------------------- | ------------------------------------- |
| `tl/nginx/imagesweserv.conf`  | `/etc/nginx/` (replaces upstream's)   |
| `tl/nginx/url-allowlist.conf` | `/etc/nginx/`                         |
| `tl/public/*`                 | `/var/www/imagesweserv/public/`       |

## Environments

Deployed by Coolify, built from source with `docker/Dockerfile` (build context = repo root).

- **Dev**
  - URL: https://img-dev.transient.xyz
  - Docs: https://img-dev.transient.xyz/docs/quick-reference.html
  - Deployment: https://app.coolify.io/project/ockwg0cwg0884gc4kws8kwwg/dev

- **Prod**
  - URL: https://img.transient.xyz
  - Docs: https://img.transient.xyz/docs/quick-reference.html
  - Deployment: https://app.coolify.io/project/ockwg0cwg0884gc4kws8kwwg/production

Coolify settings: build pack **Dockerfile**, base directory `/`, Dockerfile
location `/docker/Dockerfile`, port 80, health check `/health`. Git submodules
must be enabled, because `public/` is the upstream docs submodule that serves `/docs/`.

## Testing the `?url=` allowlist

The url allowlist (SSRF protection) lives in `tl/nginx/url-allowlist.conf`. Test cases are in
`tl/tests/url-cases.txt`, one per line: `ALLOW <query>` or `DENY <query>`. Run them (also runs in CI on every push/PR):

```
make -C tl test
```

## Building and running locally

```
git submodule update --init
docker build --platform linux/amd64 -t image-scaler -f docker/Dockerfile .
docker run --rm --platform=linux/amd64 -l dev.orbstack.domains=image-scaler.local -it image-scaler
```
Now the app will be accessible at https://image-scaler.local
Note: you might need to disable Rosetta in docker/orbstack settings to run on silicon macs.

## Useful commands to run in the docker container

Delete a nginx cached file based on the URL:
e.g. to clear the filesystem cache for URLs matching CID `bafybeicmunryg5o`

```
rg -a -l -F -0 'bafybeicmunryg5o' /var/cache/nginx/ | xargs -0r rm --
```

## Clearing the Cloudflare cache by IPFS CID

Responses carry a `Cache-Tag` header set to the IPFS CID found in the `?url=` param
(CIDv0 or CIDv1, encoded or unencoded url, path or subdomain gateway).

Purge every cached variant (all widths, formats, etc.) of a CID in the Cloudflare interface or via CLI.

```
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"tags":["bafybeicmunryg5o..."]}'
```
