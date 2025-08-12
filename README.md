<div style="display: flex; overflow-x: auto; gap: 10px; padding: 10px; scroll-snap-type: x mandatory;">
  <img src="https://raw.githubusercontent.com/Muitsu/Offline-Logger/refs/heads/main/assets/home.png" height="200" style="scroll-snap-align: center;" />
  <img src="https://raw.githubusercontent.com/Muitsu/Offline-Logger/refs/heads/main/assets/create.png" height="200" style="scroll-snap-align: center;" />
  <img src="https://raw.githubusercontent.com/Muitsu/Offline-Logger/refs/heads/main/assets/read_clean.png" height="200" style="scroll-snap-align: center;" />
  <img src="https://raw.githubusercontent.com/Muitsu/Offline-Logger/refs/heads/main/assets/share.png" height="200" style="scroll-snap-align: center;" />
</div>

# Offline Logger

A simple and powerful logging utility for Flutter that combines:
- [flutter_logs](https://pub.dev/packages/flutter_logs)
- [logger](https://pub.dev/packages/logger)
- [share_plus](https://pub.dev/packages/share_plus)
- [open_filex](https://pub.dev/packages/open_filex)

`AppLogger` supports:
✅ Pretty terminal logs  
✅ Persistent file-based logs  
✅ Exporting logs  
✅ Sharing logs  
✅ Opening logs in external apps  
✅ Auto-cleaning logs when space is low

---

## ✨ Features

- Singleton-based logger
- Supports log levels: `info`, `debug`, `warning`, `error`, `severe`
- Automatically stores logs in local device storage
- Export logs for external use
- Share logs via email, messaging, etc.
- Open logs using external apps
- Auto-delete old logs if total size exceeds limit
- Option to retain latest log while deleting older ones

---

## 🚀 Getting Started

### 1. 📦 Add Dependencies

```yaml
dependencies:
  flutter_logs: ^2.1.5
  logger: ^2.0.2
  share_plus: ^7.2.1
  open_filex: ^4.3.2
  path_provider: ^2.1.2
```
### 2. ⚙️ AndroidManifest Configuration
```
<activity
  ...
  
  android:allowBackup="false"
  android:fullBackupOnly="false" 
  >
```

### 3. 📂 Log Storage Location
```
../Android/data/com.example.appname/files/AppLogs

```
## 🛠️ Usage
### 1. Initialize the logger
Call this in main() or app startup:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger().initialize(logFileName: "app_log");
```

### 2. Start logging
```dart
AppLogger().debug("MyFunction", "Debug message");
AppLogger().info("LoginScreen", "User logged in");
AppLogger().warning("Settings", "Potential config issue");
AppLogger().error("Network", "Failed to fetch data");
AppLogger().severe("Auth", "Critical auth error");

```

## 📤 Export, Share, Open Logs

### Export logs manually (returns file path):

```dart
String path = await AppLogger().exportLogs();
```

### Share logs:

```dart
await AppLogger().shareLogs();
```

### Open log file in external app:

```dart
await AppLogger().openLogExternally();
```

## 🧹 Cleanup Tools
### Delete all .log files:

```dart
await AppLogger().clearLogFiles();
```

### Keep latest .log only, delete older ones:

```dart
await AppLogger().clearOldLogFiles();
```

### Auto-clean logs if total size exceeds 10MB:

```dart
await AppLogger().clearLogsIfExceedsLimit(maxSizeBytes: 10 * 1024 * 1024);
```
-- Call this after initializing the logger to manage disk space proactively.

## 🧪 Debug Tips
```
- Always call initialize() before logging.

- Use real device for testing file open/share.

- openLogExternally() uses open_filex — ensure the device has an app that supports .log or .txt.
```