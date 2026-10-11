# Youth Card release assistance

Run lanes from the repository root with `bundle exec fastlane ...` after `bundle install`.

## Screenshots

Build and run the app in an iOS simulator or Android emulator, then sign in with a suitable test account. The guided lanes pause before each screen so you can navigate and wait for content:

```sh
bundle exec fastlane ios screenshots locale:en-US
bundle exec fastlane android screenshots locale:en-US
```

Pass `names:01_dashboard,02_card` to change the list. For a single capture of the visible screen:

```sh
bundle exec fastlane ios screenshot name:01_dashboard locale:en-US
bundle exec fastlane android screenshot name:01_dashboard locale:en-US
```

Repeat with `02_card`, `03_discover`, `04_calendar`, and other screens. iOS captures go to `fastlane/screenshots/<locale>/`; Android captures go to the Play metadata layout under `fastlane/metadata/android/<locale>/images/phoneScreenshots/`. Set `ANDROID_SERIAL` if multiple Android devices are connected. Capture each device size and locale required by the stores. Review images before uploading them.

`validate_screenshots` checks that files exist and are nonempty. `upload_screenshots` uploads reviewed images only after you invoke it with store credentials.

## Candidate builds

```sh
bundle exec fastlane ios build_candidate
bundle exec fastlane android build_candidate
```

The iOS lane uses the signing setup in Xcode. The Android lane uses `android/key.properties` if available. Neither lane uploads a build.

## Store staging

Set `APP_STORE_CONNECT_KEY_PATH` (a `.p8` file), `APP_STORE_CONNECT_KEY_ID`, and, for team keys, `APP_STORE_CONNECT_ISSUER_ID` before `bundle exec fastlane ios beta`. It uploads to TestFlight without submitting for App Store review.

Set `GOOGLE_PLAY_JSON_KEY` (a service account JSON file) before `bundle exec fastlane android internal`. It uploads a draft to the Play internal track. Credentials and signing files must stay outside Git.

Store screenshots should be reviewed against the final app build, localization, and account data before staging.
