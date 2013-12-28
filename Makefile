SRC = $(shell find syn -name '*{h,m}')
COCOAPODS = Pods Podfile.lock

install: $(COCOAPODS) $(SRC)
	@xcodebuild \
		-workspace syn.xcworkspace \
		-scheme syn \
		-sdk macosx \
		-configuration Release

$(COCOAPODS):
	@pod install

