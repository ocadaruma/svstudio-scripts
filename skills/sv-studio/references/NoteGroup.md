# NoteGroup

## NoteGroup

A set of notes ([`Note`](Note.md)) and parameters ([`Automation`](Automation.md)) grouped together for convenient reuse.

To put a `NoteGroup` inside a [`Track`](Track.md), it has to be wrapped in a [`NoteGroupReference`](NoteGroupReference.md) which provides the context (e.g. voice, language, time and pitch offset) for the group.

### Extends

- [ScriptableNestedObject](ScriptableNestedObject.md)

### Methods

#### addNote(note) → {number}

Add a note to this `NoteGroup` and return the index of the added note. The notes are kept sorted by ascending onset positions.

##### Parameters:

Name Type Description `note` [Note](Note.md)

##### Returns:

Type

number

#### addPitchControl(pitchControl) → {number}

Add a pitch control object to this `NoteGroup` and return the index of the added object. The pitch control objects are kept sorted by ascending anchor positions.

(supported since 2.1.0)

##### Parameters:

Name Type Description `pitchControl` [PitchControlPoint](PitchControlPoint.md) | [PitchControlCurve](PitchControlCurve.md)

##### Returns:

Type

number

#### clearScriptData()

Inherited From:

- [ScriptableNestedObject#clearScriptData](ScriptableNestedObject.md#clearScriptData)

Remove all script data from the object's storage. Note: use with caution as this could also remove data created by other scripts.

#### clone() → {[NoteGroup](NoteGroup.md)}

A deep copy of the current object.

##### Returns:

Type

[NoteGroup](NoteGroup.md)

#### getIndexInParent() → {number}

Inherited From:

- [NestedObject#getIndexInParent](NestedObject.md#getIndexInParent)

Get index of the current object in its parent. In Lua, this index starts from 1. In JavaScript, this index starts from 0.

##### Returns:

Type

number

#### getName() → {string}

Get the user-specified name of this `NoteGroup`.

##### Returns:

Type

string

#### getNote(index) → {[Note](Note.md)}

Get the note at `index`. The notes inside a `NoteGroup` are always sorted by onset positions.

##### Parameters:

Name Type Description `index` number

##### Returns:

Type

[Note](Note.md)

#### getNumNotes() → {number}

Get the number of notes in the `NoteGroup`.

##### Returns:

Type

number

#### getNumPitchControls() → {number}

Get the number of pitch control objects in the `NoteGroup`.

(supported since 2.1.0)

##### Returns:

Type

number

#### getParameter(type) → {[Automation](Automation.md)}

Get the [`Automation`](Automation.md) object for parameter `type`. It is case-insensitive.

`type` should be one of the strings in the `typeName` column in the table shown in [`Automation#getDefinition`](Automation.md#getDefinition).

##### Parameters:

Name Type Description `type` string

##### Returns:

Type

[Automation](Automation.md)

#### getParent() → {[NestedObject](NestedObject.md)|undefined}

Inherited From:

- [NestedObject#getParent](NestedObject.md#getParent)

Get the parent [`NestedObject`](NestedObject.md). Return `undefined` if the current object is not attached to a parent.

##### Returns:

Type

[NestedObject](NestedObject.md) | undefined

#### getPitchControl(index) → {[PitchControlPoint](PitchControlPoint.md)|[PitchControlCurve](PitchControlCurve.md)}

Get the pitch control object at `index`. The pitch control objects inside a `NoteGroup` are kept sorted by anchor positions.

(supported since 2.1.0)

##### Parameters:

Name Type Description `index` number

##### Returns:

Type

[PitchControlPoint](PitchControlPoint.md) | [PitchControlCurve](PitchControlCurve.md)

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

#### getUUID() → {string}

Get the Universally Unique Identifier. Unlike the name, a UUID is unique across the project and can be used to associate a [`NoteGroupReference`](NoteGroupReference.md) with a `NoteGroup`.

A UUID looks like this: "ab85d637-d80b-4628-9c27-007ea74029af".

##### Returns:

Type

string

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

#### removeNote(index)

Remove the note at `index`.

##### Parameters:

Name Type Description `index` number

#### removePitchControl(index)

Remove the pitch control object at `index`.

(supported since 2.1.0)

##### Parameters:

Name Type Description `index` number

#### removeScriptData(key)

Inherited From:

- [ScriptableNestedObject#removeScriptData](ScriptableNestedObject.md#removeScriptData)

Remove a key-value pair from the object's script data storage.

##### Parameters:

Name Type Description `key` string

The key to remove

#### setName(name)

Set the name of this `NoteGroup`.

##### Parameters:

Name Type Description `name` string

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
