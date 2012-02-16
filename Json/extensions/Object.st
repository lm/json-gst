Object extend [

	asJsonString [
		<category: '*JSON'>

		^String streamContents: [ :string | self storeAsJsonOn: string]
	]

]

