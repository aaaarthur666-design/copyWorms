class_name UILayerContract
extends RefCounted


## CanvasLayer contract shared by every formal level and global overlay.
const WORLD: int = 0
const LEVEL_UI: int = 100
const LEVEL_ALERT: int = 700
const SHARED_HUD: int = 800
const LEVEL45_SPECIAL_FX: int = 900
const TRANSITION: int = 1000
const CINEMATIC: int = 2000

## Local z-order inside the shared HUD CanvasLayer.
const HUD_GAMEPLAY_Z: int = 0
const HUD_GAMEOVER_Z: int = 900
const HUD_PAUSE_Z: int = 1000
const HUD_PAUSE_DIALOG_Z: int = 1100
