# Store listing snapshot — 12 October 2026

This is a copy of the current published marketing material, saved before the Youth Card 2.0 rebrand. It is reference material, not an upload source. No App Store review notes or credentials are included.

## Google Play

- App: `eu.youthcard.youth_card`
- Current listing text: `google_play/fastlane/{en-GB,fi-FI,cs-CZ,de-DE,hr,pt-PT}/`
- Original store icon, feature graphic, and five phone screenshots: `google_play/fastlane/en-GB/images/`
- `google_play/images/` contains a second copy of the same original images with simple numbered names.
- The non-English listings except Finnish currently reuse English text. The other locales inherit the English images.
- The English full description still links to regional sites, including `nuortenjoensuu.fi`. The Finnish full description refers to Nuortenjoensuu and Nuortenliperi.
- The last completed internal release before 2.0 was version code 25, version 1.1.7. Production is version code 37, version 1.1.19. No internal release notes were available to download.
- `google_play/data_safety_export.csv` is Play Console's export of the existing Data safety answers. Its account deletion URL and related new answers are blank.
- Play Store contact settings currently show `info@youthcard.eu` and `https://youthcard.eu`.

## App Store

- App: `eu.youthcard.youthCard`, Apple ID `1603097889`
- Current live version: `1.1.19`, build `37`
- Current listing text: `app_store/metadata/{fi,en-GB}/`
- Current Finnish screenshots: `app_store/images/fi/` (five 1242×2688 iPhone, five 1242×2208 iPhone, two 2048×2732 iPad)
- English (U.K.) uses the existing Finnish iPhone assets; no separate English iPad assets were visible in Media Manager.
- The Finnish Support URL is `https://www.nuortenjoensuu.fi` and Marketing URL is `https://www.nuortenjoensuu.fi/app`. Both should move to `https://youthcard.eu` for the rebrand.
- The English Support and Marketing URLs already point to `https://www.youthcard.eu`.
- The English (U.K.) App Store name is still `Youthcard.eu`; the staged rebrand changes it to `Youth Card`.
- The App Store icon is supplied by the uploaded iOS binary. The 2.0 source build uses the new icon, but the current live version still shows the old one.

## Release attempt

The signed Android 2.0.0 (40) bundle was built locally. Fastlane reached Google Play's final edit commit, where Google rejected the release because the app has no current Data safety declaration. The attempted edit did not appear in Latest app bundles or Publishing overview afterward. Play Console also marks the Health apps declaration overdue. The public `https://youthcard.eu/en/home/deleting-account/` page currently contains a heading but no deletion instructions, so it cannot yet be used as the required account deletion URL.

The screenshots and feature graphic show the previous design. Review new copy and image sets before publishing the store listing changes.
