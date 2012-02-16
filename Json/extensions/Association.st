Association extend [

	storeAsJsonOn: aStream [
		<category: 'json-storing'>

		self key asString storeAsJsonOn: aStream.
		aStream
			nextPut: $:;
			space.
		self value storeAsJsonOn: aStream
	]

]

