Number extend [

	storeAsJsonOn: aWriteStream [
		<category: 'json-storing'>

		self printOn: aWriteStream
	]

]

Float extend [

	storeAsJsonOn: aWriteStream [
		<category: 'json-storing'>

		self isFinite
			ifTrue: [super storeAsJsonOn: aWriteStream]
			ifFalse: [aWriteStream nextPutAll: 'null'].
	]

]

Fraction extend [

	storeAsJsonOn: aWriteStream [
		<category: 'json-storing'>

		self asFloat storeAsJsonOn: aWriteStream.
	]

]

ScaledDecimal extend [

	storeAsJsonOn: aWriteStream [
		<category: 'json-storing'>

		self asFloat storeAsJsonOn: aWriteStream.
	]

]

