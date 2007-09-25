#! /usr/local/bin/gst -f
"
examples --- extract code examples from Squeak by Example LaTeX source

Assumes you have Gnu Smalltalk with scripting syntax installed (at least v2.95c).

$Id$
"

header := '
===== SQUEAK BY EXAMPLE ==========

Below follow all the (displayed) code examples from the book "Squeak by
Example".

For details about this book, see: http://SqueakByExample.org

The examples are provided, as is, for your convenience, in case you want
to copy and paste fragments to Squeak to try out.

Note that in almost all cases the annotation "--> ..." suggests that you
can select and apply <print it> to the previous expression and you should
obtain as a result the value following the arrow.

Many of these actually serve as test cases for the book. For more details
about testing, see the Wiki link under:

http://www.squeaksource.com/SBEtesting.html

'.

Object subclass: Chapter [
	| title code |
	initWithName: aName [
		<category: 'initialization'> 
		| name fileName file codeStream line |
		name := aName.
		title := '<unknown>'.	"default value"
		codeStream := WriteStream on: String new.
		fileName := name, '/', name, '.tex'.
		file := FileStream open: fileName mode: FileStream read.
		[ file atEnd ] whileFalse: [
			line := file nextLine.
			line =~ '\\chapter\{([^}]*)\}' ifMatched: [ :result |
				self setTitle: (result at: 1)
			] ifNotMatched: [
				line =~ '^\\begin\{(code|example|script|classdef|methods?|numMethod)\}'
				ifMatched: [ :result |
					self getCode: file to: codeStream
				] ifNotMatched: [ ]
			]
		].
		code := codeStream contents.
		file close.
	]
	setTitle: aString [
		<category: 'initialization'> 
		title := aString.
		title := title replacingAllRegex: '\\sq' with: 'Squeak'.
		title := title replacingAllRegex: '\\st' with: 'Smalltalk'.
	]
	getCode: file to: codeStream [
		<category: 'private'>
		| line |
		line := file nextLine.
		[ line ~ '^\\end\{' ] whileFalse: [
			"comment out --> incantation"
			line := line replacingAllRegex: '\s*(-->[^"\r\n]*)' with: ' "%1" '.
			"translate listings macros"
			line := line replacingAllRegex: '>>>' with: '>>'.
			line := line replacingAllRegex: 'BANG' with: '!'.
			line := line replacingAllRegex: 'UNDERSCORE' with: '_'.
			"compact extra space around comments"
			line := line replacingAllRegex: '" +' with: '"'.
			line := line replacingAllRegex: '""' with: ''.
			line := line replacingAllRegex: ' +"' with: ' "'.
			codeStream nextPutAll: line; nl.
			line := file nextLine
		].
		codeStream nextPutAll: '-----'; nl.
	]
	printOn: stream [ 
		<category: 'printing'> 
		stream
			nextPutAll: '===== CHAPTER: '; nextPutAll: title;
			nextPutAll: ' =========='; nl; nl;
			nextPutAll: '-----'; nl; nextPutAll: code.
	]
]

Chapter class extend [
	named: aName [
		<category: 'instance creation'>
		| ch |
		ch := super new.
		ch initWithName: aName.
		^ ch
	]
]

Transcript show: header.
(Smalltalk arguments) do: [ :each | |ch|
	ch := Chapter named: each.
	ch printNl.
].
