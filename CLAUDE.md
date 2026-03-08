# CLAUDE.md

## Projects in this repo

### Tic Tac Toe
- File: `tictactoe.html` — single-file browser game, no build step
- Open with `open tictactoe.html`

### Tower Defense (HTML)
- File: `New app html/TowerDefense.html` — single-file browser game, no build step
- Open directly in any browser
- 14 enemy types, 39 tiered upgrades, Web Audio sound effects, 100 waves

### App Icon
- File: `AppIcon.html` — SVG tower defense icon, open in browser to view/export

## iOS Xcode App (separate location)
- Path: `/Users/cameron999/Documents/TestAPPXCODE/TowerDefense/`
- SpriteKit + SwiftUI, medieval-themed tower defense game
- Full architecture in Claude memory: `tower-defense.md`

#### Medieval Theme
- All UI text uses medieval language (Gold, Stronghold, Ye Olde Shoppe, etc.)
- 8 tower types: Archer, Catapult, Wizard, Barracks, Alchemist, Bell Tower, Ballista, Moat
- Moat is a path-placed trap that passively slows enemies (not a shooting tower)

#### Pixel Art Sprites
- **Archer tower**: 4 tier sprites (`ArcherTower0`–`ArcherTower3`), swapped on upgrade
- **Wizard tower**: 4 tier sprites (`WizardTower0`–`WizardTower3`), swapped on upgrade
- **Moat tower**: Pond sprite (`MoatTower`), placed on path cells
- **Arrow projectile**: Pixel art sprite (`ArrowProjectile`)
- **Goblin enemy**: Animated side-walk (21 frames) + front-walk (30 frames) sprite atlases
- **Orc enemy**: Animated side-walk (30 frames) + front-walk (30 frames) sprite atlases
- All sprites use `.nearest` filtering for crisp pixel art

#### Maps
- 3 maps: King's Road (default), Castle Courtyard, Forest Trail
- Castle Courtyard: enters top-right, snake pattern, exits bottom-right
- Map selection on main menu

## GitHub
- Remote: https://github.com/Cam-999/tictactoe (branch: main)

## Mobile Game Development Guidelines

### Platform Considerations
| Constraint | Strategy |
|------------|----------|
| **Touch input** | Large hit areas, gestures |
| **Battery** | Limit CPU/GPU usage |
| **Thermal** | Throttle when hot |
| **Screen size** | Responsive UI |
| **Interruptions** | Pause on background |

### Touch Input
- Minimum touch target: 44x44 points
- Visual feedback on touch
- Avoid precise timing requirements
- Support both portrait and landscape
- Touch is imprecise and occludes screen — design accordingly

### Performance Targets
- 30 FPS often sufficient for mobile
- Sleep when paused
- Minimize GPS/network
- Dark mode saves OLED battery
- Reduce quality when device is warm, limit FPS when hot, pause effects at critical temp

### App Store Requirements
- **iOS:** Privacy labels required, account deletion if account creation exists, screenshots for all device sizes
- **Android:** Target current year's SDK, 64-bit required, app bundles recommended

### Monetization Models
| Model | Best For |
|-------|----------|
| **Premium** | Quality games, loyal audience |
| **Free + IAP** | Casual, progression-based |
| **Ads** | Hyper-casual, high volume |
| **Subscription** | Content updates, multiplayer |

### Anti-Patterns
- Don't use desktop controls on mobile — design for touch
- Don't ignore battery drain — monitor thermals
- Don't force landscape — support player preference
- Don't require always-on network — cache and sync
