# ArrangementSelectionState

## ArrangementSelectionState

The selection state of the track arrangement area.

To access the `ArrangementSelectionState` object,

- use `SV.getArrangement().getSelection()` in JavaScript
- use `SV:getArrangement():getSelection()` in Lua

### Extends

- [NestedObject](NestedObject.md)
- [SelectionStateBase](SelectionStateBase.md)
- [GroupSelection](GroupSelection.md)

### Methods

#### clearAll() → {boolean}

Inherited From:

- [SelectionStateBase#clearAll](SelectionStateBase.md#clearAll)

Unselects all object types supported by this selection state. Return true if the selection has changed.

##### Returns:

Type

boolean

#### clearGroups() → {boolean}

Inherited From:

- [GroupSelection#clearGroups](GroupSelection.md#clearGroups)

Unselect all [`NoteGroupReference`](NoteGroupReference.md). Return true if the selection has changed.

##### Returns:

Type

boolean

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

#### getSelectedGroups() → {array}

Inherited From:

- [GroupSelection#getSelectedGroups](GroupSelection.md#getSelectedGroups)

Get an array of selected [`NoteGroupReference`](NoteGroupReference.md) following the order of selection.

##### Returns:

an `array` of [`NoteGroupReference`](NoteGroupReference.md)

Type

array

#### hasSelectedContent() → {boolean}

Inherited From:

- [SelectionStateBase#hasSelectedContent](SelectionStateBase.md#hasSelectedContent)

Check if there's anything selected.

##### Returns:

Type

boolean

#### hasSelectedGroups() → {boolean}

Inherited From:

- [GroupSelection#hasSelectedGroups](GroupSelection.md#hasSelectedGroups)

Check if there is at least one [`NoteGroupReference`](NoteGroupReference.md) selected.

##### Returns:

Type

boolean

#### hasUnfinishedEdits() → {boolean}

Inherited From:

- [SelectionStateBase#hasUnfinishedEdits](SelectionStateBase.md#hasUnfinishedEdits)

Check if there's any unfinished edit on the selected objects.

For example, this will return true if the user is dragging around a few notes/control points but has not yet released the mouse.

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

#### registerClearCallback(callback)

Inherited From:

- [SelectionStateBase#registerClearCallback](SelectionStateBase.md#registerClearCallback)

Attach a script function to be called when the selection is cleared. The callback function will receive one argument: the type of the cleared objects.

Note:

- Registering a new callback function will NOT override existing callbacks.
- To prevent callbacks from slowing down the application, multiple clear events will be coalesced and handled asynchronously. There is no guarantee that the cleared selection will stay empty by the time the callback is executed.

##### Parameters:

Name Type Description `callback` function

#### registerSelectionCallback(callback)

Inherited From:

- [SelectionStateBase#registerSelectionCallback](SelectionStateBase.md#registerSelectionCallback)

Attach a script function to be called when objects are selected or deselected by the user. The callback function will receive two arguments: the type of the selected objects and whether this is a selection or deselection operation.

Note:

- Registering a new callback function will NOT override existing callbacks.
- To prevent callbacks from slowing down the application, multiple selection/deselection events will be coalesced and handled asynchronously. There is no guarantee that objects selected will stay selected by the time the callback is executed.

##### Parameters:

Name Type Description `callback` function

#### selectGroup(reference)

Inherited From:

- [GroupSelection#selectGroup](GroupSelection.md#selectGroup)

Add a [`NoteGroupReference`](NoteGroupReference.md) to the selection.

The argument must be part of the currently open project.

##### Parameters:

Name Type Description `reference` [NoteGroupReference](NoteGroupReference.md)

#### unselectGroup(reference) → {boolean}

Inherited From:

- [GroupSelection#unselectGroup](GroupSelection.md#unselectGroup)

Unselect a [`NoteGroupReference`](NoteGroupReference.md). Return true if the selection has changed.

##### Parameters:

Name Type Description `reference` [NoteGroupReference](NoteGroupReference.md)

##### Returns:

Type

boolean

Documentation generated by [JSDoc 4.0.4](https://github.com/jsdoc3/jsdoc) on Thu Oct 09 2025 18:00:39 GMT+0900 (Japan Standard Time) using the [docdash](https://github.com/clenemt/docdash) theme.

Copyright 2020-2025 Dreamtonics Co., Ltd.