# Publish / Release Checklist

Use this checklist when preparing a new release.

## 1) Bump the version

Update the `version:` in `pubspec.yaml` (SemVer: `major.minor.patch`).

## 2) Run checks

Run the project checks from the repo root:

```bash
tool/check.sh
```

Notes:
- `tool/check.sh` requires a real Firebase config at `lib/models/app/firebase_options.dart`.
- If you switch Firebase projects, rerun:

```bash
flutterfire configure --out=lib/models/app/firebase_options.dart
```

## 3) Update CHANGELOG

Update `CHANGELOG.md` with a new section for the version and list all notable changes since the previous release.

## 4) Commit

Stage the release changes and commit with the version number:

```bash
git add pubspec.yaml CHANGELOG.md PUBLISH.md
git commit -m "version X.Y.Z"
```

## 5) Push

Push the commit to the remote:

```bash
git push
```
