<img src="Designs/Cleepp/Cleepp GitHub logo.png" alt="Logo"/>

[![Build Status](https://github.com/jpmhouston/Cleepp/actions/workflows/build.yml/badge.svg)](https://github.com/jpmhouston/Cleepp/actions/workflows/build.yml)
[![Downloads](https://img.shields.io/github/downloads/jpmhouston/Cleepp/total.svg)](https://github.com/jpmhouston/Cleepp/releases/latest)
[![Donate](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg)](https://www.buymeacoffee.com/bananameterlabs)

Batch Clipboard is a menu bar utility for macOS that adds the ability to copy multiple
items and then paste them in order elsewhere.

### About

Batch Clipboard is a fork of clipboard manager [Maccy](https://maccy.app) and it's aim
isn't to have all the capabilities of a full-featured clipboard history manager,
but to provide just this single multi-clipboard feature:

<kbd>CONTROL (^)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>C</kbd>
to copy as many items as you like from a source document, then
<kbd>CONTROL (^)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>V</kbd>,
then to paste each item in same order in your target document.

[Full documentation is here](https://batchclipboard.bananameter.lol).

The project was code-named "Cleepp" and that's reflected in the name of the repo and
throughout the source code.

### Install

#### Prebuilt versions

Download the latest version from the
[releases](https://github.com/jpmhouston/Cleepp/releases/latest) page,
or the Mac App Store.

The Mac App Store version, when available, will provide a few bonus features
via an in-app purchase, but otherwise operates the same as the
direct download version.

Batch Clipboard is built to run optimally on both Intel and Apple Silicon, and is intended
to work on systems as old as 2018's macOS Mojave 10.14, however runs best
on the latest, macOS 14 Sonoma.
_Beta testers are needed to validate correct operation on those older systems,
please [download](https://github.com/jpmhouston/Cleepp/releases/latest) a pre-release build and report any issues to
[batchclip.support@bananameter.lol](mailto:batchclip.support@bananameter.lol)._

#### Build your own

The project file is still named Maccy.xcodeproj (as inherited from our fork parent),
open that in xcode and choose the build scheme "Cleepp" (the app's code name),
and then Project Menu > Run (ie. build and run). This will build and launch an unsigned
build of the app. Find "Batch Clipboard.app" among the build products (in Products group
within Xcode's sidebar) and copy to your Applications is you like, but there may be
hoops to jump through to run the unsigned (and un-notarized) app.

And this will use the debug configuration rather than release as these days it's trickier
to coax Xcode to do a release build and extract the resulting app. There's not much
difference between the the debug and release configurations.

(TBD: how to build with Sparkle updates disabled)

_Note that the scheme "Cleepp (App Store)" builds essentially the same app but with mentions
of bonus features and in-app purchases in the Intro window, and an added Settings panel for
making those in-app purchases but which won't work in a ad-hoc local build._

Alternately build from a terminal, cd into the source directory and:

    xcodebuild clean build analyze -scheme Cleepp -configuration Release -derivedDataPath .
    # or use some derivedDataPath other than "." in which case find Build there instead of "./Build"  
    ls ./Build/Products/Release/"Batch Clipboard.app" # copy this to /Applications or wherever

### Organization

For a time I was trying to keep in sync with Maccy so I could merge over bug fixes,
and so kept the same file structure, project file, and build targets.
I just added on top of (or more correctly in parallel to) those existing files and targets.
I was hoping to keep the original source buildable so that I could continue to run Maccy's
unit tests, however I don't know if that's worked, at this point I haven't been running them.

Source files for the business logic (History group, Clipboard.swift, CoreDataManager.swift)
used by Batch Clipboard targets and others with minor changes remain in the Maccy directory.
Those minor change are isolated with "#if CLEEPP".

For major additions and customizations to Maccy, I have a peer of the Maccy source folder,
Cleepp, with a parallel hierarchy. For example Menu.swift is completely replaced by a source
file with the same name in the Cleepp hiearchy, however Maccy/Menu/MenuController.swift and
some other parts of Maccy/Menu are used almost as-is.

Another way I've overriden Maccy that might be confusing is in the Maccy singleton object,
containing central logic and some global state. This file is used by Cleepp with some
ifdef'ed alterations, but also I've made extensions to it in the Cleepp source hiearchy.
The somewhat confusing thing I've done is added a typealias for the Maccy class named Cleepp.
So where you see extensions and references to the Cleepp object, and files named
Cleepp+blah.swift, this is the same Maccy singleton. 

Upstream Maccy has now changed significantly in 2024, and so keeping in sync is now a bit
of a lost cause. Future iterations of this app is likely to change this organization
completely and make it a more straightforward project and source file hierarchy. 

### Thank you & Acknowledgements

Please consider supporting development of this app by either the
in-app purchase in the App Store version, or with a
[tip at buymeacoffee.com](https://www.buymeacoffee.com/bananameterlabs).
This would be greatly appreciated.

_Thanks of course to the creators of [Maccy](https://maccy.app) and its contributors. 
Please consider supporting the continued development of that upstream project with a
[donation to it also at buymeacoffee.com](https://www.buymeacoffee.com/p0deje)._

The Batch Clipboard icon was based on [Clipboard Icon](https://icon-icons.com/icon/clipboard/50424)
by [benjsperry](https://icon-icons.com/users/SIspiIUR5Ovh9CSybjNDC/icon-sets/).
Earlier animated GIF versions of the logo were created with [Drama](www.drama.app)
by Pixelcut, makers of [PaintCode](https://paintcode.app). I no longer use that
animated logo but still really like the stuff that make over there at Pixelcut. 

### License

[MIT](./LICENSE)
