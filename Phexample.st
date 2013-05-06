TestResource subclass: Given [
    | cache |
    
    <comment: nil>
    <category: 'Phexample-Core'>

    consumeReturnValueAt: testMethod [
	<category: 'dependencies'>
	^(cache includesKey: testMethod) 
	    ifTrue: [cache removeKey: testMethod]
	    ifFalse: 
		[| ret |
		testMethod setUp.
		ret := testMethod perform: testMethod selector.
		testMethod tearDown.
		ret]
    ]

    produceReturnValueAt: testMethod [
	<category: 'dependencies'>
	cache at: testMethod ifAbsentPut: [testMethod perform: testMethod selector]
    ]

    setUp [
	<category: 'fixture'>
	cache := Dictionary new
    ]

    tearDown [
	<category: 'fixture'>
	cache := nil
    ]
]



TestCase subclass: Phexample [
    | givenNotGiven |
    
    <comment: 'Phexample, because well designed tests expand on one another.Examples see ForExampleStack. by Adrian Kuhn and Niko Schwarz  '>
    <category: 'Phexample-Core'>

    Phexample class >> allTestSelectors [
	<category: 'accessing'>
	| selectors |
	selectors := self allSelectors copy.
	selectors removeAll: Phexample allSelectors.
	selectors := selectors select: [:each | self isTest: each].
	^selectors union: super allTestSelectors
    ]

    Phexample class >> isTest: aSelector [
	<category: 'selector testing'>
	^(aSelector includesSubstring: 'should' caseSensitive: false) 
	    and: [aSelector numArgs isZero]
    ]

    Phexample class >> resources [
	<category: 'accessing'>
	^{Given}
    ]

    Phexample class >> shouldInheritSelectors [
	<category: 'accessing'>
	^true
    ]

    = example [
	<category: 'equality'>
	^self class = example class and: [self selector = example selector]
    ]

    cleanUpInstanceVariables [
	<category: 'private'>
	| names |
	names := self class allInstVarNames asOrderedCollection.
	names removeAll: Phexample allInstVarNames.
	names do: [:name | self instVarNamed: name put: nil]
    ]

    expectedFailures [
	<category: 'private'>
	| pragmas |
	pragmas := Pragma 
		    allNamed: #expectedFailure
		    from: self class
		    to: Object.
	^pragmas collect: [:each | each method selector]
    ]

    given: anExampleName [
	<category: 'dependencies'>
	self should respondTo: anExampleName.
	(thisContext sender method selector = anExampleName) should be false.
	^[Given current consumeReturnValueAt: (self class selector: anExampleName)] 
	    on: TestResult failure , TestResult error
	    do: 
		[:ex | 
		givenNotGiven := true.
		ex pass]
    ]

    hash [
	<category: 'equality'>
	^self class hash bitXor: self selector hash
    ]

    performTest [
	<category: 'private'>
	^Given current produceReturnValueAt: self
    ]

    shouldPass [
	<category: 'private'>
	^super shouldPass and: [(givenNotGiven = true) not]
    ]
]



Phexample subclass: ForExampleMatcher [
    
    <comment: nil>
    <category: 'Phexample-Test'>

    shouldBeFalse [
	<category: 'examples-expecting-boolean'>
	(Set with: 42) isEmpty should beFalse
    ]

    shouldBeKindOf [
	<category: 'examples-expecting-reflection'>
	'hello' should beKindOf: String
    ]

    shouldBeKindOfSuperclass [
	<category: 'examples-expecting-reflection'>
	'hello' should beKindOf: Collection
    ]

    shouldBeSame [
	<category: 'examples-expecting'>
	[self should beSameAs: self] value should = nil
    ]

    shouldBeTrue [
	<category: 'examples-expecting-boolean'>
	Set new isEmpty should beTrue
    ]

    shouldBeginWith [
	<category: 'examples-expecting-string'>
	'abcdef' should beginWith: 'abc'
    ]

    shouldChange [
	<category: 'examples-expecting-change'>
	| list |
	list := OrderedCollection new.
	[list add: nil] should change: [list size]
    ]

    shouldChangeFromTo [
	<category: 'examples-expecting-change'>
	| list |
	list := (OrderedCollection new)
		    add: nil;
		    add: nil;
		    yourself.
	[list add: nil] should 
	    change: [list size]
	    from: 2
	    to: 3
    ]

    shouldContainNameOfBooleanPropertyInMessageTextWhenFailing [
	<category: 'examples-expecting-boolean'>
	[nil notNil should beTrue] should signal: TestFailure
	    withMessageText: 'expected #notNil to be true'
    ]

    shouldEndWith [
	<category: 'examples-expecting-string'>
	'abcdef' should endWith: 'def'
    ]

    shouldEqualFive [
	<category: 'examples-expecting'>
	(2 + 3) should = 5
    ]

    shouldEqualIgnoringOrder [
	<category: 'examples-expecting-collections'>
	'Hi Niko' should equalIgnoringOrder: 'iH ikoN'.
	'Hi Niko' should not equalIgnoringOrder: 'Hi Niko2'.
	'Hi Niko' should not equalIgnoringOrder: 'Hi Niko '	"Trailing space."
    ]

    shouldGreaterThan [
	<category: 'examples-expecting'>
	6 should > 5
    ]

    shouldHandlePathologicCaseOfBooleanPropertyWhenFailing [
	<category: 'examples-expecting-boolean'>
	[nil should beTrue] should signal: TestFailure
	    withMessageText: 'expected #<unknown> to be true'
    ]

    shouldHaveTestsInThisClass [
	<category: 'examples'>
	self class allTestSelectors isEmpty should not be true.
	self class allTestSelectors size should > 20
    ]

    shouldInclude [
	<category: 'examples-expecting-collections'>
	#(#foo #bar) should include: #foo
    ]

    shouldIncludeFoo [
	<category: 'examples-expecting-boolean'>
	(#(#foo #bar #qux) includes: #foo) should beTrue
    ]

    shouldLesserThan [
	<category: 'examples-expecting'>
	5 should < 6
    ]

    shouldMatchRegex [
	<category: 'examples-expecting-string'>
	'aaa' should matchRegex: 'a*'
    ]

    shouldNotBeFalse [
	<category: 'examples-expecting-boolean'>
	| set |
	set := Set new.
	set isEmpty should not be false.
	^set
    ]

    shouldNotBeKindOfSubclass [
	<category: 'examples-expecting-reflection'>
	'hello' should not beKindOf: Symbol
    ]

    shouldNotBeTrue [
	<category: 'examples-expecting-boolean'>
	(Set with: 42) isEmpty should not beTrue
    ]

    shouldNotEqualSeven [
	<category: 'examples-expecting'>
	(2 + 3) should not = 7
    ]

    shouldNotInclude [
	<category: 'examples-expecting-collections'>
	#(#foo #bar) should not include: #qux
    ]

    shouldNotMatchRegex [
	<category: 'examples-expecting-string'>
	'aaa' should not matchRegex: 'ba*'
    ]

    shouldNotOffByOneWhenFindingNameOfUnknownMessage [
	<category: 'examples-expecting-boolean'>
	
	[#() isEmpty should be false should	"kinda artifical example,
	 but exercises the off-by-one nature of the PC which points after
	 #false when looking for the message name, ie we must  make sure
	 that we dont search to far which would yield #false instead of
	 the correct #isEmpty message."] 
		should signal: TestFailure withMessageText: 'expected #isEmpty to be false'
    ]

    shouldNotRespondTo [
	<category: 'examples-expecting-reflection'>
	Object new should not respondTo: #zork
    ]

    shouldNotSignalIfNothingFailed [
	<category: 'examples-expecting-error'>
	[] should not signal: Error
    ]

    shouldNotSignalWithMessageText [
	<category: 'examples-expecting-error'>
	[] should not signal: Error withMessageText: 'bla'
    ]

    shouldRespondTo [
	<category: 'examples-expecting-reflection'>
	Object new should respondTo: #yourself
    ]

    shouldReturnNilWhenTesting [
	<category: 'examples'>
	[5 should = 5] value should = nil
    ]

    shouldRunWithin [
	"makes the Kessel Run in less than twelve parsecs"

	<category: 'examples-expecting-performance'>
	[] should runWithin: 10 milliSeconds
    ]

    shouldSignal [
	<category: 'examples-expecting-error'>
	[5 should = 6] should signal: TestFailure
    ]

    shouldSignalIfFiveShouldNotEqualFive [
	<category: 'examples-expecting'>
	[5 should not = 5] should signal: TestFailure
    ]

    shouldSignalIfSignalMissing [
	<category: 'examples-expecting-error'>
	[[5 should = 5] should signal: TestFailure] should signal: TestFailure
	    withMessageText: 'Should raise TestFailure but was none'
    ]

    shouldSignalIfSignalWrong [
	<category: 'examples-expecting-error'>
	[[self error] should signal: TestFailure] should signal: Error
	"withMessageText: 'Expected class TestFailure but was Error'"
    ]

    shouldSignalIfUnexpectedSignalOfSubtype [
	<category: 'examples-expecting-error'>
	[[5 should = 6] should not signal: TestFailure] should signal: TestFailure
	    withMessageText: 'Should not raise TestFailure but did'
    ]

    shouldSignalWhenBeFalseFails [
	<category: 'examples-expecting-boolean'>
	[Set new isEmpty should beFalse] should signal: TestFailure
	    withMessageText: 'expected #isEmpty to be false'
    ]

    shouldSignalWhenBeKindOfFails [
	<category: 'examples-expecting-reflection'>
	['hello' should beKindOf: Number] should signal: TestFailure
    ]

    shouldSignalWhenBeSameFails [
	<category: 'examples-expecting'>
	['string' copy should beSameAs: 'string' copy] should signal: TestFailure
	    withMessageText: 'expected ''string'' but got ''string'' (using ==)'
    ]

    shouldSignalWhenBeTrueFails [
	<category: 'examples-expecting-boolean'>
	[(Set with: 42) isEmpty should beTrue] should signal: TestFailure
	    withMessageText: 'expected #isEmpty to be true'
    ]

    shouldSignalWhenBeginsWithFails [
	<category: 'examples-expecting-string'>
	['abcdef' should beginWith: 'abcX'] should signal: TestFailure
	    withMessageText: 'expected ''abcX'' but got ''abcdef'' (using beginsWith:)'
    ]

    shouldSignalWhenEndWithFails [
	<category: 'examples-expecting-string'>
	['abcdef' should endWith: 'Xdef'] should signal: TestFailure
	    withMessageText: 'expected ''Xdef'' but got ''abcdef'' (using endsWith:)'
    ]

    shouldSignalWhenGreaterThanFails [
	<category: 'examples-expecting'>
	[5 should > 6] should signal: TestFailure
	    withMessageText: 'expected 6 but got 5 (using >)'.
	[4 should > 4] should signal: TestFailure
	    withMessageText: 'expected 4 but got 4 (using >)'
    ]

    shouldSignalWhenIncludeFails [
	<category: 'examples-expecting-collections'>
	[#(#foo #bar) should include: #qux] should signal: TestFailure
    ]

    shouldSignalWhenLesserThanFails [
	<category: 'examples-expecting'>
	[6 should < 5] should signal: TestFailure
	    withMessageText: 'expected 5 but got 6 (using <)'.
	[4 should < 4] should signal: TestFailure
	    withMessageText: 'expected 4 but got 4 (using <)'
    ]

    shouldSignalWhenMatchRegexFails [
	<category: 'examples-expecting-string'>
	['aaa' should matchRegex: 'ba*'] should signal: TestFailure
	    withMessageText: 'expected ''ba*'' but got ''aaa'' (using matchesRegex:)'
    ]

    shouldSignalWhenNotBeFalseFails [
	<category: 'examples-expecting-boolean'>
	[(Set with: 42) isEmpty should not beFalse] should signal: TestFailure
	    withMessageText: 'did not expect #isEmpty to be false'
    ]

    shouldSignalWhenNotBeTrueFails [
	<category: 'examples-expecting-boolean'>
	[Set new isEmpty should not beTrue] should signal: TestFailure
	    withMessageText: 'did not expect #isEmpty to be true'
    ]

    shouldSignalWhenNotIncludeFails [
	<category: 'examples-expecting-collections'>
	[#(#foo #bar) should not include: #foo] should signal: TestFailure
    ]

    shouldSignalWhenNotMatchRegexFails [
	<category: 'examples-expecting-string'>
	['aaa' should not matchRegex: 'a*'] should signal: TestFailure
	    withMessageText: 'expected not to get ''a*'' but got ''aaa'' (using matchesRegex:)'
    ]

    shouldSignalWhenNotRespondToFails [
	<category: 'examples-expecting-reflection'>
	[Object new should not respondTo: #yourself] should signal: TestFailure
	    withMessageText: 'expected an Object not to respond to #yourself (using respondsTo:)'
    ]

    shouldSignalWhenRespondToFails [
	<category: 'examples-expecting-reflection'>
	[Object new should respondTo: #zork] should signal: TestFailure
	    withMessageText: 'expected an Object to respond to #zork (using respondsTo:)'
    ]

    shouldSignalWhenRunWithinFails [
	<category: 'examples-expecting-performance'>
	[[(Delay forMilliseconds: 20) wait] should runWithin: 10 milliSeconds] 
	    should signal: TestFailure
    ]

    shouldSignalWhenSignalWithMessageTextFails [
	<category: 'examples-expecting-error'>
	[[self error: 'foo'] should signal: Error withMessageText: 'bar'] 
	    on: TestFailure
	    do: [:ex | ex messageText should = 'expected ''bar'' but got ''foo'' (using =)']
    ]

    shouldSignalWithMessage [
	<category: 'examples-expecting-error'>
	[5 should = 6] should signal: TestFailure
	    withMessageText: 'expected 6 but got 5 (using =)'
    ]

    shouldSignalWithMessageBlock [
	<category: 'examples-expecting-error'>
	[5 should = 6] should signal: TestFailure
	    withMessageText: 
		[:m | 
		m should beKindOf: String.
		m isEmpty should not be true.
		m should = 'expected 6 but got 5 (using =)']
    ]

    shouldTestForSameHashWhenExpectingEqualValues [
	<category: 'examples-expecting'>
	| factory probe p |
	factory := ClassFactoryForTestCase new.
	probe := factory 
		    newSubclassOf: Object
		    instanceVariableNames: 'counter'
		    classVariableNames: ''.
	probe compile: 'initialize counter := 0'.
	probe compile: 'hash ^counter := counter + 1'.
	probe compile: 'printOn: stream stream nextPutAll: ''probe'''.
	p := probe new.
	p hash should = 1.
	p hash should = 2.
	p hash should = 3.
	[p should = p] should signal: TestFailure
	    withMessageText: 'expected same hash for probe and probe (using hash implied by =)'.
	[p should not ~= p] should signal: TestFailure
	    withMessageText: 'expected same hash for probe and probe (using hash implied by =)'.
	factory cleanUp
    ]
]



Phexample subclass: ForExampleStack [
    
    <comment: nil>
    <category: 'Phexample-Test'>

    shouldBeEmpty [
	<category: 'examples'>
	| stack |
	stack := Stack new.
	stack isEmpty should beTrue.
	stack size should = 0.
	^stack
    ]

    shouldFailWhenPopEmpty [
	<category: 'examples'>
	| stack |
	stack := self given: #shouldBeEmpty.
	[stack pop] should signal: Error.
	[stack pop] on: Error
	    do: [:e | e messageText should matchRegex: '.* is empty']
    ]

    shouldLastInFirstOut [
	<category: 'examples'>
	| stack |
	stack := self given: #shouldPushMoreElements.
	stack pop should = 13.
	stack pop should = 7.
	stack pop should = 42.
	stack isEmpty should beTrue
    ]

    shouldPopElement [
	<category: 'examples'>
	| stack |
	stack := self given: #shouldPushElement.
	stack pop should = 42.
	stack isEmpty should beTrue.
	stack size should = 0.
	^stack
    ]

    shouldPushElement [
	<category: 'examples'>
	| stack |
	stack := self given: #shouldBeEmpty.
	stack push: 42.
	stack isEmpty should not beTrue.
	stack size should = 1.
	stack top should = 42.
	^stack
    ]

    shouldPushMoreElements [
	<category: 'examples'>
	| stack |
	stack := self given: #shouldPushElement.
	stack push: 7.
	stack push: 13.
	stack isEmpty should not beTrue.
	stack size should = 3.
	stack top should = 13.
	^stack
    ]
]



Phexample subclass: PhexampleClassTest [
    | factory |
    
    <comment: 'PhexampleClassTest has is like PhexampleTest, but inherits from Phexample. That''s a bit circular, which is why more ''advanced'' tests go here.'>
    <category: 'Phexample-Test'>

    assertForTestResult: aResult runCount: aRunCount passed: aPassedCount failed: aFailureCount errors: anErrorCount expectedFailures: anExpectedFailureCount [
	<category: 'tests'>
	self
	    assert: aResult runCount = aRunCount;
	    assert: aResult expectedPassCount = aPassedCount;
	    assert: aResult failureCount = aFailureCount;
	    assert: aResult errorCount = anErrorCount;
	    assert: aResult expectedDefectCount = anExpectedFailureCount
    ]

    expectedFailureFails [
	<category: 'private'>
	<expectedFailure>
	self assert: false
    ]

    expectedFailurePasses [
	<category: 'private'>
	<expectedFailure>
	self assert: true
    ]

    shouldComputeNumberOfTests [
	<category: 'tests'>
	self class allTestSelectors size should = 4
    ]

    testExpectedFailure [
	<category: 'tests'>
	| case result |
	case := self class selector: #expectedFailureFails.
	self deny: case shouldPass.
	result := case run.
	self 
	    assertForTestResult: result
	    runCount: 1
	    passed: 0
	    failed: 0
	    errors: 0
	    expectedFailures: 1
    ]

    testExpectedFailureDetection [
	<category: 'tests'>
	self assert: self expectedFailures asSet
	    equals: #(#expectedFailureFails #expectedFailurePasses) asSet
    ]

    testExpectedFailurePass [
	<category: 'tests'>
	| case result |
	case := self class selector: #expectedFailurePasses.
	self deny: case shouldPass.
	result := case run.
	self 
	    assertForTestResult: result
	    runCount: 1
	    passed: 0
	    failed: 1
	    errors: 0
	    expectedFailures: 0
    ]
]



Phexample subclass: PhexampleTest [
    | factory |
    
    <comment: nil>
    <category: 'Phexample-Test'>

    PhexampleTest class >> allTestSelectors [
	| selectors |
	selectors := self selectors select: [:each | each beginsWith: 'should'].
	^selectors union: super allTestSelectors
    ]

    setUp [
	<category: 'fixture'>
	factory := ClassFactoryForTestCase new
    ]

    shouldExecuteExampleMethod [
	<category: 'examples'>
	| class testcase hasRun result |
	class := factory 
		    newSubclassOf: Phexample
		    instanceVariableNames: 'action'
		    classVariableNames: ''.
	class compile: 'shouldRun action value'.
	class compile: 'action: aBlock action := aBlock'.
	testcase := class selector: #shouldRun.
	testcase action: [hasRun := true].
	result := testcase run.
	result tests size should = 1.
	result passed size should = 1.
	hasRun should be true
    ]

    shouldHaveGivenAsResource [
	<category: 'examples'>
	Phexample resources should include: Given
    ]

    shouldNicelyHandleNotifications [
	"Checks whether notifications are properly ignored, both immediately and in dependent tests."

	<category: 'examples'>
	| class testcase hasRun result suite |
	class := factory 
		    newSubclassOf: Phexample
		    instanceVariableNames: ''
		    classVariableNames: ''.
	class compile: 'throwNotification Notification  signal:''Waa!'''.
	class compile: 'consumeNotification   self given: #throwNotification. '.
	suite := TestSuite new.
	suite
	    addTest: (class selector: #throwNotification);
	    addTest: (class selector: #consumeNotification).
	result := suite run.
	result passedCount should = 2.
	result failureCount should = 0.
	result errorCount should = 0.
	result unexpectedPassCount should = 0.
	result unexpectedErrorCount should = 0.
	result unexpectedFailureCount should = 0
    ]

    shouldNotHaveTestsInPhexample [
	<category: 'examples'>
	Phexample allTestSelectors isEmpty should be true
    ]

    tearDown [
	<category: 'fixture'>
	factory cleanUp
    ]
]



Phexample subclass: PhexampleTestSelectorTest [
    
    <comment: nil>
    <category: 'Phexample-Test'>

    shouldAllowShouldInBeginningOfSelector [
	<category: 'tests'>
	(Phexample isTest: #shouldBeTest) should be true
    ]

    shouldAllowShouldInMiddleOfSelector [
	<category: 'tests'>
	(Phexample isTest: #fooShouldBeAllowed) should be true
    ]

    shouldNotAllowSelectorsWithArguments [
	<category: 'tests'>
	(Phexample isTest: #shouldFoo:) should be false.
	(Phexample isTest: #fooShould:NotBeAllowed:) should be false
    ]
]



Phexample subclass: PhexampleTodoTest [
    
    <comment: nil>
    <category: 'Phexample-Test'>

    expectedFailures [
	<category: 'private'>
	^(Smalltalk hasClassNamed: #TestTodo) 
	    ifTrue: [#()]
	    ifFalse: [#(#shouldSupportTodo)]
    ]

    shouldSupportTodo [
	<category: 'tests'>
	self should do: 'a real test'.
	self should testFor: 'something'
    ]
]



Object extend [

    should [
	<category: '*phexample-core'>
	^PhexMatcher with: self
    ]

]



Object subclass: PhexMatcher [
    | value state |
    
    <category: 'Phexample-Core'>
    <comment: 'A PhexMatcher is the sort of thing that works out if your example behaves properly or not. Most of the magic happens in expect:using:. Please notice that = works unlike in most classes. Therefore, do not store me in a collection!If you wish to forward to another ''should'' method call, the state of this matcherwould be lost. Instead, call either expect*, which works fine, or, if nothing else works,use self should:. Note that this is much slower and leads to messier stack traces than calling expectInstance Variables	state:		the items matched so far	value:		state	- xxxxxvalue	- xxxxx'>

    PhexMatcher class >> rewriteRules [
	"Use this TreeRewriter to rewrite existing SUnit tests to Phexample.
	 To run the rewrite rules open the following menu:
	 Classlist -> refactor -> rewrite code.
	 Copy paste the following code in and save it to execute the rewrite rules.
	 "

	<category: 'documentation'>
	^(RBParseTreeRewriter new)
	    replace: 'self assert: [ `@expression ]' with: 'self assert: `@expression';
	    replace: 'self deny: `@expression' with: 'self assert: `@expression not';
	    replace: 'self assert: `@value = `@expected'
		with: '`@value should = `@expected';
	    replace: 'self assert: `@value ~= `@expected'
		with: '`@value should not = `@expected';
	    replace: 'self assert: `@value > `@expected'
		with: '`@value should > `@expected';
	    replace: 'self assert: `@value < `@expected'
		with: '`@value should < `@expected';
	    replace: 'self assert: `@value >= `@expected'
		with: '`@value should >= `@expected';
	    replace: 'self assert: `@value <= `@expected'
		with: '`@value should <= `@expected';
	    replace: 'self assert: (`@value isKindOf: `@type)'
		with: '`@value should beKindOf: `@type';
	    replace: 'self assert: `@expression isNil'
		with: '`@expression should be isNil';
	    replace: 'self assert: `@expression notNil'
		with: '`@expression should be notNil';
	    replace: 'self assert: `@expression `test not'
		with: '`@expression should not be `test'
		when: 
		    [:node | 
		    node arguments first receiver selector 
			matchesRegex: '(is|has|not).+|atEnd'];
	    replace: 'self assert: `@expression `test'
		with: '`@expression should be `test'
		when: [:node | node arguments first selector matchesRegex: '(is|has|not).+|atEnd'];
	    replace: 'self assert: (`@collection includes: `@element) not'
		with: '`@collection should not be includes: `@element';
	    replace: 'self assert: (`@collection includes: `@element)'
		with: '`@collection should be includes: `@element';
	    yourself
    ]

    PhexMatcher class >> with: anObject [
	<category: 'creation'>
	^self new initialize; setValue: anObject
    ]

    PhexMatcher class >> with: anObject state: aState [
	<category: 'creation'>
	^(self new)
	    initialize;
	    setValue: anObject;
	    state: aState;
	    yourself
    ]

    < expected [
	<category: 'expecting'>
	^self expect: expected using: #'<'
    ]

    <= expected [
	<category: 'expecting'>
	^self expect: expected using: #'<='
    ]

    = expected [
	<category: 'expecting'>
	self expect: expected using: #=.
	self isShould ifTrue: [self expectSameHash: expected].
	^nil
    ]

    > expected [
	<category: 'expecting'>
	^self expect: expected using: #'>'
    ]

    >= expected [
	<category: 'expecting'>
	^self expect: expected using: #'>='
    ]

    be [
	<category: 'expecting-boolean'>
	state := state copyWith: #be
    ]

    beFalse [
	<category: 'expecting-boolean'>
	^self be false
    ]

    beKindOf: expectedClass [
	<category: 'expecting-reflection'>
	^self 
	    expect: [value isKindOf: expectedClass]
	    describeShould: 
		['expected kind of <1p> but got instance of <2p> (using isKindOf)' 
		    expandMacrosWith: expectedClass
		    with: value class]
	    describeShouldNot: 
		['expected not to get kind of <1p> but got instance of <2p> (using isKindOf)' 
		    expandMacrosWith: expectedClass
		    with: value class]
    ]

    beSameAs: expected [
	<category: 'expecting'>
	^self expect: expected using: #'=='
    ]

    beTrue [
	<category: 'expecting-boolean'>
	^self be true
    ]

    beginWith: aPrefix [
	<category: 'expecting-string'>
	^self expect: aPrefix using: #beginsWith:
    ]

    change: aBlock [
	<category: 'expecting-change'>
	| before after |
	before := aBlock value.
	value value.
	after := aBlock value.
	before should not = after
    ]

    change: aBlock from: before to: after [
	<category: 'expecting-change'>
	(self should: aBlock value) = before.
	value value.
	(self should: aBlock value) = after
    ]

    do: aDescription [
	<category: 'TDD todos'>
	TestTodo signal: aDescription
    ]

    endWith: aSuffix [
	<category: 'expecting-string'>
	^self expect: aSuffix using: #endsWith:
    ]

    equalIgnoringOrder: anotherCollection [
	<category: 'expecting-collections'>
	self 
	    expect: [value sorted = anotherCollection sorted]
	    describeShould: 
		['Expected <1p> to equal <2p> ignoring order, but didn''t.' 
		    expandMacrosWith: value
		    with: anotherCollection]
	    describeShouldNot: 
		['Expected <1p> to not equal <2p> ignoring order, but did.' 
		    expandMacrosWith: value
		    with: anotherCollection]
    ]

    expect: aBlock describeShould: shouldBlock describeShouldNot: shouldNotBlock [
	<category: 'private'>
	self isShould 
	    ifTrue: 
		[aBlock value ifFalse: [TestFailure signal: shouldBlock value].
		^nil].
	self isShouldNot 
	    ifTrue: 
		[aBlock value ifTrue: [TestFailure signal: shouldNotBlock value].
		^nil].
	self error: 'illegal state ' , state asString
    ]

    expect: expected using: aSymbol [
	<category: 'private'>
	^self 
	    expect: [value perform: aSymbol with: expected]
	    describeShould: 
		['expected <1p> but got <2p> (using <3s>)' 
		    expandMacrosWith: expected
		    with: value
		    with: aSymbol]
	    describeShouldNot: 
		['expected not to get <1p> but got <2p> (using <3s>)' 
		    expandMacrosWith: expected
		    with: value
		    with: aSymbol]
    ]

    expectSameHash: expected [
	<category: 'private'>
	value hash = expected hash 
	    ifFalse: 
		[TestFailure 
		    signal: ('expected same hash for <1p> and <2p> (using hash implied by =)' 
			    expandMacrosWith: value
			    with: expected)].
	^nil
    ]

    expectedUnknownMessageToReturn: expected [
	<category: 'private'>
	state := state copyWithout: #be.
	^self 
	    expect: [value = expected]
	    describeShould: 
		['expected #<1s> to be <2p>' 
		    expandMacrosWith: self findNameOfUnknownMessage
		    with: expected]
	    describeShouldNot: 
		['did not expect #<1s> to be <2p>' 
		    expandMacrosWith: self findNameOfUnknownMessage
		    with: expected]
    ]

    false [
	<category: 'expecting-boolean'>
	^self expectedUnknownMessageToReturn: false
    ]

    findNameOfUnknownMessage [
	"1. walk up the stack until we are outside of this instance.
	 2. collect all sent message from bytecode up to program counter.
	 3. drop messages until #should and return previous."

	<category: 'private'>
	| frame scanner sent |
	frame := thisContext.
	
	[frame := frame sender.
	frame receiver == self] whileTrue.
	scanner := InstructionStream on: frame method.
	sent := Stack new.
	scanner scanFor: 
		[:bytecode | 
		sent push: scanner selectorToSendOrSelf.
		frame pc - 1 <= scanner pc].
	
	[sent isEmpty ifTrue: [^'<unknown>'].
	sent pop = #should] whileFalse.
	sent top isSymbol ifFalse: [^'<unknown>'].
	^sent top
    ]

    hash [
	<category: 'private'>
	self 
	    error: 'Don''t put a matcher into a dictionary. It does not behave ordinarily on ='
    ]

    implement: aDescription [
	<category: 'TDD todos'>
	TestTodo signal: aDescription
    ]

    implemented [
	<category: 'TDD todos'>
	TestTodo signal
    ]

    include: element [
	<category: 'expecting-collections'>
	self expect: element using: #includes:
    ]

    initialize [
	<category: 'private'>
	state := #()
    ]

    isShould [
	<category: 'private'>
	^state = #() or: [state = #(#be)]
    ]

    isShouldNot [
	<category: 'private'>
	^state = #(#not) or: [state = #(#not #be)]
    ]

    matchRegex: regexString [
	<category: 'expecting-string'>
	^self expect: regexString using: #matchesRegex:
    ]

    nil [
	<category: 'expecting-boolean'>
	^self expectedUnknownMessageToReturn: nil
    ]

    not [
	<category: 'expecting'>
	state := state copyWith: #not
    ]

    respondTo: aSelector [
	<category: 'expecting-reflection'>
	^self 
	    expect: [value respondsTo: aSelector]
	    describeShould: 
		['expected <1p> to respond to <2p> (using respondsTo:)' 
		    expandMacrosWith: value
		    with: aSelector]
	    describeShouldNot: 
		['expected <1p> not to respond to <2p> (using respondsTo:)' 
		    expandMacrosWith: value
		    with: aSelector]
    ]

    runWithin: aDuration [
	<category: 'expecting-performance'>
	^self 
	    expect: [
		[value value.
		true] valueWithin: aDuration onTimeout: [false]]
	    describeShould: 
		['expected to run within <1p> but took longer' expandMacrosWith: aDuration]
	    describeShouldNot: 
		['expected to take longer then <1p> but was faster' 
		    expandMacrosWith: aDuration]
    ]

    setValue: anObject [
	<category: 'private'>
	value := anObject
    ]

    should: anObject [
	"If you wish to forward to another 'should method call, the state of this matcher
	 would be lost. Instead, call either expect*, which works fine, or, if nothing else works,
	 use self should:. Note that this is much slower and leads to messier stack traces than
	 calling expect*."

	<category: 'private'>
	^PhexMatcher with: anObject state: state copy
    ]

    signal: errorClass [
	<category: 'expecting-error'>
	| signaled |
	signaled := false.
	value on: errorClass do: [:ex | signaled := true].
	self 
	    expect: signaled
	    describeShould: 
		['Should raise <1p> but was none' expandMacrosWith: errorClass]
	    describeShouldNot: 
		['Should not raise <1p> but did' expandMacrosWith: errorClass]
    ]

    signal: errorClass withMessageText: message [
	<category: 'expecting-error'>
	value on: Exception
	    do: 
		[:ex | 
		(self should: ex) beKindOf: errorClass.
		message isBlock 
		    ifTrue: [message value: ex messageText]
		    ifFalse: [(self should: ex messageText) = message].
		^self].
	self 
	    expect: false
	    describeShould: 
		['Should raise <1p> but was none' expandMacrosWith: errorClass]
	    describeShouldNot: 
		['Should not raise <1p> but did' expandMacrosWith: errorClass]
    ]

    state [
	<category: 'accessing'>
	^state
    ]

    state: anObject [
	<category: 'accessing'>
	state := anObject
    ]

    testFor: aDescription [
	<category: 'TDD todos'>
	TestTodo signal: aDescription
    ]

    true [
	<category: 'expecting-boolean'>
	^self expectedUnknownMessageToReturn: true
    ]

    ~= expected [
	<category: 'expecting'>
	self expect: expected using: #~=.
	self isShouldNot ifTrue: [self expectSameHash: expected].
	^nil
    ]
]



Object subclass: SequenceableCollectionComparator [
    
    <category: 'Phexample-ShouldPlugins'>
    <comment: nil>

    is: collection1 equal: collection2 [
	collection1 with: collection2 do: [:e1 :e2 | e1 = e2 ifFalse: [^false]].
	^true
    ]
]

