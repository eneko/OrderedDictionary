.PHONY: docs build

docs:
	sourcedocs generate --clean --spm-module OrderedDictionary --output-folder docs

build:
	swift build --disable-sandbox -c release -Xswiftc -static-stdlib

test:
	swift test --parallel

xcode:
	swift package generate-xcodeproj --enable-code-coverage
