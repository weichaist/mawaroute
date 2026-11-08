# Contributing to MaWaRoute

Thanks for your interest. Issues and pull requests are welcome.

## Before you open a pull request

- Keep each pull request to one change, and say what it changes and why.
- Run the same checks CI runs (`.github/workflows/ci.yml`) for the parts you touched:

```sh
# Apps (Flutter 3.47.9, see each app's .fvmrc)
cd apps/<visitor|shop|business|qr-chat> && flutter analyze && flutter test
# The two web apps must also build
flutter build web --release --dart-define-from-file=config/example.json

# Cloud Functions (Node.js 22)
cd functions && npm ci && npm run lint && npm test
```

- Never commit real configuration: API keys, `config/<name>.json` files other
  than `config/example.json`, `.env` files, `google-services.json`,
  `GoogleService-Info.plist`, signing keys or service-account files. The
  `.gitignore` covers these; double-check `git status` before you commit.
- Describe new configuration values in the README of the part that uses them,
  and add a placeholder to the example config.

## Reporting a security problem

Please don't open a public issue for a vulnerability. Use GitHub's
"Report a vulnerability" button on the repository's Security tab instead.

## License

By contributing, you agree that your contributions are licensed under the
[MIT License](LICENSE).
