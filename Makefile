SRC = $(shell find syn -name '*{h,m}')
COCOAPODS = Pods Podfile.lock
PREFIX = /usr/local

build: $(COCOAPODS) $(SRC)
	@xcodebuild \
		-workspace syn.xcworkspace \
		-scheme syn \
		-sdk macosx \
		-configuration Release

install: bin/syn syn/syn.1
	cp bin/syn $(PREFIX)/bin/syn
	cp syn/syn.1 $(PREFIX)/share/man/man1/syn.1

bin/syn: build

$(COCOAPODS):
	@pod install

