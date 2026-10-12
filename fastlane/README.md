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

## Store API access

For iOS, set `APP_STORE_CONNECT_KEY_PATH`, `APP_STORE_CONNECT_KEY_ID`, and `APP_STORE_CONNECT_ISSUER_ID` to an App Store Connect API key. The equivalent `APP_STORE_CONNECT_API_KEY_*` names also work. For Android, set `GOOGLE_PLAY_JSON_KEY` (or `GOOGLE_PLAY_JSON_KEY_FILE`) to the service account JSON path. Verify access with:

```sh
bundle exec fastlane ios check_store_access
bundle exec fastlane android check_store_access
```

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
