PhexMatcher extend [
    PhexMatcher class >> with: anObject [
	<category: 'creation'>
        "Call initialize on GST"
	^self new initialize; setValue: anObject
    ]

    PhexMatcher class >> with: anObject state: aState [
	<category: 'creation'>
        "Call initialize on GST"
	^(self new)
	    initialize;
	    setValue: anObject;
	    state: aState;
	    yourself
    ]

    findNameOfUnknownMessage [
	"1. walk up the stack until we are outside of this instance.
	 2. collect all sent message from bytecode up to program counter.
	 3. drop messages until #should and return previous."

	<category: 'private'>
	| frame sent |
	frame := thisContext.
	
	[frame := frame parentContext.
	frame receiver == self] whileTrue.

        sent := PhexampleInstructionMatcher new
                    findLastSendForContext: frame.
                    
	[sent isEmpty ifTrue: [^'<unknown>'].
	sent removeFirst = #should] whileFalse.
	sent isEmpty ifTrue: [^'<unknown>'].
	^sent first
    ]

]

ForExampleMatcher extend [
    shouldTestForSameHashWhenExpectingEqualValues [
        "No ClassFactoryForTestCase in GST"
    ]
]

PhexampleClassTest extend [
    assertForTestResult: aResult runCount: aRunCount passed: aPassedCount failed: aFailureCount errors: anErrorCount expectedFailures: anExpectedFailureCount [
        "Our version of SUnit apparently counts differently"
	<category: 'tests'>
	self
	    assert: aResult runCount = aRunCount;
	    assert: aResult expectedPassCount = aPassedCount;
	    assert: aResult unexpectedFailureCount = aFailureCount;
	    assert: aResult errorCount = anErrorCount;
	    assert: aResult expectedDefectCount = anExpectedFailureCount
    ]

    testExpectedFailurePass [
	<category: 'tests'>
	| case result |
        "Unexpected passes are recorded differently"
	case := self class selector: #expectedFailurePasses.
	self deny: case shouldPass.
	result := case run.
	self 
	    assertForTestResult: result
	    runCount: 1
	    passed: 0
	    failed: 0
	    errors: 0
	    expectedFailures: 0
    ]
]
