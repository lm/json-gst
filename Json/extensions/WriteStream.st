WriteStream extend [

	jsonPrint: anObject [
		<category: 'json-storing'>

		anObject storeAsJsonOn: self
	]

]

