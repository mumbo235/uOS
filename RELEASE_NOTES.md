# uOS 3.2

**made by jarvo and deepseek**

A desktop-style operating system that lives in a single HTML file. No build step, no
dependencies, no installs, no accounts — just open it.

## New in 3.2

- **Session restore + window memory** — reopen uOS and your apps come back, each where
  and how big you left it (maximised state included). Toggle in Settings → Windows.
- **Command palette** — **Ctrl+K** searches apps, files, settings sections and commands.
  Type, arrow, Enter. Everything is one keystroke away.
- **Virtual desktops** — four desktops with a pager in the taskbar. Ctrl+Alt+1–4 or
  Ctrl+Alt+arrows switch; add Shift to send the active window across.
- **Snap layouts** — drag a window to the top edge and pick a zone (halves, thirds,
  quarters, main+side). Hover to preview, release to snap.
- **User profiles** — separate files, settings, desktop, games and chips per person.
  Switch from the Start menu or Settings → Users; nothing is shared.
- **Open with… / default apps** — Files can open a file in any compatible app, and you
  can change which app owns each extension.
- **Notification actions** — toasts and the Action Center now carry buttons (the update
  notice can take you straight to the release).
- **Storage safety net** — a quota warning instead of a silent failed save, a storage
  breakdown in Settings, and one-click export of everything as JSON.
- **Touch mode** — bigger taskbar, buttons, icons and resize handles; enabled
  automatically on touch devices, toggle in Settings → Display.
- **AI privacy notice** — the Assistant states which service your prompts go to, and has
  a switch to stop sending anything at all.

## Also in 3.2

- **Arcade** — **28 games, built in**, including a play-money casino (Slots, Blackjack,
  Roulette, Video Poker, Higher or Lower) played for virtual chips only: nothing to buy,
  deposit or cash out.
- **HTML Viewer** (open, edit and run HTML locally with a sandboxed preview and
  fullscreen) and **My Apps** (your own shelf of single-file HTML apps, up to 64 MB).
- Tray menus with live Wi-Fi info, a volume mixer with per-app levels, and battery
  information with Battery saver / Balanced / Performance modes.
- Zoom & scale, more personalisation (corners, font, transparency, wallpaper fit and
  dimming), and an update checker that reads this repository's releases.

## New tools in 3.2

- **Sheets** — a spreadsheet with `=SUM`, `=AVERAGE`, `=MIN`, `=MAX`, `=COUNT`, ranges and
  ordinary arithmetic (`=A1+B2*2`), arrow-key navigation, CSV export and saving into Files.
- **Text Tools** — 29 converters in one window: case styles, Base64/URL/HTML encode and
  decode, JSON pretty/minify/validate, SHA-1/256/512 hashes, line tools (sort, dedupe,
  number, reverse), UUID and random generators, and counts with reading time.
- **System Info** — screen, cores, memory, touch points, language, timezone, real WebGL
  renderer, network estimates, battery and storage; copy the report or save it as .txt.
- **Colour Studio** — shades, tints, complementary/triadic/analogous harmonies, HSL and
  luminance, plus WCAG contrast checks; click any swatch to copy its hex.
- **Typing Test** — 30 random words, live WPM and accuracy, 60-second limit.
- **Flashcards** — decks you can add to, shuffle, study and score, with a best-run record.

## Highlights

- **33 apps** — Files, Notepad, Calculator, Terminal, Settings, Nova Browser, Paint,
  Music Studio, Clock/Timer, Task Manager, Colour Picker, QR Code, Password Generator,
  Calendar, Sticky Notes, Media Player, Code Editor, **HTML Viewer**, **My Apps**,
  **Arcade**, **Sheets**, **Text Tools**, **System Info**, **Colour Studio**,
  **Typing Test**, **Flashcards**, Photos, AI Assistant, Recycle Bin, Clipboard, Run,
  Widgets and About
- **Arcade** with 28 built-in games (including a play-money casino) and a proper menu —
  categories, search, best scores, chips
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
