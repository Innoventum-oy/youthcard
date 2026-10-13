# Youth Card store information pages

These Markdown files are the repository copy of the public pages on `youthcard.eu`. All twelve URLs below were opened and checked for their matching language and page content on 12 October 2026.

The app interface and staged store listing copy cover English, Finnish, and Swedish. Google Play has listing changes for all three languages in review. App Store Connect has an editable iOS 2.0.0 version with all three listings saved.

| Page | English | Finnish | Swedish | Store use |
| --- | --- | --- | --- | --- |
| Privacy policy | [en](en/privacy-policy.md) | [fi](fi/privacy-policy.md) | [sv](sv/privacy-policy.md) | Required public Privacy Policy URL for both stores. |
| Account deletion | [en](en/account-deletion.md) | [fi](fi/account-deletion.md) | [sv](sv/account-deletion.md) | Required external deletion resource and Data safety URL for Google Play; suitable for Apple's optional Privacy Choices URL. |
| Support | [en](en/support.md) | [fi](fi/support.md) | [sv](sv/support.md) | Apple Support URL must lead to real contact details. Use the same page for Google Play website/help links. |
| About the app | [en](en/about.md) | [fi](fi/about.md) | [sv](sv/about.md) | Apple Marketing URL and Google Play website link; optional as a dedicated page. |

| Page | Finnish URL | English URL | Swedish URL |
| --- | --- | --- | --- |
| Privacy policy | `https://youthcard.eu/fi/privacy-policy` | `https://youthcard.eu/en/privacy-policy` | `https://youthcard.eu/sv/privacy-policy` |
| Account deletion | `https://youthcard.eu/fi/account-deletion` | `https://youthcard.eu/en/account-deletion` | `https://youthcard.eu/sv/account-deletion` |
| Support | `https://youthcard.eu/fi/support` | `https://youthcard.eu/en/support` | `https://youthcard.eu/sv/support` |
| About | `https://youthcard.eu/fi/about` | `https://youthcard.eu/en/about` | `https://youthcard.eu/sv/about` |

The staged App Store metadata maps privacy, support, and marketing to the matching page for each language. Google Play's Data safety account deletion field uses the English account deletion URL; the page itself links to the corresponding localized content. Apple's Privacy Choices field uses the matching account deletion URL.

The stores also need listing text, screenshots, an icon, and form answers. Those are store fields/assets, not public information pages. A separate terms of service page is not required by either store for the currently known app features; add one if the service has actual terms to publish.

## Store declaration follow-up

- Keep the live privacy-policy pages aligned with the repository copy: a participating municipality can access the full profile of users in its activities. The current live wording is less explicit.
- Recheck the app's Data safety and App Privacy forms if data collection changes, especially location, profile images, form attachments, feedback, and activity visits.
- Confirm that `info@youthcard.eu` processes account deletion requests from outside the app and verifies account ownership. The live pages describe this path, and Google requires that it works without reinstalling the app.
- Review the small-group re-identification risk of visit statistics containing age and gender before calling them anonymous. These drafts deliberately do not use that claim.

Current official guidance: [Apple privacy policy and choices URLs](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information), [Apple Support and Marketing URLs](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/), [Google account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en), and [Google Health apps declaration](https://support.google.com/googleplay/android-developer/answer/14738291?hl=en). The app has no health or fitness features, so the Play Console Health apps answer is “My app doesn’t provide any health features.” This is a form answer, not a public information page.
