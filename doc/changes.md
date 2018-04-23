## 1.5.2

- Use Map to track injected instances under cpp as WeakMap is not implemented.

## 1.5.1

- Add @:keep to all injected fields

## 1.5.0

- Removed macro approach to DCE support

## 1.4.0

- Internal refactor, dce support, removed dependencies, only assert in debug.
- Rename RTTI to something Macro, more cleanup.
- Moved keep to minject.Macro
- Extract ClassMap so that mmvc can use it
- Update property syntax for Haxe 3

## 1.3.0

- Attempting to add a little more detail around warning message for duplicate rule mappings
- Add a little more context to the toString of injection result
- Add InjectorConfig.toString and class this from InjectOtherRuleResult.toString
- Make result private again
- Remove some diffs
- Upgraded dependencies
- Merge pull request #10 from massiveinteractive/fix/improve-duplicate-rule-warning
- Adds support for recursive singleton injection (Closes #12)
- Added hamcrest dependency (shakes fist at munit)
- Fix for Haxe 3.1.
- Merge pull request #14 from jasononeil/master
- Another PHP fix
- Merge pull request #15 from jasononeil/master
- Update documentation style and haxelib info in prep for release.

1.0.0 Initial release
1.1.0 Removed inline mcore/mdata classes, added dependencies.
1.1.1 Fixes possible memory leak, removes inline dependencies

* Fixes possible memory leak in attendedToInjectees under JS.

1.2.0 Adds support for Haxe 3
1.2.1 Fixes compile time macro error under Haxe 3 rc2
1.2.2 Added haxelib.json
1.2.3 Fix issue where macros couldn't be used with the Injector.
