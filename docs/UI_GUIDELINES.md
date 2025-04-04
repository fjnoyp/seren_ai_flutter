# UI Guidelines

### Cross Device Responsivity
- `isWebVersion` is configured to not load web version on mobile browsers
- If you want to adapt the UI for small screens, use a `LayoutBuilder` with `constraints.maxWidth`
- If you want something to load in mobile browsers, you can use the native `isKWeb` variable

### Always highlight clickable elements
- Avoid using GestureDetector, use InkWell instead
- Use hover color to highlight text fields

### Always prevent duplicated tasks for inline creation
- When using `InlineTaskCreationWidget` in a list, make sure to return `SizedBox.shrink()` for the task that is currently being created
- The id of the task being created is stored in `curInlineCreatingTaskIdProvider`
