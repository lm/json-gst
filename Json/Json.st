Object subclass: Json [
	| stream line linePosition |

	<category: 'json'>
	<comment: 'This class reads and writes JSON format data - strings, numbers, boolean, nil, arrays and dictionaries. See http://json.org.'>

	LastEncodedCharacter := Character space.

	Json class >> readFrom: aStream [
		<category: 'parsing'>

		| parser result |

		parser := self new initializeStream: aStream.
		result := parser next.

		parser nextSeparator.
		aStream atEnd ifFalse: [parser errorExpected: 'end of input' was: aStream peek].

		^result
	]

	Json class >> parse: aString [
		<category: 'parsing'>

		^self readFrom: aString readStream
	]

	Json class >> stringify: anObject [
		<category: 'storing'>

		| stream |

		stream := WriteStream on: String new.
		anObject storeAsJsonOn: stream.
		^stream contents
	]

	Json class >> mimeType [
		<category: 'utilities'>

		^'application/x-json'
	]

	Json class >> putEscapedCharacter: aCharacter on: aStream [
		<category: 'utilities'>

		(aCharacter < LastEncodedCharacter or: [aCharacter codePoint = 127])
			ifTrue: [
				Character backspace = aCharacter ifTrue: [^aStream nextPutAll: '\b'].
				Character tab = aCharacter ifTrue: [^aStream nextPutAll: '\t'].
				Character lf = aCharacter ifTrue: [^aStream nextPutAll: '\n'].
				Character ff = aCharacter ifTrue: [^aStream nextPutAll: '\f'].
				Character cr = aCharacter ifTrue: [^aStream nextPutAll: '\r'].
				aStream nextPutAll: '\u'.
				aCharacter codePoint printOn: aStream paddedWith: $0 to: 4 base: 16]
			ifFalse: [
				$" = aCharacter ifTrue: [^aStream nextPutAll: '\"'].
				$\ = aCharacter ifTrue: [^aStream nextPutAll: '\\'].
				aStream nextPut: aCharacter]
	]

	initializeStream: anObject [
		<category: 'initialising'>

		stream := anObject.
		line := 1.
		linePosition := 0.
	]

	stream [
		<category: 'accessing'>

		^stream
	]

	next [
		<category: 'private'>

		| char |

		self nextSeparator.
		char := stream peek.

		char = $" ifTrue: [^self nextString].
		char = ${ ifTrue: [^self nextDictionary].
		char = $[ ifTrue: [^self nextArray].
		char = $t ifTrue: [self nextExpect: 'true'. ^true].
		char = $f ifTrue: [self nextExpect: 'false'. ^false].
		char = $n ifTrue: [self nextExpect: 'null'. ^nil].
		(char = $- or: [char notNil and: [char isDigit]]) ifTrue: [^self nextNumber].

		self errorExpected: 'string, object, array, true, false, null or digit' was: char.
	]

	nextString [
		<category: 'private'>

		| writeStream char |

		writeStream := WriteStream on: ''.
		(stream peekFor: $") ifFalse: [self errorExpected: 'string' was: stream peek].

		[(char := stream next) isNil or: [char = $"]] whileFalse: [
			char < LastEncodedCharacter ifTrue: [
				self errorExpected: 'printable character' was: 'control character'].

			char = $\
				ifTrue: [writeStream nextPutAll: self nextEscapedCharacter]
				ifFalse: [writeStream nextPut: char]
		].

		char ifNil: [self errorExpected: 'character' was: nil].
		^writeStream contents
	]

	nextEscapedCharacter [
		<category: 'private'>

		| char |

		char := stream next.
		char == $" ifTrue: [^'"'].
		char == $\ ifTrue: [^'\'].
		char == $/ ifTrue: [^'/'].
		char == $b ifTrue: [^Character backspace asString].
		char == $n ifTrue: [^Character lf asString].
		char == $f ifTrue: [^Character newPage asString].
		char == $r ifTrue: [^Character cr asString].
		char == $t ifTrue: [^Character tab asString].
		char == $u ifTrue: [^self nextUnicodeEscapedCharacter asString].

		self errorExpected: '", \, /, b, n, f, r, t, u' was: char asString.
	]

	nextUnicodeEscapedCharacter [
		<category: 'private'>

		| codePoint |

		(codePoint := stream nextAvailable: 4) size < 4 ifTrue: [
			self errorExpected: '4 hex digits' was: codePoint].

		^Character codePoint: (Integer readFrom: codePoint readStream radix: 16)
	]

	nextSeparator [
		<category: 'private'>

		| char |

		[(char := stream peek) notNil and: [char isSeparator]] whileTrue: [
			stream next = Character nl ifTrue: [
				line := line + 1.
				linePosition := stream position]].
	]

	nextDictionary [
		<category: 'private'>

		| result expectComma key |

		result := Dictionary new.
		expectComma := false.
		stream next.

		[
			self nextSeparator.
			stream peek = $}.
		] whileFalse: [
			expectComma ifTrue: [self nextComma; nextSeparator].
			expectComma := true.

			key := self nextString.
			self nextSeparator; nextExpect: ':'; nextSeparator.
			result at: key put: self next.
		].

		stream next.
		^result
	]

	nextArray [
		<category: 'private'>

		| result expectComma |

		result := OrderedCollection new.
		expectComma := false.
		stream next.

		[
			self nextSeparator.
			stream peek = $].
		] whileFalse: [
			expectComma ifTrue: [self nextComma; nextSeparator].
			expectComma := true.

			result add: self next.
		].

		stream next.
		^result asArray
	]

	nextComma [
		<category: 'private'>

		(stream peekFor: $,) ifFalse: [
			self errorExpected: ',' was: stream peek].
	]

	nextExpect: aString [
		<category: 'private'>

		| unexpected |

		(unexpected := stream nextAvailable: aString size) = aString ifFalse: [
			self errorExpected: aString was: (unexpected isEmpty ifTrue: [] ifFalse: [unexpected])].
	]

	nextNumber [
		<category: 'private'>

		| sign number |

		sign := (stream peekFor: $-) ifTrue: [-1] ifFalse: [1].

		(stream peekFor: $0)
			ifTrue: [number := 0]
			ifFalse: [number := self nextInteger].

		(stream peekFor: $.) ifTrue: [number := number + self nextFloat].

		number := number * sign.

		((stream peekFor: $e) or: [stream peekFor: $E]) ifTrue: [
			sign := (stream peekFor: $-) ifTrue: [-1] ifFalse: [1].
			number := number * (10 raisedTo: self nextInteger * sign)].

		^number
	]

	nextInteger [
		<category: 'private'>

		| char number |

		number := 0.

		[(char := stream peek) notNil and: [char isDigit]] whileTrue: [
			number := number * 10 + stream next digitValue].

		number = 0 ifTrue: [self errorExpected: 'digit' was: stream peek].
		^number
	]

	nextFloat [
		<category: 'private'>

		| char number i |

		number := 0.
		i := 1.

		[(char := stream peek) notNil and: [char isDigit]] whileTrue: [
			i := i * 10.
			number := stream next digitValue / i + number].

		i = 1 ifTrue: [self errorExpected: 'digit' was: stream peek].
		^number asFloat
	]

	errorExpected: aString was: currrentString [
		<category: 'error raising'>

		JsonSyntaxError signal:
			'Expected %1 but %2 found on line %3 column %4' %
				{aString.
				currrentString ifNil: ['end of input'].
				line.
				stream position - linePosition}
	]
]
