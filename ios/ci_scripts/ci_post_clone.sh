#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# OLD - suddenly stopped working: https://github.com/flutter/flutter/issues/163198
# Install Flutter using git.
#git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
#export PATH="$PATH:$HOME/flutter/bin"

# NEW - Temporary solution?
# Install Flutter using curl instead of git
curl -sLO "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.29.0-stable.zip"
unzip -qq flutter_macos_3.29.0-stable.zip -d $HOME
export PATH="$PATH:$HOME/flutter/bin"


# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.

exit 0