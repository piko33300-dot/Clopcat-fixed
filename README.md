# Clopcat

This repository is a browser-friendly Flutter rebuild of the original Clopcat editor. The app is prepared to run in a browser and deploy to GitHub Pages.

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

## Build for web

```bash
flutter build web --release
```

## Deploy to GitHub Pages

The workflow in `.github/workflows/deploy_web.yml` builds the app and publishes it to GitHub Pages automatically on pushes to `main`.
