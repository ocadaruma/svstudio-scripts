# Track

## Track

A collection of [`NoteGroupReference`](NoteGroupReference.md). A `Track` also contains a [`NoteGroup`](NoteGroup.md) which is the main group of the track. The first [`NoteGroupReference`](NoteGroupReference.md) inside the track always refers to the main group.

The default voice properties of the `Track` is defined by the first [`NoteGroupReference`](NoteGroupReference.md) (the main group).

### Extends

- [ScriptableNestedObject](ScriptableNestedObject.md)

### Methods

#### addGroupReference(group) → {number}

Add a [`NoteGroupReference`](NoteGroupReference.md) to this `Track` and return the index of the added group. It keeps all groups sorted by onset position.

##### Parameters:

Name Type Description `group` [NoteGroupReference](NoteGroupReference.md)

##### Returns:

Type

number

#### clearScriptData()

Inherited From:

- [ScriptableNestedObject#clearScriptData](ScriptableNestedObject.md#clearScriptData)

Remove all script data from the object's storage. Note: use with caution as this could also remove data created by other scripts.

#### clone() → {[Track](Track.md)}

A deep copy of the current object.

##### Returns:

Type

[Track](Track.md)

#### getDisplayColor() → {string}

Get the track's color as a hex string.

##### Returns:

Type

string

#### getDisplayOrder() → {number}

Get the display order of the track inside the parent [`Project`](Project.md). A track's display order can be different from its storage index. The order of tracks as displayed in arrangement view is always based on the display order.

##### Returns:

Type

number

#### getDuration() → {number}

Get the duration of the `Track` in blicks, defined as the ending position of the last [`NoteGroupReference`](NoteGroupReference.md).

##### Returns:

Type

number

#### getGroupReference(index) → {[NoteGroupReference](NoteGroupReference.md)}

Get the `index`-th [`NoteGroupReference`](NoteGroupReference.md). The first is always the main group, followed by groups that refer to [`NoteGroup`](NoteGroup.md) in the project library. The groups are sorted in ascending onset positions.

##### Parameters:

Name Type Description `index` number

##### Returns:

Type

[NoteGroupReference](NoteGroupReference.md)

#### getIndexInParent() → {number}

Inherited From:

- [NestedObject#getIndexInParent](NestedObject.md#getIndexInParent)

Get index of the current object in its parent. In Lua, this index starts from 1. In JavaScript, this index starts from 0.

##### Returns:

Type

number

#### getMixer() → {[TrackMixer](TrackMixer.md)}

Get the track's mixer.

The mixer allows you to adjust gain, pan, mute, and solo settings for the track.

(supported since 2.1.1)

##### Returns:

Type

[TrackMixer](TrackMixer.md)

#### getName() → {string}

Get the track name.

##### Returns:

Type

string

#### getNumGroups() → {number}

Get the number of [`NoteGroupReference`](NoteGroupReference.md) in this `Track`, including the main group.

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

#### isBounced() → {boolean}

An option for whether or not to be exported to files, shown in Render Panel.

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

#### removeGroupReference(index)

Remove the `index`-th [`NoteGroupReference`](NoteGroupReference.md) from this `Track`.

##### Parameters:

Name Type Description `index` number

#### removeScriptData(key)

Inherited From:

- [ScriptableNestedObject#removeScriptData](ScriptableNestedObject.md#removeScriptData)

Remove a key-value pair from the object's script data storage.

##### Parameters:

Name Type Description `key` string

The key to remove

#### setBounced(enabled)

Set whether or not to have the `Track` exported to files. See [`Track#isBounced`](Track.md#isBounced).

##### Parameters:

Name Type Description `enabled` boolean

#### setDisplayColor(colorStr)

Set the display color of the `Track` to a hex string.

##### Parameters:

Name Type Description `colorStr` string

#### setName(name)

Set the name of the `Track`.

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