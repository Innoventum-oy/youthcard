# Discover and Calendar review

Date: 2026-10-11

## What the live app shows

- Discover currently requests the category list, then makes another event request for every category that enters the viewport. Empty categories used to reserve a full-height carousel; that layout has been corrected, but the request pattern remains.
- The [Figma Discover view](https://www.figma.com/design/Qc215zClE0kqncDGYxF84I) presents a mixed image-led feed with All, Activities, and Places filters. The current app presents category sections instead.
- Calendar's 1,000-item full-field request failed after a long wait in the iOS simulator. A 250-item request with the five fields used by the view loaded event markers and thumbnails successfully. Calendar now pages those requests, showing the first page while later pages load.

## Discover direction

1. Make the landing view a feed with **All**, **Activities**, and **Places** filters. Load upcoming activities and active places through one paged request per type. Use the existing 30-minute request cache. Keep event and place cards image-led, with a category image or themed icon when no event cover exists.
2. Show category choices as a compact secondary strip. Load a category's events only after it is opened. This removes the request per visible category while preserving category browsing.
3. Fetch the next page when the user reaches the end of a feed. Deduplicate by activity ID and preserve the visible results during refresh or a network error. Keep a manual refresh action.
4. Make search server backed once the iCMS filter contract is confirmed. A client-only filter over the first page would falsely imply that it searches all available activities and places.
5. Keep location permission optional. Places can initially sort by name; sort by distance only after the user grants location access.

The first implementation should replace the category-first body in `CategorisedActivityList` with the feed. The existing category screen can become a secondary route. The existing `ActivityListProvider` already caches requests by their sorted parameters, so each feed and page can reuse its snapshot.

## Calendar choice

Keep `table_calendar` for the current month-and-upcoming-events layout. The resolved version is 3.3.0; its API supports locale, event loading, month/week formats, and custom builders. The dependency constraint now names 3.3.0 explicitly. The calendar's Finnish weekday labels now use the active app locale.

[`calendar_view`](https://pub.dev/packages/calendar_view) is a stronger choice if the product needs day and week scheduling views, but its 2.x series warns that releases may contain breaking changes. [`flutter_calendar_carousel`](https://pub.dev/packages/flutter_calendar_carousel) offers a newer controlled month/week widget, but replacing the working month view would not resolve the data-loading issue. [`table_calendar`](https://pub.dev/packages/table_calendar) already provides the UI hooks needed for the Figma view.

The calendar currently requests up to eight 250-item pages in date order, stopping after the first page that extends beyond its navigation window. The `ActivityListProvider` caches each page for 30 minutes, so reopening Calendar can reuse the results. This is an interim guard rather than a complete range query: if more than 2,000 events fall before the end of the window, later events will be omitted. Confirm an iCMS upper-bound date filter and then fetch only the visible month and missing ranges. A range-aware cache would also avoid reading every earlier page when the user opens a later month.
