UndefinedObject extend [

	storeAsJsonOn: aWriteStream [
		<category: 'json-storing'>

		aWriteStream nextPutAll: 'null'
	]

]

