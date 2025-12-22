## ▶️ How to Run the Project (Local Development)

> ⚠️ **Important:** All commands must be run from the **project root** (where `pubspec.yaml` exists).

---

### 1️⃣ Clone the repository

Clone the source code and navigate to the project directory:

```bash
git clone <REPOSITORY_URL>
cd SimpleWeather
```

### 2️⃣ Setup Environment Variables

Create a local environment file from the example (This file should **NOT** be committed to git):

```bash
cp .env.example .env.local
```

### 3️⃣ Configure API Key

Open the newly created `.env.local` file and update it with your keys:

```env
WEATHER_API_KEY=YOUR_OPENWEATHER_API_KEY
ENV=dev
```

### 4️⃣ Run the Application

The project uses specific scripts to inject environment variables. Please use the command appropriate for your OS:

#### 🟢 Windows (PowerShell)

```powershell
.\scripts\run_dev.ps1
```

> **Execution Policy Error?**
> If script execution is blocked, run the following command once (Run as Administrator):
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

#### 🟢 Mac / Linux

Grant execution permission (required only once) and run the script:

```bash
chmod +x scripts/run_dev.sh
./scripts/run_dev.sh
```

---

### ❌ Do NOT run the project strictly via Flutter CLI

Please do **NOT** use the command below. The app will fail or crash because it lacks the environment variables provided by the launch scripts.

```bash
# Do NOT run this!
flutter run
```
