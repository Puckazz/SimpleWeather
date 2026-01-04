# 🌤️ Weather App

A modern, feature-rich weather application built with Flutter that provides real-time weather information and forecasts for locations worldwide.

## ✨ Features

- 🌍 **Current Weather**: Get real-time weather data for any city or your current location
- 📅 **Hourly & Daily Forecasts**: View detailed hourly and 7-day weather forecasts
- 📍 **Location Services**: Automatic location detection with GPS support
- 🏙️ **Multi-City Management**: Save and manage multiple cities for quick access
- 🎨 **Beautiful UI**: Clean, modern interface with smooth animations
- 🌓 **Dark/Light Theme**: Automatic theme switching based on system preferences
- 🌡️ **Temperature Units**: Support for both Celsius and Fahrenheit
- 🔍 **City Search**: Smart city autocomplete with geocoding
- 🔄 **Pull to Refresh**: Easy data refresh with swipe gesture
- 💾 **Offline Support**: Cached data for offline access

## 🛠️ Tech Stack

- **Framework**: Flutter 3.10.1+
- **State Management**: Provider
- **API**: OpenWeatherMap API
- **Architecture**: Clean Architecture (Domain/Data/Presentation layers)
- **Dependency Injection**: get_it
- **Local Storage**: shared_preferences
- **Location Services**: geolocator & geocoding
- **Environment Config**: flutter_dotenv

---

## ▶️ How to Run the Project (Local Development)

> ⚠️ **Important:** All commands must be run from the **project root** (where `pubspec.yaml` exists).

---

### 1️⃣ Prerequisites

- Flutter SDK 3.10.1 or higher
- Dart SDK 3.10.1 or higher
- OpenWeatherMap API Key ([Get it here](https://openweathermap.org/api))

### 2️⃣ Clone the Repository

Clone the source code and navigate to the project directory:

```bash
git clone <REPOSITORY_URL>
cd SimpleWeather
```

### 3️⃣ Install Dependencies

Install all required Flutter packages:

```bash
flutter pub get
```

### 4️⃣ Setup Environment Variables

Create a local environment file from the example (This file should **NOT** be committed to git):

**On Windows (PowerShell):**
```powershell
Copy-Item .env.example .env.local
```

**On Mac/Linux:**
```bash
cp .env.example .env.local
```

### 5️⃣ Configure API Key

Open the newly created `.env.local` file and update it with your OpenWeatherMap API key:

```env
WEATHER_API_KEY=YOUR_OPENWEATHER_API_KEY_HERE
ENV=dev
```

> 💡 **How to get an API Key:**
> 1. Visit [OpenWeatherMap](https://openweathermap.org/api)
> 2. Sign up for a free account
> 3. Go to API Keys section
> 4. Copy your API key and paste it in `.env.local`

### 6️⃣ Run the Application

Simply run the app using Flutter CLI:

```bash
flutter run
```

Or select a specific device:

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

---

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

---

## 🏗️ Project Structure

```
lib/
├── config/           # App configuration & theme
├── core/            # Core utilities, API service, helpers
├── data/            # Data layer (models, repositories, data sources)
├── domain/          # Domain layer (entities, use cases)
├── presentation/    # UI layer (pages, widgets, controllers)
│   ├── controllers/ # State management controllers
│   ├── pages/      # Screen pages
│   └── widgets/    # Reusable UI components
├── injection_container.dart  # Dependency injection setup
└── main.dart       # App entry point
```

---

## 🔧 Build for Production

### Android APK
```bash
flutter build apk --release
```

### iOS App
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

---

## 📄 License

This project is open source and available under the MIT License.

---

## 👨‍💻 Developer

Built with ❤️ using Flutter

---

## 📞 Support

If you encounter any issues or have questions, please open an issue on GitHub.
