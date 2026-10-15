# uOS — a web operating system in one file

**made by jarvo and deepseek**

uOS is a desktop-style operating system that runs entirely inside a single HTML file.
No build step, no dependencies, no installs, no accounts. Open `uOS.html` and you're in.

## Features

- **Window manager** — drag, resize, minimise, maximise, edge-snapping, Alt+Tab switcher
- **Desktop** — draggable icons that snap to a grid and never overlap, marquee select,
  right-click menu (new folder / text document / sticky note / widgets)
- **Taskbar** — pinned + running apps, search, Task View, system tray, clock, show-desktop
- **Start menu** — searches apps, files and settings
- **Widgets** — clock, calendar, quick notes, to-do, system stats, quick actions, Ask AI
- **Sticky notes** that live on the desktop
- **Full settings app** — themes, accents, wallpapers + custom upload, slideshow, night light,
  compact mode, high contrast, taskbar placement, clock format, notifications, power, backup
- **Optional first-run tour** you can skip and replay
- **Splash text** on boot and lock screen
- **Recycle Bin**, **Clipboard history**, **Run dialog**, **lock screen with PIN**

## Apps

Files · Notepad · Calculator · Terminal · Settings · Nova Browser · Paint · Music Studio ·
Clock/Timer · Task Manager · Colour Picker · QR Code · Password Generator · Calendar ·
Sticky Notes · Media Player · Code Editor · Photos · AI Assistant · Recycle Bin ·
Clipboard · Run · Widgets · About

## Keyboard shortcuts

| Shortcut | Action |
|---|---|
| `Alt + Tab` | Switch windows |
| `Ctrl + Alt + T` | Terminal |
| `Ctrl + Alt + A` | AI Assistant |
| `Ctrl + Alt + S` | Settings |
| `Ctrl + Alt + C` | Clipboard |
| `Ctrl + Alt + R` | Run dialog |
| `Ctrl + Alt + L` | Lock screen |
| `Esc` | Close menus |

## Running it

Open `uOS.html` in any modern browser. To serve it instead:

```bash
python3 -m http.server 8000
# then visit http://localhost:8000/uOS.html
```

## Publishing a release

```bash
bash publish.sh <your-username>/uOS
```

Pushes `main`, tags `v<UOS_VERSION>`, creates the GitHub release from
`RELEASE_NOTES.md` and uploads a freshly built `uos-<UOS_VERSION>.zip`. The version is
read straight out of `uOS.html`, so **bump `UOS_VERSION` there to ship a new version** —
it tags and names everything from that one line. Re-running it is safe: it updates the
existing release and replaces the asset instead of failing.

**One-time setup so it never asks for a token again** — pick your platform:

```bash
git config --global credential.helper store        # Linux (plaintext in ~/.git-credentials)
git config --global credential.helper osxkeychain  # macOS (Keychain)
```

Run the script once and paste the token when asked; it is remembered and
`bash publish.sh <user>/uOS` needs no token after that.

## Notes

- Everything is stored in your browser's `localStorage` — files, notes, widgets, settings.
- Settings → About & backup can **export / import** a full backup as JSON.
- The AI Assistant works **without an API key** by default; you can point it at your own
  OpenAI-compatible provider in its settings.
