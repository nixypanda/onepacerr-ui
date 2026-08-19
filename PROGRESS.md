# OnePacerr Elm UI - Progress Summary

## Project Overview

**Goal**: Build an informational Elm UI dashboard for OnePacerr (One Pace episode manager) that consumes the OnePacerr REST API and displays pipeline status, episode progress, and configuration in a clean, dark-mode interface.

**Initial Instructions:**
1. Check the docs of OnePacerr project
2. Check 4 JSON files as reference (healthz, status-metadata, status-pipeline, status-pipeline-report)
3. Make a UI using Elm that works with OnePacerr API
4. UI should be informational and leverage API data for easy understanding
5. Test via SSH tunnel to nixypanda@srt-n01-rivendell
6. Use structuring patterns from ../Calco (elm-ui, Store pattern with RequestToken, pane reconciliation)
7. Apply "parse don't evaluate" and "make invalid state unrepresentable" patterns
8. Use elm-ui for styling
8. Clarify doubts upfront
9. Expect a detailed plan any agent can follow

**User Clarifications Received:**
1. No auth required for API
2. WebSocket is internal only (OnePacerr → one-pace-api), use polling instead
3. Read-only informational UI (no control actions)
4. No episode filtering needed
5. Magnet links → copy to clipboard
6. No poster artwork needed
7. Only latest pipeline report matters
8. Keep it simple - single dashboard page preferred

## Completed

### Project Setup
- `elm.json` - Dependencies configured (elm-ui 1.1.8, NoRedInk/elm-json-decode-pipeline)
- `package.json` - Vite + elm-tooling + vite-plugin-elm
- `vite.config.js` - Dev server with `/api` proxy to `localhost:8080`
- `index.html` - Basic HTML shell
- `src/main.js` - Elm app initialization with copy-to-clipboard port

### Data Models (`src/Data/`)
- `Pipeline.elm` - All domain types (PipelineStatus, ArcStatus, PipelineConfig, PipelineReport, MonitoredArc, Episode, EpisodeFiles, FileInfo, ArchivedFile)
- `Health.elm` - Health check types
- `Metadata.elm` - Metadata config types

### JSON Decoders (`src/Lib/Json.elm`)
- Complete decoders for all 4 API endpoints using Json.Decode.Pipeline
- Custom decoders for enums (PipelineStatus, ArcStatus) and Posix timestamps

### Date Utilities (`src/Lib/Date.elm`)
- formatDateTime, formatRelative, formatDuration helpers

### API Layer (`src/Api/`)
- `Client.elm` - HTTP client with ApiError type
- `Endpoints.elm` - 4 endpoint functions (health, metadata, pipeline config, pipeline report)

### Store (`src/Store.elm`)
- Loadable pattern (NotAsked | Loading | Failure | Success)
- 30-second polling for all 4 endpoints
- Proper Msg types for each endpoint response

### UI Theme (`src/Ui/`)
- `DesignTokens.elm` - Colors, spacing
- `Theme.elm` - Complete theme with card, badge, toggle components using rgb255

### View Components (`src/View/Components.elm`)
- statCard, pipelineStatusBadge, arcStatusBadge
- configToggle (animated switch)
- arcSection (expandable arc with episodes)
- episodeRow, fileBadge, archivedFileBadge
- progressBar, errorBanner, loadingSpinner, emptyState
- clickable, copyButton using Input.button

### Dashboard View (`src/View/Dashboard.elm`)
- Single-page layout with stats row, progress bar, config toggles, expandable arcs
- ArcState dictionary for tracking expanded/collapsed arcs

### Layout (`src/View/Layout.elm`)
- App header with title, subtitle, health indicator
- Main content area

### Main (`src/Main.elm`)
- Browser.element with flags
- Port for copy-to-clipboard
- Subscriptions for polling

---

## Build Failures (Elm 0.19.1 + elm-ui 1.1.8 API Mismatches)

### 1. Element.el Second Argument
**Problem**: `Element.el attrs children` expects `children : Element msg`, not `List (Element msg)`
**Current**: `Element.el attrs (Element.column [] children)` 
**Need**: Single Element child (use `Element.column attrs children` directly)

### 2. Input.button Label Type
**Problem**: `Input.button` label must be `Element msg`, but `Element.text "📋"` produces `Element String`
**Need**: Type annotation issue - copyButton should work but compiler sees String

### 3. Column/Row API
**Problem**: `Element.column` and `Element.row` first argument must be `List (Element.Attribute msg)`, not `List (Element msg)`
**Current**: `Element.column (List.map ...)` 
**Need**: `Element.column [ Element.spacing 8 ] (List.map ...)`

### 4. Element.el for Spacer
**Problem**: `Element.el [ Element.width Element.fill ] []` expects `Element msg` as second arg
**Need**: Use `Element.none` or proper spacer element

### 5. Http API
**Problem**: `Http.send` doesn't exist in this Elm version, `Http.get` record fields differ
**Working**: `Http.get { url, expect }` without timeout field

---

## Files Needing Fixes

| File | Issues |
|------|--------|
| `src/View/Components.elm` | Element.el usage, column/row attrs, Input.button label type, clickable implementation |
| `src/View/Layout.elm` | Element.el spacer, row/column attrs |
| `src/View/Dashboard.elm` | column/row attrs |

---

## Next Steps

1. **Rewrite View Components** using correct elm-ui 1.1.8 API:
   - Replace `Element.el attrs (Element.column [] children)` with `Element.column attrs children`
   - Replace `Element.row`/`Element.column` with proper attribute lists
   - Fix `Input.button` label to use `Element.text` with proper type
   - Replace spacer `Element.el` with `Element.none` or `Element.spacer`

2. **Test incrementally** - build after each component fix

3. **SSH Tunnel Testing** once build succeeds:
   ```bash
   ssh -L 8080:localhost:3000 nixypanda@srt-n01-rivendell
   npm run dev
   ```

4. **Verify with real data** from the 4 JSON endpoints