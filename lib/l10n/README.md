## Updating translations

1. Update the Strings to the `app_pt_PT.arb` or `app_pt_BR.arb` file.
1. Run `flutter pub get` to update the `app_localizations` files.
1. Run the app.


## Adding new Strings to the App

1. Add the string to the `app_en.arb` file.
1. Translate the string to the `app_pt_PT.arb` file.
1. Translate the string to the `app_pt_BR.arb` file.
1. Run `flutter pub get` to update the `app_localizations` files.
1. Run the app.

> **Note:** The `app_pt.arb` file is not used (other portuguese locales default to `pt_PT` instead), so it's not necessary to translate it. But the generator needs it to be present anyway.

## Placeholders, plurals, selects and more
See the [documentation](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#placeholders-plurals-and-selects) for more information.