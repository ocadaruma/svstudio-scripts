# PitchControlCurve

## PitchControlCurve

A pitch control curve that overrides the generated pitch over a time range within a [`NoteGroup`](NoteGroup.md).

Pitch control curves represent continuous pitch modifications defined by multiple time-pitch pairs. They have an anchor position (relative to the note group), an anchor pitch value (in semitones relative to the note group), and a collection of time-pitch pairs shifted by the curve's anchor position and pitch values.

The anchor position/value is not seen in the GUI but kept for implementation convenience. It's typically set to the center position taken from the bounding box for all the points inside.

(supported since 2.1.0)

### Extends

- [ScriptableNestedObject](ScriptableNestedObject.md)

### Methods

#### clearScriptData()

Inherited From:

- [ScriptableNestedObject#clearScriptData](ScriptableNestedObject.md#clearScriptData)

Remove all script data from the object's storage. Note: use with caution as this could also remove data created by other scripts.

#### clone() → {[PitchControlCurve](PitchControlCurve.md)}

A deep copy of the current object.

##### Returns:

Type

[PitchControlCurve](PitchControlCurve.md)

#### getIndexInParent() → {number}

Inherited From:

- [NestedObject#getIndexInParent](NestedObject.md#getIndexInParent)

Get index of the current object in its parent. In Lua, this index starts from 1. In JavaScript, this index starts from 0.

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

#### getPitch() → {number}

Get the anchor pitch value of this pitch control curve in semitones relative to the pitch offset of the note group.

##### Returns:

pitch in semitones

Type

number

#### getPoints() → {Array.&lt;Array.&lt;number&gt;&gt;}

Get all control points of this pitch control curve.

Returns an array of \[time, value] pairs where time is in blicks relative to the curve's anchor position and value is the pitch offset from the anchor position in semitones.

##### Returns:

array of \[time, value] pairs

Type

Array.&lt;Array.&lt;number&gt;&gt;

#### getPosition() → {number}

Get the anchor position of this pitch control curve relative to the time offset of the note group (in blicks).

##### Returns:

position in blicks

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

#### getValueAt(time) → {number}

Get the interpolated pitch value at a specific time position.

Returns the pitch offset in semitones at the given time, interpolated from the curve's control points.

##### Parameters:

Name Type Description `time` number

time in blicks relative to the curve's position

##### Returns:

pitch offset in semitones

Type

number

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

#### isMemoryManaged() → {boolean}

Inherited From:

- [NestedObject#isMemoryManaged](NestedObject.md#isMemoryManaged)

Check whether or not the current object is memory managed (i.e. garbage collected by the script environment).

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

#### setPitch(pitch)

Set the anchor pitch value of this pitch control curve.

##### Parameters:

Name Type Description `pitch` number

pitch in semitones

#### setPoints(points)

Set all control points of this pitch control curve.

Each point should be an array of \[time, value] where time is in blicks relative to the curve's anchor position and value is the pitch offset from the anchor position in semitones.

##### Parameters:

Name Type Description `points` Array.&lt;Array.&lt;number&gt;&gt;

array of \[time, value] pairs

#### setPosition(position)

Set the anchor position of this pitch control curve.

##### Parameters:

Name Type Description `position` number

position in blicks

#### setScriptData(key, value)

Inherited From:

- [ScriptableNestedObject#setScriptData](ScriptableNestedObject.md#setScriptData)

Store a value with the specified key in the object's script data storage. The value must be JSON-serializable.

##### Parameters:

Name Type Description `key` string

The key to store the value under

`value` any

The value to store (must be JSON-serializable)

Documentation generated by [JSDoc 4.0.4](https://github.com/jsdoc3/jsdoc) on Thu Oct 09 2025 18:00:39 GMT+0900 (Japan Standard Time) using the [docdash](https://github.com/clenemt/docdash) theme.

Copyright 2020-2025 Dreamtonics Co., Ltd.