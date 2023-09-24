# App Overview

The app is organized into various sub-libraries for modular functionality.

## Sub-Libraries

### RJCore

- **RJServices**: Declares core types and protocols. Intended to be utilized across the app.
- **RJImplementations**: Implements protocols declared in RJServices. Positioned either in AppDelegate for dependency injection or in unit tests for identical purposes.
- **RJResources**: A minimal set of files designed purely for testing objectives.

### RJViewModel

This package, as implied by its name, comprises view models prepared for future UI integrations. It's solely dependent on RJServices and remains oblivious to its implementations.

## Design Philosophy

Given the specifics of the position, the application is tailored to be:

- **Robust**: Abundant tests are incorporated (would have integrated more if time permitted). The app also features extensive logs made through the system's `Logger`, proving particularly beneficial in the Xcode 15 debugger. Moreover, there's an inclusion of analytics and reporting for unhandled errors. Language usage remains unrestricted.

- **Flexible**: The `WordsCounter` accepts configuration as an argument. It supports diverse parsing rules, post-processing, and harbors potential for further expansions. Notably, all sub-libraries, including the view models, are independent of the UI framework. They're compatible with UIKit, AppKit, or SwiftUI (possibly necessitating some supplementary components for the latter).

- **Backward Compatible**: Designed to be iOS 14+ compatible. The sole concession involved resorting to the older `NSRegularExpression` as opposed to the modern `Regex`.

For amusement, I've embedded some extensive text files (as the original parsed too swiftly). To integrate additional files, kindly transfer them to `./Packages/RJCore/Sources/RJResources/Files` and include the filename into the `LocalTextFile` enumeration.

The original file encountered encoding issues, especially with apostrophes parsing, which I've manually rectified. If incorporating a programmatic solution to this was an anticipated part of the task, kindly notify me. I've conceptualized several strategies and can promptly execute them.

## What's Not Included

- Ascending/descending sort (for each criteria) - feasible via inverting entries in the existing index tables.
- UI tests.
- Localization.
- Accessibility considerations.
- Unit tests focusing on cancellation & errors.

