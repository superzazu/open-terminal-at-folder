# open-terminal-at-folder

Quickly opens the macOS Terminal at "current folder", which is:

- either the Finder's "insertion location" (the location where a new folder would be created if "New folder" was selected) if the Finder is the frontmost app
- or the active window's document path (if possible). Works with Sublime Text, VSCode, Terminal, and most document-based native apps.

Run with `swift run`, build & install with:

```sh
swift build -c release && sudo cp .build/release/open-terminal-at-folder /usr/local/bin
```

## Why ?

For years, I've had an AppleScript that did the same thing — which was triggered by a keyboard shortcut (using tools such as Hammerspoon or Raycast).
This project allows for a faster execution: ~0.32s -> ~0.0278sec (almost _12 times faster_).

## Development

During development, if there is a need to add more props to `FinderApplication.swift`, here is how the SDEF/header files can be generated:

```sh
sdef /System/Library/CoreServices/Finder.app > Finder.sdef
sdp -fh --basename Finder Finder.sdef
```
