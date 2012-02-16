CharacterArray extend [

	storeAsJsonOn: aStream [
		<category: 'json-storing'>

		aStream nextPut: $".
		self asString do: [ :char | Json putEscapedCharacter: char on: aStream].
		aStream nextPut: $".
	]

]

