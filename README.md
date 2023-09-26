# App Overview

The app is organized into various sub-libraries for modular functionality.

## Sub-Libraries

### RJCore

- **RJServices**: Declares core types and protocols. Intended to be utilized across the app.
- **RJImplementations**: Implements protocols declared in RJServices. Positioned either in AppDelegate for dependency injection or in unit tests for identical purposes.
- **RJResources**: A minimal set of files designed purely for testing objectives.

### RJViewModel

This package, as implied by its name, comprises view models prepared for future UI integrations. It's solely dependent on RJServices and is oblivious to its implementations.

## Design Philosophy

Given the specifics of the position, the application is tailored to be:

- **Robust**: Abundant tests are incorporated (would have been even more if time permitted). The app also features extensive logs made through the system's `Logger`, proving particularly beneficial in the Xcode 15 debugger. Moreover, there's an inclusion of analytics and reporting for unhandled errors. There are no restrictions on the input language.

- **Flexible**: The `WordsCounter` accepts configuration as an argument. It supports diverse parsing rules, post-processing, and harbors potential for further expansions. Notably, all sub-libraries, including the view models, are independent of the UI framework. They're compatible with UIKit, AppKit, or SwiftUI (possibly necessitating some supplementary components for the latter).

- **Backward Compatible**: Designed to be iOS 14+ compatible. (had to use the older `NSRegularExpression` as opposed to the modern `Regex`)

I've added a few big text files for fun (as the original parsed too swiftly). To integrate additional files, kindly transfer them to `./Packages/RJCore/Sources/RJResources/Files` and include the filename into the `LocalTextFile` enumeration. The input file can be changed in `AppDelegate.initialInputFile`. By default it is set to "Romeo and Juliet" duplicated 120 times (resulting in some 400k lines). 

As the original text file had some funny encoding (there were problems with the apostrophes parsing), I've fixed it manually. Please let me know if dealing with it programmatically was part of the task - I have a few workarounds in mind and can implement them as well.

## What's Not Included

Due to time constraints, several important items were omitted during the implementation:

- Ascending/descending sort for each criteria (can be done via inverting entries in the existing index tables)
- UI for in-app input & configuration change (while supported by view model)
- UI tests.
- Localization.
- Accessibility considerations.
- Unit tests for errors.

