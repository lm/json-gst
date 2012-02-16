Dictionary extend [

	storeAsJsonOn: aStream [
		<category: 'json-storing'>

		| isFirst |

		isFirst := true.
		aStream nextPut: ${.

		self associationsDo: [ :association |
			isFirst ifFalse: [
				isFirst := false.
				aStream nextPutAll: ', '].
			association storeAsJsonOn: aStream].

		aStream nextPut: $}
	]

]

