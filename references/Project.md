# Project

## Project

The largest object to work with. Contains [`Track`](Track.md), [`TimeAxis`](TimeAxis.md), [`NoteGroup`](NoteGroup.md), etc.

### Extends

- [ScriptableNestedObject](ScriptableNestedObject.md)

### Methods

#### addNoteGroup(group, suggestedIndex) → {number}

Insert a [`NoteGroup`](NoteGroup.md) to the project library at `suggestedIndex`. If `suggestedIndex` is not given, the [`NoteGroup`](NoteGroup.md) is added at the end. Return the index of the added [`NoteGroup`](NoteGroup.md).

##### Parameters:

Name Type Description `group` [NoteGroup](NoteGroup.md) `suggestedIndex` number

(optional)

##### Returns:

Type

number

#### addTrack(track) → {number}

Add a [`Track`](Track.md) to the `Project`. Return the index of the added [`Track`](Track.md).

##### Parameters:

Name Type Description `track` [Track](Track.md)

##### Returns:

Type

number

#### clearScriptData()

Inherited From:

- [ScriptableNestedObject#clearScriptData](ScriptableNestedObject.md#clearScriptData)

Remove all script data from the object's storage. Note: use with caution as this could also remove data created by other scripts.

#### getDuration() → {number}

Get the duration of the `Project` (blicks), defined as the duration of the longest [`Track`](Track.md).

##### Returns:

Type

number

#### getFileName() → {string}

Get the absolute path of the project on the file system.

##### Returns:

Type

string

#### getIndexInParent() → {number}

Inherited From:

- [NestedObject#getIndexInParent](NestedObject.md#getIndexInParent)

Get index of the current object in its parent. In Lua, this index starts from 1. In JavaScript, this index starts from 0.

##### Returns:

Type

number

#### getNoteGroup(id) → {[NoteGroup](NoteGroup.md)|undefined}

If `id` is a number, get the `id`-th [`NoteGroup`](NoteGroup.md) in the project library.

If `id` is a string, look for a [`NoteGroup`](NoteGroup.md) in the project library with `id` as its UUID; return `undefined` if no such [`NoteGroup`](NoteGroup.md) exists.

##### Parameters:

Name Type Description `id` number | string

##### Returns:

Type

[NoteGroup](NoteGroup.md) | undefined

#### getNumNoteGroupsInLibrary() → {number}

Get the number of [`NoteGroup`](NoteGroup.md) in the project library.

It does not count the main groups and is unrelated to the number of [`NoteGroupReference`](NoteGroupReference.md).

##### Returns:

Type

number

#### getNumTracks() → {number}

Get the number of tracks.

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

#### getTimeAxis() → {[TimeAxis](TimeAxis.md)}

Get the [`TimeAxis`](TimeAxis.md) object of this `Project`.

##### Returns:

Type

[TimeAxis](TimeAxis.md)

#### getTrack(index) → {[Track](Track.md)}

Get the `index`-th [`Track`](Track.md). The indexing is based on the storage order rather than display order.

##### Parameters:

Name Type Description `index` number

##### Returns:

Type

[Track](Track.md)

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

#### newUndoRecord()

Add a new undo record for this `Project`. This means that all edits following the last undo record will be undone/redone together when the users press `Ctrl + Z` or `Ctrl + Y`.

A new undo record is automatically added to the currently open project at the beginning of script execution.

#### removeNoteGroup(index)

Remove `index`-th [`NoteGroup`](NoteGroup.md) from the project library. This also removes all [`NoteGroupReference`](NoteGroupReference.md) that refer to the [`NoteGroup`](NoteGroup.md).

##### Parameters:

Name Type Description `index` number

#### removeScriptData(key)

Inherited From:

- [ScriptableNestedObject#removeScriptData](ScriptableNestedObject.md#removeScriptData)

Remove a key-value pair from the object's script data storage.

##### Parameters:

Name Type Description `key` string

The key to remove

#### removeTrack(index)

Remove the `index`-th [`Track`](Track.md) from the `Project`.

##### Parameters:

Name Type Description `index` number

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