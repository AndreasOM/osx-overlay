# Hack

Adds one or more transparent web views over the OSX desktop.

# TODO
[ ] Replace url as key for overlays by uuid
[ ] Allow removing of overlays
[ ] Allow (re)ordering of windows
[ ] Actually destroy web view when unticking in menu (?  Maybe just deactivate it?)
[ ] Do not store web view in overlay
[ ] Add (optional) auto disable timer to windows, e.g. for one-shot animations
[ ] Allow enable/disable via MIDI command

# DONE
[x] Add window to allow adding/editing URLs
[x] Added UUID to overlays
[x] Allow editing of overlay startup state
[x] Serialize overlay visibility, and use on next startup
[x] Set tick mark in menu based on enabled state
[x] Display UUID in config window (read only)
[x] Improved overlay config window
