$env:ANDROID_HOME = "C:\Users\TERY\AppData\Local\Android\Sdk"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:MAVEN_HOME = "C:\apache-maven-3.9.14"
$env:Path += ";$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\build-tools\35.0.0;$env:JAVA_HOME\bin;$env:MAVEN_HOME\bin"

Write-Host "--- Cấu hình môi trường thành công ---" -ForegroundColor Green
Write-Host "ANDROID_HOME: $env:ANDROID_HOME"
Write-Host "JAVA_HOME: $env:JAVA_HOME"
Write-Host "--------------------------------------"
