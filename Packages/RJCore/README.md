## RJCore Module Documentation

### **Type Aliases**:

- **AnalyticsContext**: A dictionary type representing a context for analytics. It's 
  essentially a map of `String` keys to any value (`[String: Any]`).

- **WordPostProcessor**: A closure used for post-processing on words, allowing for 
  modifications or splits based on specific rules.


### **Protocols**:

- **WordsCounter**: Protocol that defines the interface for counting word frequencies in 
  a given text.
  - Method: `countWords(_ string: String, config: WordsCounterConfiguration) -> 
    WordFrequencyMap`.
    
- **WordFrequencyIndexBuilder**: A protocol outlining the requirements for building an 
  index of word frequencies.
  - Method: `build(_ frequencyMap: WordFrequencyMap, index: WordFrequencySortingKey) -> 
    [WordFrequencyMap.Key]`.

- **TextProvider**: Represents an entity capable of providing text content asynchronously.
  - Property: `text` (async, throws).
  
- **Analytics**: Defines the requirements for an analytics entity.
  - Properties: `screenShownEventName`, `screenNameKey`.
  - Methods: `error(_ error: Error)`, `event(_ key: String, context: AnalyticsContext?)`, 
    `screen(_ name: String, context: AnalyticsContext?)`.


### **Enums**:

- **WordFrequencySortingKey**: Enumerates different keys or criteria for sorting and 
  indexing word frequencies.
  - Cases: `alphabetical`, `mostFrequent`, `wordLength`.

- **MatchPattern**: Defines patterns for matching words within a text.
  - Cases: `alphanumeric`, `alphanumericWithDashesAndApostrophes`.
  - Property: `regex` - Returns a `NSRegularExpression` corresponding to the match pattern.


### **Classes**:

- **CommonWordPostProcessors**: Provides standard post-processing functions for words.
  - **endingsExtractor**: Decomposes contractions by extracting endings.
  - **postApostropheOmitter**: Omits characters following an apostrophe in a word.


### **Structures**:

- **WordsCounterConfiguration**: Configuration settings dictating how words should be parsed 
  for the `WordsCounter`.
  - Properties: `pattern` (Specifies the pattern to match words in text), 
    `postProcessor` (Optional post-processor for refining parsed words).


### **Implementation**:

- **FileTextProvider**:
  - An open class conforming to `TextProvider`. Allows asynchronous retrieval of text 
    from a file.

- **StandardIndexBuilder**:
  - An open class conforming to the `WordFrequencyIndexBuilder` protocol.

- **StandardWordsCounter**:
  - An open class conforming to `WordsCounter` protocol.  
