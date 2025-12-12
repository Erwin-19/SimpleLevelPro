#!/bin/bash
#echo "🚀 Erstelle Repository Struktur..."
# ... [der komplette Script-Code von oben]
#!/bin/bash

echo "🚀 Erstelle Repository Struktur..."

# Repository klonen oder erstellen
if [ ! -d "SimpleLevelPro" ]; then
    echo "📁 Klone Repository..."
    git clone https://github.com/erwin-19/SimpleLevelPro.git
    cd SimpleLevelPro
else
    echo "📁 Repository existiert bereits"
    cd SimpleLevelPro
fi

# Ordner erstellen
mkdir -p .github/workflows
mkdir -p app/src/main/java/com/simplelevel/pro
mkdir -p app/src/main/res/layout

echo "📝 Erstelle Dateien..."

# 1. GitHub Actions
cat > .github/workflows/android.yml << 'EOF'
name: Build Android APK
on: [push, workflow_dispatch]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    - name: Build APK
      run: |
        chmod +x gradlew
        ./gradlew assembleDebug
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-debug
        path: app/build/outputs/apk/debug/*.apk
EOF

# 2. MainActivity.kt
cat > app/src/main/java/com/simplelevel/pro/MainActivity.kt << 'EOF'
package com.simplelevel.pro
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.math.*
class MainActivity : AppCompatActivity(), SensorEventListener {
    private lateinit var sensorManager: SensorManager
    private lateinit var tvDegrees: TextView
    private lateinit var tvCmPerM: TextView
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        tvDegrees = findViewById(R.id.tvDegrees)
        tvCmPerM = findViewById(R.id.tvCmPerM)
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        sensorManager.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_NORMAL)
    }
    override fun onSensorChanged(event: SensorEvent) {
        val x = event.values[0]
        val y = event.values[1]
        val angle = atan2(x.toDouble(), y.toDouble()) * (180.0 / PI)
        val absAngle = abs(angle)
        runOnUiThread {
            tvDegrees.text = "%.1f°".format(absAngle)
            val radians = absAngle * PI / 180
            val cmPerM = tan(radians) * 100
            tvCmPerM.text = "%.1f cm/m".format(cmPerM)
        }
    }
    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
    override fun onPause() { super.onPause(); sensorManager.unregisterListener(this) }
    override fun onResume() { 
        super.onResume()
        val accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        sensorManager.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_NORMAL)
    }
}
EOF

# 3. Layout
cat > app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:gravity="center"
    android:padding="24dp"
    android:background="#F5F5F5">
    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="📱 SimpleLevel Pro"
        android:textSize="28sp"
        android:textStyle="bold"
        android:textColor="#2196F3"
        android:layout_marginBottom="48dp"/>
    <TextView
        android:id="@+id/tvDegrees"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="0.0°"
        android:textSize="72sp"
        android:textStyle="bold"
        android:textColor="#212121"/>
    <TextView
        android:id="@+id/tvCmPerM"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="0.0 cm/m"
        android:textSize="32sp"
        android:textColor="#FF9800"
        android:layout_marginTop="24dp"/>
    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Halte Gerät parallel zur Oberfläche"
        android:textSize="14sp"
        android:textColor="#757575"
        android:layout_marginTop="48dp"/>
</LinearLayout>
EOF

# 4. Manifest
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-feature android:name="android.hardware.sensor.accelerometer" android:required="true"/>
    <application
        android:allowBackup="true"
        android:label="SimpleLevel Pro"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:screenOrientation="portrait">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# 5. Build Gradle
cat > app/build.gradle.kts << 'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}
android {
    namespace = "com.simplelevel.pro"
    compileSdk = 34
    defaultConfig {
        applicationId = "com.simplelevel.pro"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }
    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
}
dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
}
EOF

# 6. Settings Gradle
cat > settings.gradle.kts << 'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "SimpleLevelPro"
include(":app")
EOF

# 7. Gradle Properties
cat > gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx2048m
android.useAndroidX=true
android.enableJetifier=true
EOF

# 8. README
cat > README.md << 'EOF'
# 📱 SimpleLevel Pro
Einfacher Neigungsmesser mit cm/m Umrechnung.
## 📥 Download APK
[⬇️ Download Latest APK](https://github.com/erwin-19/SimpleLevelPro/releases)
## ✨ Features
- Grad-Anzeige
- cm/m Umrechnung
- Einfache Bedienung
## 🚀 Installation
1. APK herunterladen
2. Auf Android installieren
3. App öffnen und nutzen
EOF

# 9. LICENSE
cat > LICENSE << 'EOF'
MIT License
Copyright (c) 2024 erwin-19
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

echo "✅ Alle Dateien erstellt!"
echo "📤 Lade auf GitHub hoch..."

# Git Commands
git add .
git commit -m "🚀 SimpleLevel Pro - Funktionierende Version"
git push origin main

echo "🎉 Fertig! APK wird in GitHub Actions gebaut."
echo "📥 Download: https://github.com/erwin-19/SimpleLevelPro/actions"