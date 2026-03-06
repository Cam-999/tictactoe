# CLAUDE.md

## Overview

Single-file browser-based Tic Tac Toe game. No build step, no dependencies, no framework.

## Running the project

```
open tictactoe.html
```

Or open `tictactoe.html` directly in any browser.

## Architecture

`tictactoe.html` is entirely self-contained (HTML + CSS + JS in one file).

Key patterns:
- **Board state**: 9-element array representing the 3×3 grid
- **Win detection**: `WINS` array of 8 winning index combinations (3 rows, 3 columns, 2 diagonals)
- **Score tracking**: `{X, O, D}` object tracking wins for X, O, and draws
