# SV Studio Scripting via eval-client.mjs

## Overview

Synthesizer V Studio is controlled remotely via `eval-client.mjs`, a CLI that sends Lua code to an EvalServer running inside SV Studio and returns results.

```bash
node eval-client.mjs -c 'lua code here'
node eval-client.mjs -f script.lua
node eval-client.mjs --ping       # check server alive
node eval-client.mjs --status     # server info
```

**Key point**: All Lua code runs inside SV Studio's Lua 5.4 environment with the `SV` global object as the single entry point.

## Reference Files

| File | Purpose | When to read |
|------|---------|-------------|
| `references/API.md` | Consolidated API reference | **Read first** — single-file lookup for all classes/methods |
| `references/*.md` | Original JSDoc docs | Deep-dive on specific classes |
| `SKILL.md` | This file | Workflows, patterns, pitfalls |

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
local srcGroup = project:getTrack(1):getGroupReference(2):getTarget()
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

## Key Reference

- **Note attributes**: `references/API.md` → `Note` section
- **Voice attributes**: `references/API.md` → `NoteGroupReference` section
- **Time units**: `SV.QUARTER` = 705600000 blicks/quarter. All onset/duration in blicks.
- **Object factory**: `SV:create("Note")`, `SV:create("Track")`, etc.
- **Return values**: `return value` → JSON. `nil` → `(null)`. `SV:print()` → SV Studio stdout.
- **Undo**: One record per eval command. `project:newUndoRecord()` for new boundary.
