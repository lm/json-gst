TestCase subclass: JsonTest [

	<comment: 'I provide a number of test cases for class Json.'>
	<category: 'JSON'>

	json: aString equals: aValue [
	| readValue |
	readValue := self readFrom: aString.
	self assert: readValue = aValue
		description: readValue printString , ' = ' , aValue printString
	]

	readFrom: aString [
	^Json readFrom: aString readStream
	]

	render: anObject equals: aString [
	self assert: (Json render: anObject) = aString
		description: 'Json render ' , anObject printString , ' = ' , aString
	]

	testArray [
	self json: '[]' equals: #().
	self json: '[[]]' equals: #(#()).
	self json: '[[], []]' equals: #(#() #()).
	self json: '["hi", "there"]' equals: #('hi' 'there').
	self json: '[["a", "b", null]]' equals: #(#('a' 'b' nil))
	]

	testAtomFalse [
	self json: 'false' equals: false.
	self json: '  false' equals: false.
	self json: 'false  ' equals: false.
	self json: '  false  ' equals: false
	]

	testAtomNull [
	self json: 'null' equals: nil.
	self json: '  null' equals: nil.
	self json: 'null  ' equals: nil.
	self json: '  null  ' equals: nil
	]

	testAtomNumber [
	self json: '1' equals: 1.
	self json: '0123' equals: 123.
	self json: '1.23e2' equals: 123.
	self json: '-1' equals: -1.
	self json: '-0' equals: 0.
	self json: '[-1.2]' equals: {1.2 negated}
	]

	testAtomString [
	self json: '"hi"' equals: 'hi'.
	self json: '"\""' equals: '"'.
	self json: '"\\"' equals: '\'.
	self json: '""' equals: ''.
	self json: '"a\u0004b"'
		equals: (String from:
			{$a.
			Character value: 4.
			$b}).
	self json: '"a\nb"' equals: (String from:
			{$a.
			Character lf.
			$b})
	]

	testAtomTrue [
	self json: 'true' equals: true.
	self json: '  true' equals: true.
	self json: 'true  ' equals: true.
	self json: '  true  ' equals: true
	]

	testDictionary [
	self json: '{}' equals: Dictionary new.
	self json: '{"a": "a"}'
		equals: ((Dictionary new)
			at: 'a' put: 'a';
			yourself).
	self json: '{"a": [[]]}'
		equals: ((Dictionary new)
			at: 'a' put: #(#());
			yourself).
	self json: '{"a":"b", "b":"a"}'
		equals: ((Dictionary new)
			add: 'a' -> 'b';
			add: 'b' -> 'a';
			yourself)
	]

	testStringWithUnicode [
	self json: '"\u263A"'
		equals: (Character codePoint: 16r263A) asUnicodeString asString.
	]

	testWriteAssociation [
	self render: 'key' -> 'value' equals: '"key": "value"'.
	self render: 'key' -> 2 equals: '"key": 2'.
	"keys should be strings"
	self render: 42 -> 2 equals: '"42": 2'.
	]

	testWriteString [
	self render: '"' equals: '"\""'.
	self render: '\' equals: '"\\"'.
	self render: 'hi' equals: '"hi"'.
	self render: (String from:
			{$a.
			Character lf.
			$b})
		equals: '"a\nb"'.
	self render: (String from:
			{$a.
			Character value: 4.
			$b})
		equals: '"a\u0004b"'
	]
]

