# uOS 3.1

**made by jarvo and deepseek**

A desktop-style operating system that lives in a single HTML file. No build step, no
dependencies, no installs, no accounts — just open it.

## New in 3.1

- **Arcade** — **17 games, built in**: Snake, Block Drop (Tetris), Brick Breaker,
  Paddle Duel, Invaders, Asteroids, Jumper, Dodger, Tower, Whack-a-mole, Reaction,
  2048, Minesweeper, Memory, Simon, Tic-tac-toe and Word Guess. Browsable menu with
  categories, search, best scores and play counts — all saved locally.
- **HTML Viewer** — open, edit and run HTML locally: source on the left, live sandboxed
  preview on the right, with **⛶ Fullscreen** (Ctrl+Shift+F, Esc to exit). Opens any
  local `.html` file at any size, saves back to uOS, downloads, or opens in a real tab.
- **My Apps** — your own shelf of single-file HTML apps. Small ones live in the uOS file
  system; anything **up to 64 MB** goes to an IndexedDB vault, so big pages work too.
- **Tray menus** — click the network, volume or battery icon: live Wi-Fi info with a
  connection test, a volume mixer with **per-app** levels, and battery info with
  **Battery saver / Balanced / Performance** modes.
- **Zoom & scale** — scale the whole interface 60–160% (Ctrl+Alt+= / − / 0), plus taskbar
  height; everything is scale-aware so windows, icons and menus stay put.
- **More personalisation** — window corners, interface font, transparency, acrylic,
  wallpaper fit and dimming, profile avatar.
- **Updates** — uOS now checks its GitHub releases and tells you when a newer version is
  out (Settings → *About & backup* → Updates).
- Terminal and AI Assistant are pinned to the taskbar by default; the taskbar tray got a
  cleaner look; the centred taskbar now stays at the bottom.

## Highlights

- **27 apps** — Files, Notepad, Calculator, Terminal, Settings, Nova Browser, Paint,
  Music Studio, Clock/Timer, Task Manager, Colour Picker, QR Code, Password Generator,
  Calendar, Sticky Notes, Media Player, Code Editor, **HTML Viewer**, **My Apps**,
  **Arcade**, Photos, AI Assistant, Recycle Bin, Clipboard, Run, Widgets and About
- **Arcade** with 17 built-in games and a proper menu — categories, search, best scores
- **Window manager** with drag, resize, minimise/maximise, edge-snapping and an Alt+Tab
  switcher
- **Desktop** with grid-snapping icons that never overlap, marquee selection and a
  right-click menu (new folder / text document / sticky note / widgets)
- **Widgets** — clock, calendar, quick notes, to-do list, system stats, quick actions and
  an **Ask AI** card, all draggable and persistent
- **Settings** with themes, accents, wallpapers + custom upload, slideshow, night light,
  compact mode, high contrast, taskbar placement, clock format, notifications, power
  options and a full backup export/import
- **AI Assistant** that works with **no API key** out of the box, and can be pointed at
  your own provider (OpenRouter, Groq, Gemini, Ollama, OpenAI-compatible)
- **Optional first-run tour** — skippable, replayable
- **Splash text** on boot and the lock screen
- **Recycle Bin**, **clipboard history**, **Run dialog** and a **lock screen with PIN**

## Notes

- Everything is stored in your browser — settings and files in `localStorage`, and large
  app files in `IndexedDB`. Nothing is uploaded anywhere.
- Settings → *About & backup* exports/imports everything as JSON.

## Install

Download `uOS.html` and open it in a browser. That's it.
