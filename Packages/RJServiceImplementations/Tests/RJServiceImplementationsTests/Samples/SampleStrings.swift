//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import Foundation

enum SampleString: String {
	/// 3 same words + 1 different
	case simpleEngLowercased = "one two three two"
	/// 3 same words + 1 different
	case simpleEngMixCase = "oNE tWo three two"
	/// 0 words
	case zeroLength = ""
	/// 0 words
	case whitespaces = "  "
	/// 0 words
	case singleEmoji = "😊"
	/// 2 same
	case sameWordSeparatedByNumber = "one4one"
	/// 2 different
	case differentWordsSeparatedByNumber = "one4two"
	/// 2 same
	case sameWordSeparatedByEmoji = "one😊one"
	/// 2 different
	case differentWordsSeparatedByEmoji = "one😊two"
	/// 4 different
	case withSubstringWord = "spy with spying glass"
	/// 2 same words + 1 different
	case ukrainianWithComplexUnicodeCharAndSubstring = "їжа їжак їжа"
	/// 2 same words + 1 different
	case chineseSimplified = "食品 刺猬 食品"
	/// 3 different
	case chineseEngMix = "罗密欧 means Romeo"
	/// 3 different
	case chineseEngMixWithApostropheQuotes = "'罗密欧' means 'Romeo'"
	/// 2 same words + 1 different
	case sameWordWithAndWithoutApostropheQuotes = "'Romeo' means Romeo"
	/// 3 same words + 1 different
	case simpleArabicLowercased = "واحد اثنان ثلاثة اثنان"
	
	/// 1 word - special character handling
	case specialCharacterMixedWord = "he11o"
	
	/// 3 different words - mixed numbers and letters
	case mixedNumbersAndLetters = "abc123 def456 ghi789"
	
	/// 2 different words - special characters and whitespaces
	case specialCharactersAndWhitespaces = "hello!  $world#"
	
	/// 2 different words - punctuations
	case wordsWithPunctuations = "hello, world!"
	
	/// 3 different words (2 + 2 + 1) - emoji within word
	case emojiWithinWords = "love😍love hate😡hate like😊"
	
	/// 5 different words - mixed languages and numbers
	case mixedLanguagesAndNumbers = "hello 世界 123 bonjour мир"
	
	/// 1 word - URL (this could be seen as one word or may be broken down further based on the logic)
	case urlAsWord = "https://www.example.com"
	
	/// 2 different words - hyphenated words
	case hyphenatedWords = "mother-in-law father-in-law"
	
	/// 2 different words - words with apostrophes
	case wordsWithApostrophes = "it's they're"
	
	/// 2 different words - words separated by newline character
	case wordsSeparatedByNewLine = """
	hello
	world
"""
	
	// Can (and possibly should - depending on use cases) be extended furhter
	// with various types of apostrophes, exotic unicode characters etc.
	
	// ...
}
