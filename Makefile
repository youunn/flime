MAKEFLAGS += -rR

BUILD_TOOLS := $(ANDROID_HOME)/build-tools/34.0.0
PLATFORM := $(ANDROID_HOME)/platforms/android-34

AAPT := $(BUILD_TOOLS)/aapt
AAPT2 := $(BUILD_TOOLS)/aapt2
D8 := $(BUILD_TOOLS)/d8
ZIPALIGN := $(BUILD_TOOLS)/zipalign
APKSIGNER := $(BUILD_TOOLS)/apksigner
JAVAC := $(JAVA_HOME)/bin/javac
KEYTOOL := $(JAVA_HOME)/bin/keytool

ANDROID_JAR := $(PLATFORM)/android.jar

BUILD_DIR := build
CACHE_DIR := cache

RES := $(shell find app/res -type f)
JAVA_SRC := app/MainActivity.java
R_JAVA := $(BUILD_DIR)/java/im/nue/flime/R.java

.PHONY: all
all: $(BUILD_DIR)/app.apk

$(CACHE_DIR)/keystore.jks: $(CACHE_DIR)
	@mkdir -p $(CACHE_DIR)
	$(KEYTOOL) \
		-genkeypair \
		-keystore $@ \
		-dname "CN=UN, OU=UN, O=UN, L=UN, S=UN, C=UN" \
		-validity 10000 \
		-keyalg RSA \
		-keysize 2048 \
		-alias androidkey \
		-storepass android \
		-keypass android

$(BUILD_DIR)/res.zip: $(RES)
	@mkdir -p $(BUILD_DIR) 
	$(AAPT2) compile \
		--dir app/res \
		-o $(BUILD_DIR)/res.zip

$(BUILD_DIR)/app.base.apk: app/AndroidManifest.xml $(BUILD_DIR)/res.zip 
	$(AAPT2) link \
		-o $@ \
		-I $(ANDROID_JAR) \
		--manifest app/AndroidManifest.xml \
		-R $(BUILD_DIR)/res.zip \
		--java $(BUILD_DIR)/java \
		--auto-add-overlay

$(BUILD_DIR)/classes.dex: $(JAVA_SRC) $(R_JAVA)
	$(JAVAC) -cp $(ANDROID_JAR) -d $(BUILD_DIR)/classes $^
	$(D8) --no-desugaring --output $(BUILD_DIR) --release \
		$$(find $(BUILD_DIR)/classes -name "*.class")

$(BUILD_DIR)/app.unaligned.apk: $(BUILD_DIR)/app.base.apk $(BUILD_DIR)/classes.dex
	cd build && \
	cp app.base.apk app.unaligned.apk && \
	$(AAPT) add app.unaligned.apk classes.dex


$(BUILD_DIR)/app.unsigned.apk: $(BUILD_DIR)/app.unaligned.apk
	$(ZIPALIGN) -f -p 4 $< $@

$(BUILD_DIR)/app.apk: $(BUILD_DIR)/app.unsigned.apk $(CACHE_DIR)/keystore.jks
	$(APKSIGNER) sign --ks $(CACHE_DIR)/keystore.jks \
		--ks-key-alias androidkey \
		--ks-pass pass:android \
		--key-pass pass:android \
		--out $(BUILD_DIR)/app.apk \
		$<

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: install
install: $(BUILD_DIR)/app.apk
	adb push $< /data/local/tmp/flime.apk
	adb shell pm install --user 0 /data/local/tmp/flime.apk