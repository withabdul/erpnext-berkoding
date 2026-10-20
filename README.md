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
```

Compose memakai Traefik sebagai proxy publik lewat network eksternal `traefik-net` (sesuaikan nama network ini kalau setup Traefik kamu beda) dan certresolver `letsencrypt`; Nginx tetap berjalan di service `frontend` untuk asset dan routing internal ERPNext. Service `configurator` jalan sekali di awal untuk menulis host MariaDB/Redis ke `common_site_config.json` sebelum `backend`/`scheduler`/`worker-*` start.

### Setup site pertama kali

Compose ini tidak otomatis membuat site. Setelah `docker compose up -d`, buat site dan install apps-nya:

```sh
docker compose exec backend bench new-site <nama-domain> \
  --db-host mariadb \
  --db-root-username root \
  --mariadb-root-password <MYSQL_ROOT_PASSWORD> \
  --admin-password <password-admin> \
  --mariadb-user-host-login-scope='%'

docker compose exec backend bench --site <nama-domain> install-app erpnext
docker compose exec backend bench --site <nama-domain> install-app crm
docker compose exec backend bench --site <nama-domain> install-app erpnext_indonesia_localization
```

Pastikan `FRAPPE_SITE_NAME_HEADER` di `.env` sama dengan `<nama-domain>` di atas.

Untuk migrasi berikutnya (misal setelah ganti image), pakai:

```sh
bash scripts/migrate.sh <nama-domain>
```

Backup database dan sites sebelum mengganti image production.

Untuk memakai image atau volume berbeda, override `ERP_IMAGE`, `MARIADB_VOLUME`, `SITES_VOLUME`, dan `LOGS_VOLUME` di `.env`.
