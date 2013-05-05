Phexample class extend [

    selectorIncludesShould: aSelector [
	<category: '*PhexamplePlatform-Pharo20'>
	^aSelector includesSubstring: 'should' caseSensitive: false
    ]

]

