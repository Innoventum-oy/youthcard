# Youth Card store releases

Run lanes from the repository root after `bundle install`. Keep signing material and store API keys outside Git.

## Screenshots

Use a demo account with display data suitable for the stores. The default `screenshots` lanes guide you through these seven views in order: landing, login, dashboard, Events / Discover, sample event detail, calendar, and own card. Wait for network content to load before each capture.

```sh
bundle exec fastlane ios prepare_screenshots
bundle exec fastlane ios screenshots locale:fi device_label:iPhone_6_5
bundle exec fastlane ios validate_screenshots locale:fi

bundle exec fastlane android prepare_screenshots
bundle exec fastlane android screenshots locale:fi-FI
bundle exec fastlane android validate_screenshots locale:fi-FI
```

The iOS preparation lane builds a simulator app with the debug server selector hidden. Boot the simulator first. The Android preparation lane builds and installs a release APK on an attached device or emulator. If the APK is already built, use `prepare_screenshots skip_build:true`. Set `ANDROID_SERIAL` when more than one Android device is connected.

Capture a single visible screen with `ios screenshot name:05_event_detail locale:fi` or the corresponding `android screenshot` lane. The iOS images are in `fastlane/screenshots/<locale>/`; Android images are in `fastlane/metadata/android/<locale>/images/phoneScreenshots/`.

Review the images, account details, localization, and store device requirements before invoking `upload_screenshots`. These lanes only stage screenshots; the binary release lanes skip screenshot and metadata uploads.

### iOS store screenshots

`ios capture_store_screenshots` drives the production demo account through the dashboard, Discover, an event detail, and My Card in English (`en-GB`), Finnish (`fi`), and Swedish (`sv`). It captures the full simulator display, including the status bar. Use an iPhone 15 Pro (1179 × 2556) and iPad Pro 13-inch (M5) (2064 × 2752). The iPad simulator's system language is set to match each listing language.

Put `SCREENSHOT_DEMO_EMAIL` and `SCREENSHOT_DEMO_PASSWORD` in a private JSON file outside Git, then run:

```sh
SCREENSHOT_DEFINES_FILE=/absolute/path/to/private-demo-defines.json bundle exec fastlane ios capture_store_screenshots
bundle exec fastlane ios prepare_store_screenshots
APP_STORE_CONNECT_ENV_FILE=/absolute/path/to/shared/fastlane/.env bundle exec fastlane ios upload_store_screenshots
APP_STORE_CONNECT_ENV_FILE=/absolute/path/to/shared/fastlane/.env bundle exec fastlane ios verify_store_screenshots
```

Pass `target:iphone_61` or `target:ipad_13` and `locale:en-GB`, `locale:fi`, or `locale:sv` to capture a subset. Pass `device:<simulator-UDID>` if the default simulator name is unavailable. Raw images are under `build/fastlane/raw/ios/`; the preparation lane checks every image and writes 24 opaque PNGs under `build/fastlane/screenshots/ios_current/`. The upload lane repeats validation and targets the editable iOS version from `pubspec.yaml` without uploading a binary, metadata, or submitting for review. `APP_STORE_CONNECT_ENV_FILE` can point at the existing EmpowerHer Fastlane `.env`; no key is copied into this repository.

## Store API access

For iOS, set `APP_STORE_CONNECT_KEY_PATH`, `APP_STORE_CONNECT_KEY_ID`, and `APP_STORE_CONNECT_ISSUER_ID` to an App Store Connect API key. The equivalent `APP_STORE_CONNECT_API_KEY_*` names also work. For Android, set `GOOGLE_PLAY_JSON_KEY` (or `GOOGLE_PLAY_JSON_KEY_FILE`) to the service account JSON path. Verify access with:

```sh
bundle exec fastlane ios check_store_access
bundle exec fastlane android check_store_access
```

The ignored `fastlane/.env` on this machine points to the authorised shared Google Play service account. It contains only a local key-file path; never add the JSON key or `.env` to Git.

## Store listing data

Download a fresh, separate copy of each store's current text and marketing images before editing them:

```sh
bundle exec fastlane android download_store_listing
bundle exec fastlane ios download_store_listing
```

These lanes write to `store_snapshot/<date>/<store>/fastlane/` and refuse to overwrite an existing snapshot. Pass `path:/absolute/new/directory` for another download on the same day. The iOS download deliberately excludes App Review contact details, demo credentials, and notes. Google Play downloads only images actually assigned to each locale; other locales inherit images from the default `en-GB` listing.

Put reviewed Google Play text in `fastlane/metadata/android/<locale>/*.txt`, its icon and feature graphic in `images/icon.png` and `images/featureGraphic.png`, and phone images in `images/phoneScreenshots/`. Put reviewed App Store text in `fastlane/metadata/ios/<locale>/*.txt` and screenshots in `fastlane/screenshots/<locale>/`. Then run:

```sh
bundle exec fastlane android upload_store_listing
bundle exec fastlane ios upload_store_listing
```

`android upload_store_icon` uploads only the reviewed 512×512 Google Play icon in `fastlane/metadata/android/en-GB/images/icon.png`. The iOS store icon is carried by the iOS binary.

The staged metadata covers English, Finnish, and Swedish. The translated privacy, support, marketing, and deletion URLs were live and verified in all three languages on 12 October 2026. The repository copy and URL mapping are in `docs/store-pages/README.md`. App Store Connect has an editable iOS 2.0.1 version with the three localized listings and privacy URLs saved. The shared EmpowerHer App Store Connect key was verified to access Youth Card on 13 October 2026. The 24 new iPhone and iPad screenshots were uploaded and verified in all six localization/device slots. The signed iOS 2.0.1 (42) binary was uploaded, processed as valid, made available to the internal TestFlight group, and selected for the editable App Store listing on 13 October 2026. The listing has not been submitted for App Store review.

Google Play rejected production version 2.0.0 (41) with a generic loading issue. The old review instructions told reviewers to select a Development server that the production app does not offer. Version 2.0.1 (42) adds a login timeout and restores the login form after network failure. A production demo account was verified on the signed release build and saved in Play Console's Sign-in details, replacing the obsolete server and validation-code instructions. Version 42 is available on the internal track and its production release, updated icon, English/Finnish/Swedish listing copy, new screenshots, privacy URL, account-deletion Data safety declaration, and no-health-features answer were sent for review on 12 October 2026. The live policy says residual visit statistics have no fixed expiry. Play Console's Data safety form also declares full profile sharing with participating municipalities; keep the public privacy-policy pages aligned with this detail.

## Testing releases

Increment the version and build number in `pubspec.yaml` before building. The iOS lane uploads a signed IPA to TestFlight without submitting for App Store review. On a machine without the existing signing profile, set `IOS_SETUP_SIGNING=1` to let Fastlane fetch the distribution certificate and create a provisioning profile under the ignored `build/` directory.

```sh
IOS_SETUP_SIGNING=1 bundle exec fastlane ios build_candidate
bundle exec fastlane ios beta skip_build:true
bundle exec fastlane ios testflight_status
bundle exec fastlane ios distribute_internal
```

`bundle exec fastlane ios beta` builds and uploads in one run when signing is already configured. The status lane shows processing state and internal group access for the current `pubspec.yaml` version. Run the distribution lane after upload; it completes exempt encryption declaration for an uploaded build when needed and checks that the internal group has access. Apple's exempt encryption flag is also set in `ios/Runner/Info.plist` for future builds.

The Android lane builds a signed App Bundle and publishes it to the Google Play internal testing track as a completed release:

```sh
bundle exec fastlane android internal
```

Use `android internal skip_build:true` only after confirming that `build/app/outputs/bundle/release/app-release.aab` matches the current source. Google Play policy declarations must be complete before the API can commit a release.

The current local Android candidate is `2.0.1+42`. Its signed bundle is `build/app/outputs/bundle/release/app-release.aab` with SHA-256 `126071cee1ac17baa63145740b89777632471dca81044dd6f0f97777f2a2df12`.
