# Triple Espresso - AGENTS.md

## Project Overview
macOS menu bar app that prevents your Mac from sleeping. Swift only. Based on [Caffeine](https://github.com/domzilla/Caffeine) (MIT).

## Tech Stack
- **Language**: Swift
- **UI Framework**: SwiftUI + AppKit (`NSStatusItem`, `NSHostingController`)
- **IDE**: Xcode
- **Platforms**: macOS 14.6+
- **Localization**: 13 languages (`src/TripleEspresso/Resources/*.lproj`): de, en, es, fr, it, ja, ko, nl, pt, pt-BR, ru, uk, zh-Hans
- **Dependencies**: none (no auto-updater yet)

## Build Commands
```bash
xcodebuild -project src/TripleEspresso.xcodeproj -scheme TripleEspresso -destination "platform=macOS" build
```

## Assets
Icons are generated, not hand-drawn. Edit the scripts and re-run them:
- Menu bar template icons: `swift scripts/make_icons.swift src/TripleEspresso/Resources/Assets.xcassets/<name>.imageset` (run once per output dir, then move active/inactive files into their imagesets)
- App icon: `swift scripts/make_app_icon.swift <layer.png> <flattened.png>` (layer goes in `Icon.icon/Assets/Espresso.png`, flattened is `assets/Icon.png`)

## Testing
No test targets exist yet. Sleep prevention can be checked by running the app, activating it, and watching `pmset -g assertions` for a single `PreventUserIdleDisplaySleep` assertion held by TripleEspresso.
