# ERPNext Berkoding

Konfigurasi build image ERPNext untuk environment Berkoding.

Apps yang ikut dibuild:

- ERPNext, branch `version-16`
- CRM, branch `main`
- Indonesia Localization, branch `develop`

## Build image

GitHub Actions di `.github/workflows/build-image.yml` akan:

- build image Linux `amd64` dari `docker/Containerfile`;
- membaca daftar apps dari `apps.json`;
- publish image ke `ghcr.io/withabdul/erpnext-berkoding`;
- memberi tag `latest` dan tag commit `sha-*`.

Workflow berjalan saat ada push ke `main`, manual, dan mingguan.

## Deploy

Salin konfigurasi environment terlebih dahulu:

```sh
cp .env.example .env
```

Isi domain dan password di `.env`. Untuk VPS production saat ini, pertahankan tiga nama volume default yang sudah ada.

Login ke GHCR menggunakan token yang memiliki akses `read:packages`, lalu jalankan:

```sh
docker compose pull
docker compose up -d
bash scripts/migrate.sh site.localhost
```

Backup database dan sites sebelum mengganti image production. Compose memakai Traefik sebagai proxy publik; Nginx tetap berjalan di service `frontend` untuk asset dan routing internal ERPNext.

Untuk memakai image atau volume berbeda, override `ERP_IMAGE`, `MARIADB_VOLUME`, `SITES_VOLUME`, dan `LOGS_VOLUME` di `.env`.
