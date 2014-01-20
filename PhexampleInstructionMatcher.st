Object subclass: PhexampleInstructionMatcher [
    | currentPC maxPC lastSends |

    <category: 'Phexample'>
    <comment: 'I help with the implementation of findNameOfUnknownMessage. I can
    be used for dispatch on the CompiledCode'>

    findLastSendForContext: aContext [
        currentPC := nil.
        lastSends := OrderedCollection new.
        maxPC := aContext ip.

        aContext method dispatchTo: self with: nil.
        ^lastSends
    ]

    invalidOpcode: aStream [
    ]

    pushInstVar: anIndex with: aStream [
    ]

    storeInstVar: anIndex with: aStream [
    ]

    popIntoArray: anIndex with: aStream [
    ]

    pushTemporary: anIndex outer: scopes with: aStream [
    ]

    storeTemporary: anIndex outer: scopes with: aStream [
    ]

    pushTemporary: anIndex with: aStream [
    ]

    storeTemporary: anIndex with: aStream [
    ]

    pushLiteral: anObject with: aStream [
    ]

    pushGlobal: anObject with: aStream [
    ]

    storeGlobal: anObject with: aStream [
    ]

    pushSelf: aStream [
    ]

    popStackTop: aStream [
    ]

    makeDirtyBlock: aStream [
    ]

    lineNo: n with: aStream [
    ]

    dupStackTop: aStream [
    ]

    exitInterpreter: aStream [
    ]

    returnFromContext: aStream [
    ]

    returnFromMethod: aStream [
    ]

    popJumpIfFalseTo: destination with: aStream [
    ]

    popJumpIfTrueTo: destination with: aStream [
    ]

    jumpTo: destination with: aStream [
    ]

    superSend: aSymbol numArgs: anInteger with: aStream [
    ]

    send: aSymbol numArgs: anInteger with: aStream [
	<category: 'private-printing'>
        currentPC <= maxPC
            ifTrue: [lastSends addFirst: aSymbol]
    ]

    bytecodeIndex: byte with: aStream [
        currentPC := byte.
    ]
]
