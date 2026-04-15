# Streamy App

Flutter movie & TV app based on a chapter-by-chapter learning flow, extended with advanced UX interactions.

## Run

```bash
flutter pub get
flutter run -d chrome
```

## Deep Links & Web URLs Report

This project uses `go_router` and supports deep-linkable URLs in web mode.

### Routes used in the project

- `/login`
- `/`
- `/movie/:id`
- `/genre/:name`
- `/favourites`
- `/profile`
- `/watchlist` -> redirects to `/favourites`

### Deep link examples (web)

If your app is running with default hash URL strategy:

- `https://<host>/#/movie/1`
- `https://<host>/#/genre/Drama`
- `https://<host>/#/favourites`
- `https://<host>/#/profile`
- `https://<host>/#/watchlist` (auto-redirect)

### Current deep-link behavior

- If user is not authenticated and opens any route except `/login`, app redirects to `/login`.
- If user is already authenticated and opens `/login`, app redirects to `/`.
- If movie id does not exist, app shows a `Not Found` screen.

## Flutter docs references (official)

- Deep linking: https://docs.flutter.dev/ui/navigation/deep-linking
- Navigation and routing overview: https://docs.flutter.dev/ui/navigation
- URL strategy on web (hash/path): https://docs.flutter.dev/ui/navigation/url-strategies
- Validate deep links in DevTools: https://docs.flutter.dev/tools/devtools/deep-links
- Android app links cookbook: https://docs.flutter.dev/cookbook/navigation/set-up-app-links

## Notes

- Web currently works with default hash strategy (`/#/...`).
- To switch to path URLs, follow Flutter URL strategy docs and configure server rewrites.
