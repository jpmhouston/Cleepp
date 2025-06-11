<img src="Designs/Cleepp/Cleepp GitHub logo.png" alt="Logo"/>

[![Build Status](https://github.com/jpmhouston/Cleepp/actions/workflows/build.yml/badge.svg)](https://github.com/jpmhouston/Cleepp/actions/workflows/build.yml)
[![Downloads](https://img.shields.io/github/downloads/jpmhouston/Cleepp/total.svg)](https://github.com/jpmhouston/Cleepp/releases/latest)
[![Donate](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg)](https://www.buymeacoffee.com/bananameterlabs)

Batch Clipboard is a menu bar utility for macOS that adds the ability to copy multiple items
and then paste them in order elsewhere.

### About

Batch Clipboard is a fork of clipboard manager [Maccy](https://maccy.app) and it's aim isn't
to have all the capabilities of a full-featured clipboard history manager, but to provide
just this single multi-clipboard feature:

<kbd>CONTROL (^)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>C</kbd> to copy as many items as
you like from a source document, then\
<kbd>CONTROL (^)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>V</kbd> to paste each item in the
same order into your target document.

[Full documentation is here](https://batchclipboard.bananameter.lol).

The project was code-named "Cleepp" and that's reflected in the name of this repo and
throughout the source code.

Batch Clipboard is built to run optimally on both Intel and Apple Silicon, and is intended
to work on systems running OS versions as old as 2019's macOS Catalina 10.15, however it
will run best on the latest OS (as of this writing, macOS 15 Sequoia).
_Testing has not been comprehensive on those older systems, please report any issues to
[batchclipboard.support@bananameter.lol](mailto:batchclipboard.support@bananameter.lol)._

### Install

#### Download from GitHub

There will always be a free download on this repo's
[releases page](https://github.com/jpmhouston/Cleepp/releases/latest) with the complete and
unrestricted functionality mentioned above.

Download either the .zip or .dmg file. For the zip file, double-click to uncompress, drag
"Batch Cipboard.app" that results to /Applications (or wherever you decide to store your
installed applications).

For the disk image (dmg), double-click to mount and open its window, drag "Batch Cipboard.app"
in that window to /Applications, eject the disk image (in the Finder window sidebar, or
right-click and choose "Eject"), and finally trash the dmg file.

#### Install from the Mac App Store

The app is also available for no cost on the Mac App Store
[here](https://apps.apple.com/app/batch-clipboard/id6695729238) with the same features as
the free GitHub version. The Mac App Store version, however, has an in-app purchase allowing
users to support future development and unlocks few bonus features. Read more about those
bonus features [in the documenentaion]
(https://github.com/jpmhouston/Cleepp/wiki/Bonus-Features-for-the-Mac-App-Store-Version).

Future betas of the App Store version may be available from its TestFlight
[page](ttps://testflight.apple.com/join/epg3cusH), but we don't guarentee there will always be
a beta available that hasn't expired.

#### Install with Homebrew

As long as this app is hosted on a repo that's a fork of Maccy, Batch Clipboard cannot be
added to default homebrew tap. You need to add the current Bananameter Labs tap get the app
as a homebrew cask:

```bash
brew tap jpmhouston/bananameterlabs
brew install batch-clipboard
```

Later versions may be available without adding the above tap, and also the official
Bananameter Labs tap might change in the future. We apologize in advance for such things
still being in flux.

#### Build yourself

You can clone the project and build yourself using Xcode developer tools. This reproduces
exactly what we do to release to GitHub and the Mac App Store (although we use github
workflow scripts to also sign, notarize, upload, etc).

The project file is still named Maccy.xcodeproj (as inherited from our fork parent),
open that in Xcode and choose the build scheme "Cleepp" (the app's code name),
and then Project Menu > Run (ie. build and run). This will build and launch an unsigned
build of the app. Find "Batch Clipboard.app" among the build products (in Products group
within Xcode's sidebar) and copy to your Applications is you like, but there may be
hoops to jump through to run the unsigned (and un-notarized) app.

And this will use the debug configuration rather than release as these days it's trickier
to coax Xcode to do a release build and extract the resulting app. There's not much
difference between the the debug and release configurations.

Note: You should avoid turning on automtic Sparkle updates in the app settings when
using your own builds. You could also change the build setting in Xocde to disable Sparkle.
Do this by:

- opening the project itself from the Project Navigator ("Maccy")
- open the tab "Build Settings"
- find "Swift Compiler - Custom Flags"
- on the Debug line click, wait, click again (like editing names in the Finder) to
  edit and remove `ALLOW_SPARKLE_UPDATES`, ie. changing `CLEEPP ALLOW_SPARKLE_UPDATES DEBUG`
  to `CLEEPP DEBUG` (optionally remove it from the Release line as well)

_Also note: the scheme "Cleepp (App Store)" builds essentially the same app but with mentions
of bonus features and in-app purchases in the Intro window, and an added Settings panel for
making those in-app purchases but which won't work in a ad-hoc local build._

Alternately build from the command line instead of the Xcode app. In a terminal window, cd into the source directory and:

    xcodebuild clean build analyze -scheme Cleepp -configuration Release -derivedDataPath .
    ls "./Build/Products/Release/Batch Clipboard.app" # copy this to /Applications
    # to copy the app in the Finder reveal it using: open "./Build/Products/Release/"
    # feel free to use a derivedDataPath other than ".", then find the "Build" directory there

### Organization

For a time I was trying to keep in sync with Maccy so I could merge over bug fixes,
and so kept the same file structure, project file, and build targets.
I just added on top of (or more correctly in parallel to) those existing files and targets.
I was hoping to keep the original source buildable so that I could continue to run Maccy's
unit tests, however I don't know if that's worked, at this point I haven't been running them.

Source files for the business logic (History group, Clipboard.swift, CoreDataManager.swift)
used by Batch Clipboard targets and others with minor changes remain in the Maccy directory.
Those minor change are isolated with `#if CLEEPP`.

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

Upstream Maccy has now changed significantly since early 2024, and so keeping in sync is now
a bit of a lost cause. Future iterations of this app is likely to change this organization
completely and make it a more straightforward project and source file hierarchy. 

### Thank you & Acknowledgements

Please consider supporting development of this app by either the in-app purchase in the
App Store version, or with a [tip at buymeacoffee.com](https://www.buymeacoffee.com/bananameterlabs).
This would be greatly appreciated.

_Thanks of course to the creators of [Maccy](https://maccy.app) and its contributors. 
Please consider supporting the continued development of that upstream project with a
[donation to it also at buymeacoffee.com](https://www.buymeacoffee.com/p0deje)._

The Batch Clipboard icon was based on [Clipboard Icon](https://icon-icons.com/icon/clipboard/50424)
by [benjsperry](https://icon-icons.com/users/SIspiIUR5Ovh9CSybjNDC/icon-sets/).
Earlier animated GIF versions of the logo were created with [Drama](www.drama.app)
by Pixelcut, makers of [PaintCode](https://paintcode.app). I no longer use that animated
logo but still really like the stuff that make over there at Pixelcut. 

### License

[MIT](./LICENSE)
