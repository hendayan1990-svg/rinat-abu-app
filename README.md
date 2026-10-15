# RINAT ABU APP

Native Android boutique app, Hebrew RTL, Java. Android 8.0+.

[Download the latest APK](https://github.com/hendayan1990-svg/rinat-abu-app/releases/latest/download/RINAT-ABU.apk) · [Releases](https://github.com/hendayan1990-svg/rinat-abu-app/releases/latest)

## Version 0.3.0 preview
- Native bottom navigation, vector icons and gift illustration, burgundy/ivory visual identity.
- Animated screen entrance, favourite feedback and image fade-in. Respects disabled Android animations.
- Public product catalogue refresh at launch, manually, and every five foreground minutes; atomic offline cache.
- GitHub version checks at launch and on demand. Downloads and installation require the user's action.
- Official logo and product imagery; search, categories, sorting, favourites and sharing.

The official website is never modified. Purchases open the official store in the browser. Embedded checkout, native push and integrated gift-card redemption are not implemented. Private web admin needs the owner's sign-in. Build and signature checks pass; this preview has not been run on a phone/emulator.

## Build and release
Run `python build.py` on the configured Windows development computer. Android SDK 36 and JDK 21 are required; edit local paths if necessary.

Preserve the existing `rinat-preview.keystore` on the development computer: Android upgrades require the same package and signer. The development key is never included in the repository. Do not regenerate it for updates. This is preview signing, not production store signing.

For future releases, increment AndroidManifest.xml versionCode/versionName, MainActivity displayed/current comparison version, AppUpdates user-agent, and build.py output filename. Run the build, validate it, then publish using GitHub CLI with the APK asset named `RINAT-ABU.apk`. Use semantic `vMAJOR.MINOR.PATCH` release tags. The stable download URL points to the newest release; users keep their local favourites on an in-place update. Current update polling selects GitHub's latest non-prerelease release; previews are clearly marked in title and notes.

No administrator password, payment secret or signing key belongs in source control.
