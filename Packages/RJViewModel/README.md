## RJViewModel Module Documentation

`RJViewModel` is an internal Swift package crafted to handle word frequencies within our application.
This module is designed as a submodule for our main app, aiming to efficiently track and manage the 
frequencies of words. The use of Apple's `Combine` framework ensures reactive updates, while `OSLog`
assists in precise and streamlined logging.

### Key Components

#### 1. WordsFrequencyVM
The central ViewModel class that governs the word frequencies.

#### 2. State Management
Efficiently tracks the state of the view model, facilitating unit test tunings and providing insights
into various operations like word counting, row updating, etc.

#### 3. Configuration
While `TextProvider` acts as the source of text, `WordsCounterConfiguration` provides specific details 
for word counting. (see `RJCore` for additional details)

#### 4. Caching System
To optimize performance, a caching mechanism is implemented. This takes care of frequency maps and index
tables, thus enabling optimized row updates.

#### 5. Error & Logging Mechanisms
Errors are effectively captured and logged. This distinction between user-oriented messages and developer
logs ensures clarity during debugging sessions.

### Usage

#### Initialization

Create an instance of `WordsFrequencyVM`:
```swift
let viewModel = WordsFrequencyVM(
    textProvider: YourTextProvider(),
    wordCounter: YourWordsCounter(),
    indexBuilder: YourWordFrequencyIndexBuilder(),
    analytics: OptionalYourAnalyticsService(),
    configuration: .init(.alphanumericWithDashesAndApostrophes),
    initialSortingKey: .mostFrequent
)
```
#### Event Handling

- **View's Appearance**:
  ```swift
  viewModel.onAppear()
  ```

- **Changing Sorting Key**:
  ```swift
  viewModel.onIndexKeyChanged(newKey)
  ```

- **Changing Text Provider**:
  ```swift
  viewModel.onTextProviderChange(to: newTextProvider)
  ```

- **Configuration Adjustments**:
  ```swift
  viewModel.onConfigChange(to: newConfig)
  ```

#### State Tracking

For unit testing and other debugging purposes, the state and rowItems can be observed using Combine's
Publishers:

```swift
Copy code
viewModel.state.sink { newState in
    // Analyze state changes
}

viewModel.rowItems.sink { newItems in
    // Analyze new row items
}
```

### Development Notes

As this is an internal module, direct access to the app's subsystems, and other modules is expected.

When contributing, make sure unit tests are updated. The state mechanism has been finely tuned for
this, so utilize it to the fullest for granular test scenarios.

Please follow the established coding guidelines and standards to ensure consistency.

For any queries or clarifications, please reach out to the lead developer or consult the internal
documentation portal.
