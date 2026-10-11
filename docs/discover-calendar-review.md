# Discover and Calendar review

Date: 2026-10-11

## What the live app shows

- Discover previously requested the category list, then made another event request for every category that entered the viewport. The landing view now makes one paged request each for activities and places. Category events load only when a category is opened from the secondary browser.
- The [Figma Discover view](https://www.figma.com/design/Qc215zClE0kqncDGYxF84I) presents a mixed image-led feed with All, Activities, and Places filters. The app now follows this layout in light and dark modes.
- Calendar's 1,000-item full-field request failed after a long wait in the iOS simulator. A 250-item request with the five fields used by the view loaded event markers and thumbnails successfully. Calendar now pages those requests, showing the first page while later pages load.

## Discover direction

1. The landing view now has **All**, **Activities**, and **Places** filters. Upcoming activities and active places each use a paged request with the existing 30-minute request cache. Event and place cards show API images, with a themed icon when no cover exists.
2. Categories open from a secondary action. A category's events load only after it is opened, avoiding a request for every visible category.
3. The feed fetches the next page near the end, deduplicates by activity ID, and keeps visible results during refresh or a network error. A manual refresh action remains available.
4. Make search server backed once the iCMS filter contract is confirmed. A client-only filter over the first page would falsely imply that it searches all available activities and places.
5. Keep location permission optional. Places can initially sort by name; sort by distance only after the user grants location access.

The feed and secondary category route are implemented. `ActivityListProvider` caches each feed page by its sorted parameters for 30 minutes. Search currently filters only the loaded pages, and the UI states that limitation. The remaining API task is to confirm a server-side search parameter and make searching comprehensive across all pages.

## Calendar choice

Keep `table_calendar` for the current month-and-upcoming-events layout. The resolved version is 3.3.0; its API supports locale, event loading, month/week formats, and custom builders. The dependency constraint now names 3.3.0 explicitly. The calendar's Finnish weekday labels now use the active app locale.

[`calendar_view`](https://pub.dev/packages/calendar_view) is a stronger choice if the product needs day and week scheduling views, but its 2.x series warns that releases may contain breaking changes. [`flutter_calendar_carousel`](https://pub.dev/packages/flutter_calendar_carousel) offers a newer controlled month/week widget, but replacing the working month view would not resolve the data-loading issue. [`table_calendar`](https://pub.dev/packages/table_calendar) already provides the UI hooks needed for the Figma view.

The calendar currently requests up to eight 250-item pages in date order, stopping after the first page that extends beyond its navigation window. The `ActivityListProvider` caches each page for 30 minutes, so reopening Calendar can reuse the results. This is an interim guard rather than a complete range query: if more than 2,000 events fall before the end of the window, later events will be omitted. Confirm an iCMS upper-bound date filter and then fetch only the visible month and missing ranges. A range-aware cache would also avoid reading every earlier page when the user opens a later month.
