Collection extend [

	storeAsJsonOn: aStream [
		"By default, use array braces"

		<category: 'json-storing'>

		aStream nextPut: $[.
		self do: [:each | each storeAsJsonOn: aStream] separatedBy: [aStream nextPutAll: ', '].
		aStream nextPut: $]
	]

]

