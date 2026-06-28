# Tutorial: Custom Side Panel Sections

## Custom Side Panel Sections

Custom side panel sections allow script authors to create persistent, interactive UI panels that remain embedded within the Synthesizer V Studio interface. Unlike dialogs and message boxes which are modal and temporary, side panel sections provide a continuous workspace for tools that benefit from always-on access.

## Creating a Side Panel Section

A side panel section script requires `getClientInfo()` to return `"type": "SidePanelSection"` and must implement the `getSidePanelSectionState()` function instead of `main()`. In addition, the `minEditorVersion` must be 131330 (version 2.1.2) or above.

### Basic Structure

```javascript
function getClientInfo() {
  return {
    "name": "My Panel",
    "category": "Utilities",
    "author": "Your Name",
    "versionNumber": 1,
    "minEditorVersion": 131330,
    "type": "SidePanelSection"
  };
}

function getSidePanelSectionState() {
  return {
    "title": "My Panel",
    "rows": [
      // UI widgets defined here
    ]
  };
}
```

### Section Object Structure

The object returned by `getSidePanelSectionState()` has the following properties:

- `title`: `string` - the panel's title displayed at the top
- `rows`: `array` - an array of widget rows

## Layout System

Side panel sections use a two-level row-and-column layout system:

1. **First level (Rows)**: The `rows` array can only contain `Label` or `Container` widgets
2. **Second level (Columns)**: Inside a `Container`'s `columns` array, you can place interactive widgets like `TextBox`, `Button`, `Slider`, etc.

### Rows

Rows stack vertically from top to bottom. Each row must be either a **Label** or a **Container**:

```javascript
"rows": [
  // Row 1: Label
  {
    "type": "Label",
    "text": "Search options:"
  },
  // Row 2: Container with widgets
  {
    "type": "Container",
    "columns": [
      {
        "type": "TextBox",
        "value": searchValue,
        "width": 1.0
      }
    ]
  },
  // Row 3: Another label
  {
    "type": "Label",
    "text": "Results:"
  }
]
```

### Columns and Relative Widths

To place multiple widgets side-by-side, use a **Container** widget with a `columns` array. Each widget in a column specifies a `width` property representing its relative proportion of the available horizontal space.

```javascript
{
  "type": "Container",
  "columns": [
    {
      "type": "Button",
      "text": "Left",
      "value": leftButtonValue,
      "width": 0.3  // Takes 30% of width
    },
    {
      "type": "Button",
      "text": "Right",
      "value": rightButtonValue,
      "width": 0.7  // Takes 70% of width
    }
  ]
}
```

## Widget System

### WidgetValue

Side panel sections use [`WidgetValue`](WidgetValue.md) objects to transmit data, in both directions, between the UI and the script. Create them with `SV.create("WidgetValue")`.

```javascript
var myValue = SV.create("WidgetValue");
myValue.setValue(0);  // Initialize
myValue.setEnabled(true);  // Enable/disable the widget

// React to changes
myValue.setValueChangeCallback(function(newValue) {
  // Handle value change
});
```

### Widget Types

#### TextBox

Single-line text input.

```javascript
var textValue = SV.create("WidgetValue");
textValue.setValue("initial text");

{
  "type": "TextBox",
  "value": textValue,
}
```

#### TextArea

Multi-line text display or input.

```javascript
var textAreaValue = SV.create("WidgetValue");
textAreaValue.setValue("Multi-line\ntext here");

{
  "type": "TextArea",
  "value": textAreaValue,
  "height": 80,      // Height in pixels
}
```

#### Button

Clickable button that triggers an action.

```javascript
// The value inside isn't important.
// It is created only for receiving callbacks and setting enabled/disabled states.
var buttonValue = SV.create("WidgetValue");
buttonValue.setValueChangeCallback(function() {
  // Button clicked
  SV.showMessageBox("Info", "Button pressed!");
});

{
  "type": "Button",
  "text": "Click Me",
  "value": buttonValue,
}
```

#### Slider

Numeric slider with configurable range and formatting.

```javascript
var sliderValue = SV.create("WidgetValue");
sliderValue.setValue(3);

{
  "type": "Slider",
  "text": "Volume",
  "format": "%3.1f dB",  // printf-style format string
  "minValue": -6,
  "maxValue": 6,
  "interval": 0.1,
  "value": sliderValue,
}
```

Example format strings:

- `"%3.2f beats"` - 2 decimal places with unit
- `"%3.0f %%"` - integer percentage
- `"%2.1f Hz"` - 1 decimal place with unit

#### CheckBox

Boolean toggle.

```javascript
var checkValue = SV.create("WidgetValue");
checkValue.setValue(true);

{
  "type": "CheckBox",
  "text": "Apply this to all notes in the group",
  "value": checkValue,
}
```

#### ComboBox

Dropdown selection.

```javascript
var comboValue = SV.create("WidgetValue");
comboValue.setValue(0);  // Index of selected item

{
  "type": "ComboBox",
  "choices": ["Option 1", "Option 2", "Option 3"],
  "value": comboValue,
}
```

## Responding to Editor Events

Side panel sections can respond to editor state changes using callbacks.

### Selection Changes

```javascript
SV.getMainEditor().getSelection().registerSelectionCallback(function(selectionType, isSelected) {
  if(selectionType == "note") {
    // A note was selected or deselected, update the UI
    ...
  }
});

SV.getMainEditor().getSelection().registerClearCallback(function(selectionType) {
  if(selectionType == "notes") {
    // All notes were deselected, update the UI
    ...
  }
});
```

### Toy Example

```javascript
var SCRIPT_TITLE = "Selected Note Counter";

function getClientInfo() {
  return {
    "name": SCRIPT_TITLE,
    "category": "Utilities",
    "author": "Dreamtonics",
    "versionNumber": 1,
    "minEditorVersion": 131330,
    "type": "SidePanelSection"
  };
}

var countValue = SV.create("WidgetValue");
var setLyricsButtonValue = SV.create("WidgetValue");

countValue.setValue("0 notes selected");
countValue.setEnabled(false);

function updateSelectionCount() {
  var selection = SV.getMainEditor().getSelection();
  var selectedNotes = selection.getSelectedNotes();
  var count = selectedNotes.length;

  countValue.setValue(count + " note" + (count === 1 ? "" : "s") + " selected");
  setLyricsButtonValue.setEnabled(count > 0);
}

setLyricsButtonValue.setValueChangeCallback(function() {
  var selection = SV.getMainEditor().getSelection();
  var selectedNotes = selection.getSelectedNotes();

  if(selectedNotes.length === 0) return;

  SV.getProject().newUndoRecord();

  for(var i = 0; i < selectedNotes.length; i ++) {
    selectedNotes[i].setLyrics("a");
  }
});

// Register selection callbacks to update count automatically
SV.getMainEditor().getSelection().registerSelectionCallback(function(selectionType, isSelected) {
  if(selectionType == "note") {
    updateSelectionCount();
  }
});

SV.getMainEditor().getSelection().registerClearCallback(function(selectionType) {
  if(selectionType == "notes") {
    updateSelectionCount();
  }
});

// Initialize
updateSelectionCount();

function getSidePanelSectionState() {
  return {
    "title": SCRIPT_TITLE,
    "rows": [
      {
        "type": "Label",
        "text": "Selection:"
      },
      {
        "type": "Container",
        "columns": [
          {
            "type": "TextBox",
            "value": countValue,
            "width": 1.0
          }
        ]
      },
      {
        "type": "Container",
        "columns": [
          {
            "type": "Button",
            "text": "Set lyrics to 'a'",
            "value": setLyricsButtonValue,
            "width": 1.0
          }
        ]
      }
    ]
  };
}
```

Documentation generated by [JSDoc 4.0.4](https://github.com/jsdoc3/jsdoc) on Thu Oct 09 2025 18:00:39 GMT+0900 (Japan Standard Time) using the [docdash](https://github.com/clenemt/docdash) theme.

Copyright 2020-2025 Dreamtonics Co., Ltd.