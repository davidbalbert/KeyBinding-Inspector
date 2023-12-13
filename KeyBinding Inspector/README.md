# KeyBinding Inspector

A tool to inspect [key bindings for the macOS text system](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/TextDefaultsBindings/TextDefaultsBindings.html).

## Download

You can [download the latest version](https://github.com/rails/rails/releases/latest) from the Releases page.

## Running the code

Copy Developer.xcconfig.example to Developer.xcconfig and set your development team ID and code signing identity.

## Contributing

Feel free to open an issue or pull request. If you're thinking about a large change, it's a good idea to open an issue to discuss it first.

## TODOs

- Editing key bindings. This requires custom Property List parsing and serialization so that we don't randomly reorder the key binding dictionary on every save.
- Nested dictionaries to support multi-keystroke bindings.
- Lots of polish.

## License

KeyBinding Inspector is copyright David Albert and released under the terms of the MIT License. See LICENSE.md for details.
