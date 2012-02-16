TestCase subclass: JsonTest [

	<comment: 'I provide a number of test cases for class Json.'>
	<category: 'json'>

	testParseNull [
		self
			parseJson: 'null' equals: nil;
			parseJson: '  null' equals: nil;
			parseJson: 'null  ' equals: nil;
			parseJson: '  null  ' equals: nil.
	]

	testParseTrue [
		self
			parseJson: 'true' equals: true;
			parseJson: '  true' equals: true;
			parseJson: 'true  ' equals: true;
			parseJson: '  true  ' equals: true.
	]

	testParseFalse [
		self
			parseJson: 'false' equals: false;
			parseJson: '  false' equals: false;
			parseJson: 'false  ' equals: false;
			parseJson: '  false  ' equals: false.
	]

	testParseNumber [
		self
			parseJson: '1' equals: 1;
			parseJson: '1.23e2' equals: 123;
			parseJson: '-1.23e2' equals: -123;
			parseJson: '1e-2' equals: 1/100;
			parseJson: '-1e-2' equals: -1/100;
			parseJson: '-1' equals: -1;
			parseJson: '-0' equals: 0;
			parseJson: '-1.2' equals: -1.2.
	]

	testParseString [
		self
			parseJson: '"hi"' equals: 'hi';
			parseJson: '"\""' equals: '"';
			parseJson: '"\\"' equals: '\';
			parseJson: '""' equals: '';
			parseJson: '"a\u0004b"' equals: (String from: {$a. $<4>. $b});
			parseJson: '"a\nb"' equals: (String from: {$a. Character lf. $b});
			parseJson: '"\u263A"' equals: (Character codePoint: 16r263A) asString
	]

	testParseArray [
		self
			parseJson: '[]' equals: #();
			parseJson: '[[]]' equals: #(#());
			parseJson: '[[], []]' equals: #(#() #());
			parseJson: '["hi", "there"]' equals: #('hi' 'there');
			parseJson: '[["a", "b", null]]' equals: #(#('a' 'b' nil)).
	]

	testParseDictionary [
		self
			parseJson: '{}' equals: Dictionary new;
			parseJson: '{"a": "a"}' equals: (Dictionary with: 'a' -> 'a');
			parseJson: '{"a": [[]]}' equals: (Dictionary with: 'a' -> #(#()));
			parseJson: '{"a":"b", "b":"a"}' equals: (Dictionary with: 'a' -> 'b' with: 'b' -> 'a').
	]

	testStringifyBoolean [
		self
			stringify: true equals: 'true';
			stringify: false equals: 'false'.
	]

	testStringifyNil [
		self stringify: nil equals: 'null'.
	]

	testStringifyNumber [
		self
			stringify: 1 equals: '1';
			stringify: 1.1 equals: '1.1';
			stringify: 1e10 equals: '1.0e10';
			stringify: 1e-10 equals: '1.0e-10';
			stringify: FloatD infinity equals: 'null';
			stringify: FloatD infinity negated equals: 'null';
			stringify: 1/2 equals: '0.5';
			stringify: (1 asScaledDecimal: 1) equals: '1.0'.
	]

	testStringifyString [
		| string expected |

		string := ((0 to: 128) collect: [ :code | Character codePoint: code]) asUnicodeString.
		expected := '"\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\b\t\n\u000B\f\r\u000E',
			'\u000F\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001A\u001B',
			'\u001C\u001D\u001E\u001F !\"#$%&''()*+,-.\/0123456789:;<=>?@ABCDEFGHIJKLMNOPQRS',
			'TUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\u007F', (Character codePoint: 128) asString, '"'.

		self stringify: string equals: expected.
	]

	testStringifyArray [
		self stringify: #() equals: '[]'.
		self
			stringify: {true. false. nil. 'foo'. 2. #(). #(1). Dictionary new}
			equals: '[true, false, null, "foo", 2, [], [1], {}]'.
	]

	testStringifyDictionary [
		self
			stringify: (Dictionary with: 'key' -> 'value') equals: '{"key": "value"}';
			stringify: (Dictionary with: 42 -> 2) equals: '{"42": 2}'.
	]

	testErrorMessages [
		self
			parseJson: '[' error: 'Expected string, object, array, true, false, null or digit but end of input found';
			parseJson: '{' error: 'Expected string but end of input found';
			parseJson: '{""' error: 'Expected : but end of input found';
			parseJson: 't' error: 'Expected true but t found';
			parseJson: 'f' error: 'Expected false but f found';
			parseJson: 'n' error: 'Expected null but n found';
			parseJson: '"s' error: 'Expected character but end of input found';
			parseJson: '0 1' error: 'Expected end of input but 1 found'.
	]

	parseJson: aString error: aMessageString [
		[Json parse: aString.
		self assert: false]
			on: JsonSyntaxError do: [ :e | self assert: aMessageString = e messageText].
	]

	parseJson: aString equals: aValue [
		| value |

		value := Json parse: aString.
		self assert: value = aValue description: value printString, ' = ', aValue printString
	]

	stringify: anObject equals: aString [
		self
			assert: (Json stringify: anObject) = aString
			description: (Json stringify: anObject), ' = ', aString
	]
]

