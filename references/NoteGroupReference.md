# NoteGroupReference

## NoteGroupReference

A reference to a [`NoteGroup`](NoteGroup.md) with optional time and pitch offset and voice/database properties. It puts a [`NoteGroup`](NoteGroup.md) in a language context so text-to-phoneme conversion and rendering are possible.

A `NoteGroupReference` is always placed inside a [`Track`](Track.md). A [`NoteGroup`](NoteGroup.md) may be referenced by more than one `NoteGroupReference`.

### Extends

- [ScriptableNestedObject](ScriptableNestedObject.md)

### Methods

#### clearScriptData()

Inherited From:

- [ScriptableNestedObject#clearScriptData](ScriptableNestedObject.md#clearScriptData)

Remove all script data from the object's storage. Note: use with caution as this could also remove data created by other scripts.

#### clone() → {[NoteGroupReference](NoteGroupReference.md)}

A deep copy of the current object.

Note: since `NoteGroupReference` does not take ownership of the target [`NoteGroup`](NoteGroup.md), this does not copy the target [`NoteGroup`](NoteGroup.md).

##### Returns:

Type

[NoteGroupReference](NoteGroupReference.md)

#### getDuration() → {number}

The duration of this `NoteGroupReference` (blicks).

Equivalent to `getEnd() - getOnset()`.

##### Returns:

Type

number

#### getEnd() → {number}

Get the ending position (blicks), that is, the end of the last note in the target [`NoteGroup`](NoteGroup.md) plus the time offset.

If the `NoteGroupReference` holds an audio file ([`NoteGroupReference#isInstrumental`](NoteGroupReference.md#isInstrumental)), `getEnd()` will return the ending position (blicks) of the audio plus the time offset. However, if the `NoteGroupReference` is not placed inside a [`Project`](Project.md), there is not enough information to determine the audio's length in musical time units and `getEnd()` will assume that the duration is zero.

##### Returns:

Type

number

#### getIndexInParent() → {number}

Inherited From:

- [NestedObject#getIndexInParent](NestedObject.md#getIndexInParent)

Get index of the current object in its parent. In Lua, this index starts from 1. In JavaScript, this index starts from 0.

##### Returns:

Type

number

#### getOnset() → {number}

Get the beginning position (blicks), that is, the onset of the first [`Note`](Note.md) in the target [`NoteGroup`](NoteGroup.md) plus the time offset.

##### Returns:

Type

number

#### getParent() → {[NestedObject](NestedObject.md)|undefined}

Inherited From:

- [NestedObject#getParent](NestedObject.md#getParent)

Get the parent [`NestedObject`](NestedObject.md). Return `undefined` if the current object is not attached to a parent.

##### Returns:

Type

[NestedObject](NestedObject.md) | undefined

#### getPitchOffset() → {number}

Get the pitch shift (semitones) applied to all notes in the target [`NoteGroup`](NoteGroup.md)}.

##### Returns:

Type

number

#### getScriptData(key) → {any}

Inherited From:

- [ScriptableNestedObject#getScriptData](ScriptableNestedObject.md#getScriptData)

Retrieve a value from the object's script data storage by key. Returns `undefined` if the key does not exist.

##### Parameters:

Name Type Description `key` string

The key to retrieve the value for

##### Returns:

The stored value, or `undefined` if key doesn't exist

Type

any

#### getScriptDataKeys() → {Array.&lt;string&gt;}

Inherited From:

- [ScriptableNestedObject#getScriptDataKeys](ScriptableNestedObject.md#getScriptDataKeys)

Get all keys currently stored in the object's script data storage.

##### Returns:

Array of all stored keys

Type

Array.&lt;string&gt;

#### getTarget() → {[NoteGroup](NoteGroup.md)}

Get the target [`NoteGroup`](NoteGroup.md).

##### Returns:

Type

[NoteGroup](NoteGroup.md)

#### getTimeOffset() → {number}

Get the time offset (blicks) applied to all notes in the target [`NoteGroup`](NoteGroup.md).

##### Returns:

Type

number

#### getVoice() → {object}

Get an object holding the default voice properties for this group, similar to [`Note#getAttributes`](Note.md#getAttributes).

The object has the following properties.

- `paramLoudness`: `number` parameters - loudness (dB)
- `paramTension`: `number` parameters - tension
- `paramBreathiness`: `number` parameters - breathiness
- `paramGender`: `number` parameters - gender
- `paramToneShift`: `number` parameters - tone shift
- `vocalModeParams`: `object` vocal mode parameters (supported since 2.1.1)
  
  - Each key is a vocal mode name (e.g. "Soft", "Powerful")
  - Each value is an object with:
    
    - `pitch`: `number` pitch adjustment (0 to 150)
    - `timbre`: `number` timbre adjustment (0 to 150)
    - `pronunciation`: `number` pronunciation adjustment (0 to 150)

Properties only available in version 1:

- `tF0Left`: `number` pitch transition - duration left (seconds)
- `tF0Right`: `number` pitch transition - duration right (seconds)
- `dF0Left`: `number` pitch transition - depth left (semitones)
- `dF0Right`: `number` pitch transition - depth right (semitones)
- `tF0VbrStart`: `number` vibrato - start (seconds)
- `tF0VbrLeft`: `number` vibrato - left (seconds)
- `tF0VbrRight`: `number` vibrato - right (seconds)
- `dF0Vbr`: `number` vibrato - depth (semitones)
- `fF0Vbr`: `number` vibrato - frequency (Hz)

##### Returns:

Type

object

#### hasScriptData(key) → {boolean}

Inherited From:

- [ScriptableNestedObject#hasScriptData](ScriptableNestedObject.md#hasScriptData)

Check whether a key exists in the object's script data storage.

##### Parameters:

Name Type Description `key` string

The key to check for

##### Returns:

`true` if the key exists, `false` otherwise

Type

boolean

#### isInstrumental() → {boolean}

Whether this `NoteGroupReference` refers to an external audio file. If so, it must not refer to a [`NoteGroup`](NoteGroup.md).

##### Returns:

Type

boolean

#### isMain() → {boolean}

Whether this `NoteGroupReference` refers to the parent [`Track`](Track.md)'s main group.

##### Returns:

Type

boolean

#### isMemoryManaged() → {boolean}

Inherited From:

- [NestedObject#isMemoryManaged](NestedObject.md#isMemoryManaged)

Check whether or not the current object is memory managed (i.e. garbage collected by the script environment).

##### Returns:

Type

boolean

#### isMuted() → {boolean}

Check if this group is muted.

(supported since 2.1.1)

##### Returns:

Type

boolean

#### removeScriptData(key)

Inherited From:

- [ScriptableNestedObject#removeScriptData](ScriptableNestedObject.md#removeScriptData)

Remove a key-value pair from the object's script data storage.

##### Parameters:

Name Type Description `key` string

The key to remove

#### setMuted(muted)

Set the mute status of this group.

When a group is muted, it will not contribute to the audio output during playback.

(supported since 2.1.1)

##### Parameters:

Name Type Description `muted` boolean

#### setPitchOffset(pitchOffset)

Set the pitch offset to `pitchOffset` (semitones).

##### Parameters:

Name Type Description `pitchOffset` number

#### setScriptData(key, value)

Inherited From:

- [ScriptableNestedObject#setScriptData](ScriptableNestedObject.md#setScriptData)

Store a value with the specified key in the object's script data storage. The value must be JSON-serializable.

##### Parameters:

Name Type Description `key` string

The key to store the value under

`value` any

The value to store (must be JSON-serializable)

#### setTarget(group)

Set the target [`NoteGroup`](NoteGroup.md).

Note that once set, the target can't be changed.

##### Parameters:

Name Type Description `group` [NoteGroup](NoteGroup.md)

#### setTimeOffset(blickOffset)

Set the time offset to `blickOffset` (blicks).

##### Parameters:

Name Type Description `blickOffset` number

#### setTimeRange(onset, duration)

Set the absolute onset and duration of a group. This does not affect the time offset and can be used to shorten or extend a group from either left or right.

(supported since 2.1.0)

##### Parameters:

Name Type Description `onset` number `duration` number

#### setVoice(attributes)

Set voice properties based on an attribute object (for the definition, see [`NoteGroupReference#getVoice`](NoteGroupReference.md#getVoice)). The attribute object does not have to be complete; only the given properties will be updated (see [`Note#setAttributes`](Note.md#setAttributes)).

##### Parameters:

Name Type Description `attributes` object

Documentation generated by [JSDoc 4.0.4](https://github.com/jsdoc3/jsdoc) on Thu Oct 09 2025 18:00:39 GMT+0900 (Japan Standard Time) using the [docdash](https://github.com/clenemt/docdash) theme.

Copyright 2020-2025 Dreamtonics Co., Ltd.