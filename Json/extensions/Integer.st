Integer extend [

	storeAsJsonOn: aWriteStream [
		<category: 'json-storing'>

		^self printOn: aWriteStream base: 10
	]

]

