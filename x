#!/usr/bin/env bash

set -euo pipefail
set -x

rm -rf build

BUILD_TOOLS=$ANDROID_HOME/build-tools/34.0.0
PLATFORM=$ANDROID_HOME/platforms/android-34

AAPT=$BUILD_TOOLS/aapt
AAPT2=$BUILD_TOOLS/aapt2
D8=$BUILD_TOOLS/d8
ZIPALIGN=$BUILD_TOOLS/zipalign
APKSIGNER=$BUILD_TOOLS/apksigner
JAVAC=$JAVA_HOME/bin/javac
KEYTOOL=$JAVA_HOME/bin/keytool

ANDROID_JAR=$PLATFORM/android.jar

mkdir -p build

$AAPT2 compile \
	--dir assets/res \
	-o build/res.zip

$AAPT2 link \
	-o build/app.unaligned.apk \
	-I $ANDROID_JAR \
	--manifest assets/AndroidManifest.xml \
	-R build/res.zip \
	--auto-add-overlay \
	--java build/java
	# --java build/java \
	# --proguard build/proguard-rules.pro \
	# --output-text-symbols build/symbols

$JAVAC \
	-cp $ANDROID_JAR \
	-d build/classes \
	assets/MainActivity.java \
	$(find build/java -name "*.java")

$D8 \
	--no-desugaring \
	--output build \
	--release \
	$(find build/classes -name "*.class")

pushd build
$AAPT add app.unaligned.apk classes.dex
popd

$ZIPALIGN \
	-f \
	-p 4 \
	build/app.unaligned.apk \
	build/app.unsigned.apk

# TODO: use a fixed key
$KEYTOOL \
	-genkeypair \
	-keystore build/keystore.jks \
	-alias androidkey \
	-dname "CN=UN, OU=UN, O=UN, L=UN, S=UN, C=UN" \
	-validity 10000 \
	-keyalg RSA \
	-keysize 2048 \
	-storepass android \
	-keypass android

$APKSIGNER \
	sign --ks build/keystore.jks \
	--ks-key-alias androidkey \
	--ks-pass pass:android \
	--key-pass pass:android \
	--out build/app.apk \
	build/app.unsigned.apk
