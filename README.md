<div align="center">

<a href="https://skillicons.dev"> <img src="https://skillicons.dev/icons?i=discord" /></a>
# Discord Optimizer 
A Windows batch script to optimize the Discord client by removing unnecessary files, clearing caches, and adjusting settings for better performance.

</div>

**Original script by [rifteyy](https://github.com/rifteyy/discordoptimizer).\
Modified and enhanced by [Salc-wm](https://github.com/Salc-wm).**

---

> [!IMPORTANT]  
> This script provides a simple, menu-driven interface to apply various optimizations to your Discord installation.\
> It is designed to help reduce Discord's resource footprint, free up disk space, and potentially improve its responsiveness.

---

## ✨ Features

The script offers a range of optimization options, which can be applied individually:

1. 🧹 **Debloat**: Removes non-essential modules from the Discord application directory.
2. 🗑️ **Clear Unused Languages**: Deletes all language files except for English (`en-US`) and Portuguese (`pt-BR`).
3. 📋 **Clear Logs & Reports**: Wipes log files, old installation packages, and crash reports.
4. ⚡ **Optimize Priority**: Allows you to set Discord's CPU priority (Low, High, or Normal).
5. 📦 **Clear Old Versions**: Scans for and removes outdated Discord application versions.
6. 💨 **Clear Cache**: Deletes cached data, including the main cache, GPU cache, and code cache.
7. 🚫 **Disable Start-Up**: Removes Discord from the list of applications that run automatically at login.
8. 🔄 **Restart Discord**: Safely terminates and restarts the Discord client.

---

## 🛠️ How to Use

1.  **Download:** Get the `discordTweaks.bat` file from this repository.
2.  **Run:** Simply double-click the file to execute it.
    * *Note:* The script may require administrative privileges for certain operations.
3.  **Select Discord Version:** The script will automatically detect installed Discord versions (e.g., Stable, PTB, Canary). Choose the one you want to optimize.
4.  **Choose an Option:** Use the menu to select the desired optimization. You can apply multiple optimizations by running the script again.

---

## 📜 Script Breakdown

#### **Initial Setup & Logging**
* `@echo off` & `setlocal`: These commands start the script cleanly, preventing commands from being displayed on the screen and keeping variable changes local to the script.
* **Debug Logger**: A log file (`discord_optimizer_debug.txt`) is created in the same directory as the script. It captures all output and potential errors, which is useful for debugging.

#### **Main Logic (`:main`)**
* `title Discord Optimizer`: Sets the title of the command prompt window.
* `chcp 65001`: Changes the active code page to UTF-8 to ensure special characters and the logo display correctly.
* **UI Setup**: It defines variables for colors and special characters (`ESC`, `C1`, `BRK`, `SEP`) to create a more polished, colored interface.
* **Version Detection**:
    * `cd /d "!appdata!"`: Navigates to the `%APPDATA%` directory.
    * `for /f "delims=" %%a in ('dir /b "Discord*"')`: It searches for all directories starting with "Discord" and lists them as selectable options.

#### **Menu System (`:menu`)**
* This section displays the main menu of available optimizations.
* It waits for the user to input a number corresponding to an action.
* `goto action_%num%`: Based on the user's input, the script jumps to the corresponding action block (e.g., `action_1` for Debloat).

#### **Core Functions (Actions)**
Each function is a self-contained block of code that performs a specific optimization task.

* **:debloat**: Terminates Discord and removes non-essential modules from the application directory.
* **:languages**: Navigates to the `locales` folder and deletes all language packs except for English and Portuguese.
* **:log**: Uses a helper function `:safe_del` to delete `.log` files, `.nupkg` packages, and `.dmp` crash reports.
* **:optpriority**: Presents a sub-menu to change Discord's CPU priority by modifying the Windows Registry (`reg add`) and applying it to the live process (`wmic`).
* **:oldapp**: Scans for and deletes outdated `app-*` directories, keeping only the current version.
* **:cache**: Kills the Discord process and deletes the contents of the `Cache`, `GPUCache`, and `Code Cache` folders.
* **:action_7 (Disable Start-Up)**: Uses `reg.exe delete` to remove the registry key that makes Discord run on system startup.
* **:action_8 (Restart Discord)**: Forcefully closes Discord (`taskkill`) and restarts it using `Update.exe`.

#### **Helper Functions**
* **:logo**: Contains the ASCII art for the "DISCORD Optimizer" logo and uses `:echo-align` to center it.
* **:echo-align**: A utility function (by hXR16F) that calculates padding to print centered text in the console.
* **:cleanup_and_exit**: A simple function to restore the environment (`endlocal`) and exit the script.


## Future Features
- [ ] Dynamic Language Selection:
  - [ ] Allow users to choose which language(s) to keep through an interactive menu, instead of the current hardcoded selection.

- [ ] Advanced Priority Control:
  - [ ] Offer more granular CPU priority levels (e.g., Below Normal, Above Normal).
  - [ ] Add an option to manage I/O priority to further reduce disk usage during games.

- [ ] Client & Mod Manager:
  - [ ] Discord Installer: Add a feature to download and install official Discord clients (Stable, PTB, Canary) directly.
  - [ ] Mod Installer: Integrate an installer for popular client mods like Vencord or BetterDiscord.
  - [ ] Mod Updater/Repairer: Add functionality to update or repair mod installations.
