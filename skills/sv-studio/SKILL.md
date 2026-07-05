---
name: sv-studio
description: Control Synthesizer V Studio 2 Pro via the eval-client.mjs CLI. Use when the user asks to modify, inspect, or create tracks, notes, lyrics, pitch, vibrato, or any other SV Studio project data. 
---

# SV Studio Scripting via eval-client.mjs

## Overview

Synthesizer V Studio is controlled remotely via `eval-client.mjs` (symlinked in this skill directory to the root script), a CLI that sends Lua code to an EvalServer running inside SV Studio and returns results.

```bash
node ./eval-client.mjs -c 'lua code here'
node ./eval-client.mjs -f script.lua
node ./eval-client.mjs --stdin      # read code from stdin
node ./eval-client.mjs --ping       # check server alive
node ./eval-client.mjs --status     # server info
```

**Key point**: All Lua code runs inside SV Studio's Lua 5.4 environment with the `SV` global object as the single entry point.

## Reference Files

| File | Purpose | When to read |
|------|---------|-------------|
| `./references/SV.md` | Host object, blick conversion helpers, object factory (`SV:create`), `SV:getPlayback()` | Entry point for all scripting |
| `./references/Project.md` | `getTrack()`, `getNumTracks()`, `addTrack()`, `getTimeAxis()` | Project structure |
| `./references/Track.md` | `getName()`, `setName()`, `getGroupReference()`, `getMixer()` | Track operations |
| `./references/NoteGroup.md` | `getNote()`, `getNumNotes()`, `addNote()`, `removeNote()`, `getAutomation()` | Note container — re-sorting on mutation |
| `./references/Note.md` | `getLyrics()`, `setLyrics()`, `getPitch()`, `setPitch()`, `getAttributes()`, `setAttributes()`, `setTimeRange()` | Per-note properties |
| `./references/NoteGroupReference.md` | `getVoice()`, `setVoice()`, `getTimeOffset()`, `setTimeOffset()`, `getPitchOffset()`, `setPitchOffset()`, `isMain()` | Group-level defaults |
| `./references/Automation.md` | `getPoint()`, `addPoint()`, `removePoint()`, `getParamType()` | Parameter automation (pitch deviation, etc.) |
| `./references/PitchControlCurve.md` | `getPoint()`, `addPoint()`, `removePoint()`, time-range pitch override | Pitch bend curves |
| `./references/TrackMixer.md` | `getGain()`, `setGain()`, `getPan()`, `setPan()`, `getMuted()`, `setMuted()`, `getSolo()`, `setSolo()` | Volume, pan, mute, solo |
| `./references/TimeAxis.md` | `getTempoMarkAt()`, `getMeasureMarkAt()`, `getBlickFromSeconds()`, `getSecondsFromBlick()` | Tempo, time signature, time conversion |
| `./references/PlaybackControl.md` | `play()`, `stop()`, `pause()`, `seek(seconds)`, `loop()`, `getPlayhead()`, `getStatus()` | Playback control |
| `./references/RetakeList.md` | Retake variations for note rendering | Retakes |
| `./references/ScriptableNestedObject.md` | `getScriptData()`, `setScriptData()`, `clearScriptData()` | Persistent script storage |
| `./references/NestedObject.md` | `getParent()`, `getIndexInParent()` | Base class — tree navigation |
| `./references/MainEditorView.md` | Piano roll UI state | UI scripting |
| `./references/ArrangementView.md` | Arrangement view UI state | UI scripting |
| `./references/CoordinateSystem.md` | Scrollable area navigation (time×value) | UI coordinate mapping |
| `./references/WidgetValue.md` | Bind custom UI widgets to script variables | Custom dialogs |
| `./references/tutorial-*.md` | Minimal example, custom dialogs, side panels, localization, memory management | Getting started |
| `./references/index.md` | Official scripting manual index | Full API docs |
| `./SKILL.md` | This file | Workflows, patterns, pitfalls |

## Core Data Model

```
SV:getProject()
├── getTrack(i) → Track
│   └── getGroupReference(i) → NoteGroupReference
│       ├── getTarget() → NoteGroup
│       │   ├── getNote(j) → Note
│       │   └── getNumNotes()
│       ├── getVoice() / setVoice(attrs)   ← vibrato, tension, etc. (group-level defaults)
│       ├── getTimeOffset() / setTimeOffset()
│       └── getPitchOffset() / setPitchOffset()
│       └── isMain()  ← true for the track's main group
└── getNumTracks()
```

**Lua indexing is 1-based**. `project:getTrack(1)` gets the first track.

## Critical Pitfall: Note Re-sorting on Mutation

`NoteGroup` keeps notes sorted by onset position. Calling `note:setTimeRange()` or `note:setOnset()` triggers immediate re-sort, which means `group:getNote(i)` may return a **different note object** after the call.

### Strategy: Always process from last to first

```lua
-- BAD: forward iteration — notes shift after each mutation
for i = 1, numNotes do
    local note = group:getNote(i)
    note:setTimeRange(newOnset, newDuration)  -- re-sort happens, i+1 is now wrong
end

-- GOOD: backward iteration — earlier notes are untouched
for i = numNotes, 1, -1 do
    local note = group:getNote(i)
    note:setTimeRange(newOnset, newDuration)
end
```

### Strategy: Collect note objects before mutating

When you need to reference notes by their original index (e.g., matching main track to chorus track), collect all note objects into a table first:

```lua
local notes = {}
for i = 1, numNotes do
    notes[i] = group:getNote(i)  -- stable reference
end
-- now mutate freely using notes[i]
```

### Strategy: Read all data first, write second

Separate read and write phases completely:

```lua
-- Phase 1: Read
local data = {}
for i = 1, numNotes do
    local n = group:getNote(i)
    data[i] = { onset = n:getOnset(), duration = n:getDuration(), pitch = n:getPitch() }
end

-- Phase 2: Write (backward)
for i = numNotes, 1, -1 do
    local n = group:getNote(i)
    n:setTimeRange(data[i].onset * 2, data[i].duration * 2)
end
```

## Common Workflows

### 1. Explore the project

```lua
local project = SV:getProject()
local numTracks = project:getNumTracks()
for i = 1, numTracks do
    local track = project:getTrack(i)
    print("Track[" .. i .. "]: " .. track:getName())
    local numGroups = track:getNumGroups()
    for g = 1, numGroups do
        local ref = track:getGroupReference(g)
        local grp = ref:getTarget()
        print("  Group[" .. g .. "] main=" .. ref:isMain() .. " notes=" .. grp:getNumNotes())
    end
end
```

### 2. Read all notes from a track

```lua
local project = SV:getProject()
local track = project:getTrack(1)
-- Find the group with actual notes (main group may be empty)
local groupRef = track:getGroupReference(2)  -- or iterate to find non-empty
local group = groupRef:getTarget()
local numNotes = group:getNumNotes()

local notes = {}
for i = 1, numNotes do
    local note = group:getNote(i)
    local attrs = note:getAttributes()
    table.insert(notes, {
        lyrics = note:getLyrics(),
        pitch = note:getPitch(),
        onset = note:getOnset(),
        duration = note:getDuration(),
        dF0VbrMod = attrs.dF0VbrMod  -- vibrato modulation (nil = default)
    })
end
return notes
```

### 3. Modify note attributes (vibrato, phonemes, etc.)

```lua
-- Per-note vibrato modulation: 0.0 (none) to 1.0 (full default)
note:setAttributes({ dF0VbrMod = 0.5 })

-- Group-level defaults (applied to all notes without per-note override)
groupRef:setVoice({
    paramLoudness = 0,
    paramTension = 0,
    paramBreathiness = 0
})
```

### 4. Create a new track with notes from an existing track

```lua
local project = SV:getProject()

-- Read source
local srcGroupRef = project:getTrack(1):getGroupReference(2)
local srcGroup = srcGroupRef:getTarget()
local numNotes = srcGroup:getNumNotes()

-- Collect data
local noteData = {}
for i = 1, numNotes do
    local n = srcGroup:getNote(i)
    noteData[i] = {
        lyrics = n:getLyrics(),
        pitch = n:getPitch(),
        onset = n:getOnset(),
        duration = n:getDuration()
    }
end

-- Create new track
local newTrack = SV:create("Track")
newTrack:setName("Chorus")
local newGroupRef = newTrack:getGroupReference(1)
local newGroup = newGroupRef:getTarget()

-- Copy voice settings
newGroupRef:setVoice(srcGroupRef:getVoice())

-- Add notes (BACKWARD!)
for i = numNotes, 1, -1 do
    local newNote = SV:create("Note")
    newNote:setLyrics(noteData[i].lyrics)
    newNote:setPitch(noteData[i].pitch)
    newNote:setTimeRange(noteData[i].onset, noteData[i].duration)
    newGroup:addNote(newNote)
end

project:addTrack(newTrack)
```

### 5. Scale note durations and positions

```lua
local firstOnset = noteData[1].onset
for i = numNotes, 1, -1 do
    local note = group:getNote(i)
    local newOnset = firstOnset + (noteData[i].onset - firstOnset) * 2
    local newDuration = noteData[i].duration * 2
    note:setTimeRange(newOnset, newDuration)
end
```

### 6. Harmonize: pitch mapping

```lua
-- F-major diatonic thirds (above)
local thirdMap = { [60]=64, [62]=65, [65]=69, [67]=70, [69]=72, [72]=76 }

-- F-major pentatonic +2 steps (F,G,A,C,D)
local pentMap = { [60]=65, [62]=67, [65]=69, [67]=72, [69]=74, [72]=75 }

local chorusPitch = pentMap[origPitch] or (origPitch + 5)  -- fallback
```

## Common Workflows (continued)

### 7. Playback control

```lua
local pc = SV:getPlayback()  -- NOT getProject():getPlaybackControl()
pc:play()
pc:stop()
pc:pause()  -- stop without resetting playhead
pc:seek(5.0)  -- seek in seconds
pc:loop(0, 10)  -- loop between 0 and 10 seconds
pc:getPlayhead()  -- current playhead in seconds
pc:getStatus()  -- "playing", "looping", or "stopped"
```

**Note**: `seek()`, `loop()`, and `getPlayhead()` all use **seconds**, not blicks. Convert with `TimeAxis` if needed.

### 8. Get BPM / time signature

```lua
local timeAxis = SV:getProject():getTimeAxis()
-- BPM at a specific position (e.g. start of project)
local tempoMark = timeAxis:getTempoMarkAt(0)
local bpm = tempoMark.bpm
-- Time signature at measure 1
local measureMark = timeAxis:getMeasureMarkAt(1)
local sig = measureMark.numerator .. "/" .. measureMark.denominator
return {bpm = bpm, signature = sig}
```

### 9. Blicks ↔ seconds conversion

**Prefer TimeAxis methods** — they handle tempo changes correctly:

```lua
local timeAxis = SV:getProject():getTimeAxis()
local blicks = timeAxis:getBlickFromSeconds(seconds)
local seconds = timeAxis:getSecondsFromBlick(blicks)
```

**Manual conversion** (constant BPM only, for reference). These match `SV:seconds2Blick()` and `SV:blick2Seconds()`:

```lua
-- Seconds to blicks: s / 60 * bpm * SV.QUARTER
local blicks = seconds / 60 * bpm * SV.QUARTER
-- Blicks to seconds: b / SV.QUARTER * 60 / bpm
local seconds = blicks / SV.QUARTER * 60 / bpm
```

`SV.QUARTER` = 705600000 blicks per quarter note.

## Key Reference

- **Note attributes**: `references/Note.md` → `getAttributes()` section
- **Voice attributes**: `references/NoteGroupReference.md` → `getVoice()` / `setVoice()` section
- **Time units**: `SV.QUARTER` = 705600000 blicks/quarter. All onset/duration in blicks.
- **Object factory**: `SV:create("Note")`, `SV:create("Track")`, etc.
- **Return values**: `return value` → JSON. `nil` → `(null)`. `SV:print()` → SV Studio stdout.
- **Undo**: One record per eval command. `project:newUndoRecord()` for new boundary.
- **Playback uses seconds**: `seek()`, `loop()`, `getPlayhead()` take/return seconds. Convert via `TimeAxis:getBlickFromSeconds()` / `getSecondsFromBlick()`.

## Syllable Breaks and Legato

SV Studio handles multi-syllable words via special lyric symbols — **do NOT manually split words across notes**.

### Syllable Break (`+`)
Use `+` to continue a multi-syllable word to the next note:

| Note | Lyric | Syllable |
|---|---|---|
| 1 | `twinkle` | First syllable |
| 2 | `+` | Second syllable |

### Legato (`-`)
Use `-` to continue the last sung vowel into the following note (melisma):

| Note | Lyric | Syllable |
|---|---|---|
| 1 | `amazing` | First syllable |
| 2 | `-` | First (continued) |
| 3 | `+` | Second syllable |
| 4 | `+` | Third syllable |
| 5 | `-` | Third (continued) |

### Combining both
Multi-syllable words with melismas use `+` and `-` together:

| Note | Lyric | Syllable |
|---|---|---|
| 1 | `amazing` | First |
| 2 | `-` | First (continued) |
| 3 | `+` | Second |
| 4 | `+` | Third |
| 5 | `-` | Third (continued) |
| 6 | `-` | Third (continued) |

**Rule**: One syllable per note is best practice. Use `+` for multi-syllable words, `-` for vowel extension.

## Common MIDI Note Numbers

| Note | MIDI | Note | MIDI |
|---|---|---|---|
| C4 | 60 | D#4/ Eb4 | 63 |
| C#4/ Db4 | 61 | E4 | 64 |
| D4 | 62 | F4 | 65 |
| | | F#4/ Gb4 | 66 |
| | | G4 | 67 |
| | | G#4/ Ab4 | 68 |
| | | A4 | 69 |
| | | A#4/ Bb4 | 70 |
| | | B4 | 71 |
| | | C5 | 72 |

## Best Practices

- **Read before write**: Collect all data into tables first, then modify. Never read-modify-read in a loop.
- **Reverse iteration for destructive ops**: `setTimeRange()`, `removeNote()` — always iterate last→first.
- **Forward iteration for non-positional changes**: `setPitch()`, `setLyrics()`, `setAttributes()` are safe in any order.
- **Verify after changes**: Always run a read-back script to confirm note count, order, and key properties.
- **Ask the user when ambiguous**: e.g., "weaker vibrato" → ask for specific value before applying.
- **Copy voice settings for harmony tracks**: `groupRef:setVoice(srcGroupRef:getVoice())` to preserve singer/voice.
- **Main group may be empty**: The main `NoteGroupReference` (`isMain() == true`) often has 0 notes. Actual notes are usually in a non-main group.
- **Check timeOffset before adding notes**: The group's `getTimeOffset()` may be non-zero (e.g., `-1*QUARTER`), which can push notes before the project start and clip them. Reset with `groupRef:setTimeOffset(0)` if notes should start at position 0.
- **Avoid unnecessary pitch control points**: Adding `PitchControlPoint` objects can distort the generated pitch curve if placed incorrectly. Only add them when explicitly requested.
