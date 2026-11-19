<div align="center">

<!-- HERO BANNER -->
<img src="https://github.com/user-attachments/assets/2d0ab4f0-7633-4059-9043-d5f514aec07c" alt="I.G.I. 2: Covert Strike Cover Art" width="260" />

# 🎯 I.G.I. 2: Covert Strike
### **Native Android Engine Port (`ARM64` · `.NET 10` · `Vulkan 1.1` · `OpenAL Soft`)**

<p>
  <a href="https://github.com/rayishere0"><img src="https://img.shields.io/badge/Author-@rayishere0-181717?style=for-the-badge&logo=github" alt="Author" /></a>
  <img src="https://img.shields.io/badge/Platform-Android%207.0%2B%20(ARM64)-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/Runtime-.NET%2010.0%20CoreCLR-512BD4?style=for-the-badge&logo=dotnet&logoColor=white" alt="Runtime" />
  <img src="https://img.shields.io/badge/Graphics-Vulkan%201.1-AC162C?style=for-the-badge&logo=vulkan&logoColor=white" alt="Graphics" />
  <img src="https://img.shields.io/badge/Audio-OpenAL%20Soft%201.23.1-00599C?style=for-the-badge" alt="Audio" />
</p>

<p>
  <i>A ground-up, high-performance native Android port of Innerloop Studios' classic 2003 tactical stealth first-person shooter.</i><br/>
  <b>Zero emulation. Zero translation layers. Pure native ARM64 execution.</b>
</p>

---

[Gameplay Showcase](#-gameplay-showcase) •
[How to Play](#-how-to-play-user-guide) •
[Features](#-key-features--build-highlights) •
[Architecture](#-engine-architecture) •
[Project Layout](#-repository-structure) •
[Build from Source](#-building-from-source) •
[Portfolio](#-author--portfolio)

</div>

<br/>

## 📸 Gameplay Showcase

> *Authentic retail campaign missions, QVM menus, lightmaps, and tactical AI running natively on Android hardware.*

<div align="center">
  <table>
    <tr>
      <td align="center" width="50%">
        <img src="https://github.com/user-attachments/assets/492a7dec-3c93-413b-a56c-0db176361919" alt="Gameplay Screenshot 1" width="100%" /><br/>
        <sub><b>Tactical Combat & Stealth</b> — Native Vulkan 1.1 rendering</sub>
      </td>
      <td align="center" width="50%">
        <img src="https://github.com/user-attachments/assets/7d66cbf5-bcf4-4c42-9a0e-b3f16c4f9af4" alt="Gameplay Screenshot 2" width="100%" /><br/>
        <sub><b>Authentic Retail Visuals</b> — Baked lightmaps & weapon ballistics</sub>
      </td>
    </tr>
    <tr>
      <td align="center" colspan="2">
        <img src="https://github.com/user-attachments/assets/a80669ba-c432-4825-8b4f-bc6ae4abebbf" alt="Gameplay Screenshot 3" width="65%" /><br/>
        <sub><b>Full Campaign & QVM Interface</b> — All 19 missions running natively on ARM64</sub>
      </td>
    </tr>
  </table>
</div>

<br/>

## 🎮 How to Play (User Guide)

> [!IMPORTANT]
> **Copyright Compliance:** This repository and its compiled APK contain **no copyrighted game assets**. You must supply your own legal retail PC copy of *I.G.I. 2: Covert Strike* to play.

1. **Install the APK** on an **ARM64** Android device running **Android 7.0 (Nougat)** or newer.
2. **Transfer Your Game Data** from your PC installation to your phone's storage (e.g., `/sdcard/Download/IGI 2/`).
   - Ensure you copy the **`pc` directory** containing `igi2.exe` alongside the original game folders:
     ```text
     pc/
     ├── igi2.exe
     ├── config.qvm
     ├── common/
     ├── language/
     ├── menusystem/
     └── missions/
     ```
3. **Launch `I.G.I. 2`** (`com.projectigi2.app`) on your Android device.
4. On the launcher splash screen, tap **`SELECT GAME FOLDER`** and pick your copied `pc` folder via Android's Storage Access Framework (SAF) picker.
5. Wait for the automatic file-structure verification to complete, then tap **`PLAY`**.

<br/>

## ✨ Key Features & Build Highlights

| Category | Highlight | Details |
| :--- | :--- | :--- |
| **🚀 Native Runtime** | **Embedded .NET 10 CoreCLR** | Runs C# engine & game assemblies directly on ARM64 via JNI without Mono overhead or x86 translation. |
| **🎨 Graphics** | **Vulkan 1.1 Pipeline** | Low-overhead `ANativeWindow` surface rendering, baked lightmaps, 2D sprite batching, and strict **30 FPS target pacing** for smooth, thermals-friendly mobile play. |
| **🔊 Spatial Audio** | **OpenAL Soft 1.23.1** | Compiled natively with the `OpenSL ES` backend for directional footsteps, alarms, weapon acoustics, and environmental reverb. |
| **🕹️ Touch Controls** | **Customizable Multi-Touch HUD** | Dual-stick movement/aim, scope, reload, weapon wheel, and **stepped stance buttons** (*Stand ↔ Crouch ↔ Prone*) with drag-to-reposition layout customization. |
| **🎬 Cinematics** | **Smart Cutscene Handling** | Auto-pauses background music during dialogue; includes an interactive **hold-to-skip** ring for mid-mission cutscenes while letting end-of-mission cinematics play cleanly. |
| **⚙️ Built-in Cheats** | **On-Demand Trainer Modal** | Accessible via a subtle gear icon on the main menu: **Infinite Health** (immune to bullets, falls, explosions, electric fences), **Infinite Ammo**, and **All Weapons**. |
| **⏸️ Simulation** | **Instant State Freeze** | Interactive Pause (`||`) halts AI ticks, physics, and level updates immediately. |

<br/>

## 🏗️ Engine Architecture

This project combines a minimal Java/C++ Android native host with a modular C# game engine running inside an embedded **.NET 10.0 CoreCLR** runtime.

```mermaid
flowchart TD
    A["📱 Android Application<br/>(MainActivity.java · SurfaceView · SAF Picker)"] -->|JNI ANativeWindow & Input| B["⚙️ Native C++ Bridge<br/>(libprojectigi.so · jni_bridge.cpp)"]
    B -->|coreclr_initialize & Delegates| C["🟣 Embedded .NET 10.0 ARM64 Runtime<br/>(ProjectIGI.Android.dll)"]
    C --> D["🎨 Vulkan 1.1 Renderer<br/>(ProjectIGI.Rendering.Vulkan)"]
    C --> E["🔊 OpenAL Soft 3D Audio<br/>(libopenal.so via OpenSL ES)"]
    C --> F["🧠 I.G.I. 2 Game & AI Core<br/>(ProjectIGI.Game.Igi2)"]
    C --> G["🖥️ Retail QVM Virtual Machine<br/>(ProjectIGI.Presentation.Igi2)"]
