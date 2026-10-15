# RINAT ABU for iPhone

Native SwiftUI source for iOS 17+, version 0.3.0. Hebrew RTL, original branding, native navigation, product sheets, favourites, sharing, gifts, live public catalogue refresh and atomic offline cache. Bundled public snapshot contains 507 products.

## Build
On macOS with Xcode installed:

```sh
brew install xcodegen
cd ios
xcodegen generate
xcodebuild -project RinatAbu.xcodeproj -scheme RinatAbu -sdk iphonesimulator -configuration Debug -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
```

For device installation open the generated project in Xcode, choose the authorized Apple development team, configure signing and run on a registered iPhone. TestFlight/App Store distribution requires Apple Developer Program and App Store Connect setup. Do not commit keys/certificates or account credentials. A simulator app is not an installable iPhone IPA.

Payments open the official store, which this app never modifies. Embedded checkout, push notifications and checkout gift-card redemption are not implemented. The private web administration still requires the owner's account. iPhone app updates must use the selected Apple distribution channel; Android APK links are not iOS downloads.
