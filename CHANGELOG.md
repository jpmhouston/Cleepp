Batch Clipboard Changelog

## version 1.0.3b1 (2025-07-03)

- Attempt to address crash: avoid impossible Swift range and log details to console.
- Attempt to address crash: ensure history menu item deletion calls menu code on main thread.
- Address some outstanding TODOs: upgrade print statements to os_log calls.
- Address some outstanding TODOs: handle cut, copy, paste within the filter text field (copies not added to the clipboard history).
- Address some outstanding TODOs: make more strings within source code localizable.

## version 1.0.2 (2025-06-08 🌎)

- Ship the 1.0.2b1 changes in time for WWDC 2025, defer fix for sporadic crash until more reports available.
- Changed the github workflow for the app store verison to also automatically deploy when triggered by pushed tag matching the project's version (matching non-app store workflow behavior).

## version 1.0.2b1 (2025-06-02)

- Fix deleting history and batch mode menu items, keep menu open afterwards.
- Widened key shortcut entry fields in the General tab of the Settings window.
- Corrected label in the Intro window's first page explaining how to re-open that window.
- Made outline in the app store verison's purchase confirmation sheet visible in both light & dark.
- Avoid emitting some spurious warnings into the system log.
- Improved build actions to log the application's build number and retain symbol files.

## version 1.0.1 (2025-05-01)

- Made menus use titlecase more consistently (lowercase "to", "with"), in sync with most recent documentation.
- Made the github CI scripts log the build number used as the "bundle version" value in the app's Info.plist, also visible in the Batch Clipboard about box.
- Updated the readme file included in the non-appstore disk image.

## version 1.0.1b13 (2025-04-28 🇨🇦)

- Increased size of button on page 2 of the intro that opens the authentication page in the Settings app, the Check button on page 3.
- Fixed how expiration date is calculated for previewing appstore build's bonus menu items, made cycling the checkbox not reset the date to another week out. Only the lower checkbox about turning off previews in a week, turning that off and on will reset the week.

## version 1.0.1b12 (2025-04-21 🥚)

- Expose Start Replaying and Advance (without pasting) menu items without holding shift key, made Start Replaying take place of Start Batch, separate out Cancel item.
- Fixed Advance menu item wasn't starting batch replay.
- Made non-appstore build action log the SHA256 hash of the zip file, needed for the homebrew cask file.

## version 1.0.1b11 (2025-04-18 🐰)

- Fixed alternate menu item mechanism not working for paste and new advance items, made it appear only when queue size >= 2 because if size = 1 then advancing is same as using the existing Cancel menu item.  
- Fixed minor error in github workflow for smoke builds.

## version 1.0.1b10 (2025-04-10)

- Added alternate menu item to start replaying the collected batch of clipboard items; beforehand the clipboard will always contain the most recently copied item, afterwards it contains the next in the batch to be pasted.
- Made the new Start Replaying Itemd and Show Intro menu items accessible with the shift key modifier, with shift-clicking the status menu icon now opening the menu rathen than behaving just like control-clicking.
- Simplified titles of some menu items to refer to Batch instead of Collecting / Replaying.
- When starting batch explicitly rather than automatically with the shortcut, no longer stay in batch mode when all items are pasted.
- Preview bonus menu items, visible but disabled and badged, visible by default in app store version for one week before they disappear. Checkboxes to control this added to the General section of the Settings window.
- Updated the Intro window to reflect changed Start Batcgh menu items, minor edits.
- Fixed issues with the close box of keyboard shortcut fields not working in the General panel of the Settings window. Upgrading this 3rd party library dependency required increasing the minimum OS supported from Mojave to Catalina.
- Improved slightly the layout in the General panel of the Settings window. Admittedly there's still the issue of unnecessary vertical white space when first opening the Settings window, subsequently fixed when switching panels and then returing to General.

## version 1.0.1b9 (2025-03-12)

- Added potential hotkey in the Setting window to start a batch, can use this to start and then copy or cut in your frontmost app as normal.
- Edited the github readme to include instructions to build from source.
- Updated application copyright text for the year 2025.  

## version 1.0.1b8 (2025-01-11 🏈🚀)

- Had to increase version number from 1.0 to 1.0.1 because reasons to do with the App Store, made it apply to non-AppStore build as well.
- Improved app icon.
- App Store build add encryption exempt key to its Info.plist.

## version 1.0b7 (2024-12-12)

- App Store build no longer shows link to the privacy policy in the purchase window, only the standard store EULA link is relevant there.
- App Store build adds button to the Intro widow that opens the standard store EULA.
- App Store build adds additional links to the About box to open the privacy policy and the standard store EULA.

## version 1.0b6 (2024-12-10)

- Minor edits to section that brags about open source in the Intro widow. 
- App Store build removes from the Intro widow references to a non-App Store build being downloadable from GitHub.
- App Store build shows links to standard store EULA and privacy policy in purchase window, button to open privacy policy also in the Intro widow.
- App Store build and the Xcode project have the now-unused framework SwiftyStoreKit fully removed.

## version 1.0b5 (2024-11-17)

- App Store build should now successfully fetch products from Apple servers and support making purchases.
- App Store build product details now displays the product titles not the descriptions.
- Only allow debug App Store builds to detect option key held when starting purchase and show dummy product details, "buy" without purchasing.
- Longer timeouts for some App Store transactions, to account for potential sign in dialogs, before spinner stops and "delayed" message shown.
- Improve wording of some delayed App Store transaction messages, message shown when cancelling purchase.
- Simplify copyright string in Info plist, omit Maccy author (still fully acknowledged in the credits file/window).
- App Store build get version number suffixes stripped (1.0b5 -> 1.0) to appease App Store Connect.
- App Store and non-App Store builds no longer lose entitlements in the GitHub build workflow resigning steps.

## version 1.0b4 (2024-10-31 🎃)

- Moved a setup step from the first time the menu bar is opened to right after launch, fixing a short delay on that first click.
- Intro wording changed to name the Privacy & Security sub-panel, Accessibility, that needs permission given.
- App Store build no longer hardcodes bonus features on.
- App Store build replaces temporary payment wrapper with new well-maintained one Flare frameowrk.
- App Store build has new products alert opened by the settings panel purchase button, supports one time payment and corporate yearly subscription products.
- App Store build settings panel purchase button hit with option key shows dummy products, its buy button makes clear they are a test and no money charged.
- App Store build pament code still a work in progress, still incomplete and untested with actual App Store products and purchasing.
- GitHub build workflow for Mac App Store builds.
- GitHub build workflows save results as artifacts, non-App Store build no longer adds untagged releases for this purpose.
- GitHub build workflows save full build logs as artifacts.
- Fixed Swift 6 compiler warnings.

## version 1.0b3 (2024-10-09)

Rather than continuing to roll polish updates into b2, released it and this new one in succession in order to test Sparkle updates with a signed app.

- Minor updates to wording in the about box, intro, and disk image read me file.
- If user is hiding the status item then show the settings window when the application is reopened (for when we added back the user setting for hiding the status icon).
- Remove logging from the application's Reopen callback.

## version 1.0b2 (2024-10-08)

- Made github CI script now do signing and notarization (non-appstore build).
- Fixed github CI script to really truly create universal app now (non-appstore build).
- Made github CI build with newer OS and tools.
- Made Intro and Licenses windows open in the current Mission Control space.
- Reworded Intro instructions for giving permissions in the Settings app.
- Minor edit to intro window text mentioning what's now called "batch mode".
- Changed description for history menu items settings control to not reference the storage panel maximum when that control not showm.
- For now only macOS 13 and later get login item checkbox in app's setting window, otherwise just a button to open system login items panel.
- Changed "Get" intent to accept an item number parameter and not a selection as in Maccy.
- Added some error logging, to be expanded later.
- Temporarily for this release log invocations of application's Reopen callback.
- Renamed release notes file to CHANGELOG.md and minor reformat, corresponding changes to github CI script.
- Minor edits to .dmg's readme file and to wiki.
- More fixes to Sparkle appcast, fingers crossed this works well now.
- Added funding file for github pointing at buymeacoffee.

## version 1.0b1 (2024-06-16)

- Renamed Cleepp to Batch Clipboard, revising app and menubar icon to clipboard with asterisk.
- Merge changes from Maccy, fixing many localizations that aren't used right now, better MS Word compatibility.
- Fixes to and expansion of app intents (needs testing).
- Fixes to Sparkle updates that weren't running fully at launch but instead when Settings were opened, alerts that were non-responsive.
- Reset Sparkle appcast file again making a hard break between pre-1.0 and 1.0, as update that changes app name and bundle id seems problematic. 

## version 0.9.9 (2024-06-04)

- Renamed "Purchase" settings panel to "Support Us" and changed icon from a coin to a gift, fixed a typo in the panel.
- Fixed height of several settings panels, removing white space at the bottom.
- Internal refactoring and UI test.
- Fixed use of Sparkle API, updated its plist entries and added an entitlement it needed.
- Fixed build number generated during build, removed Sparkle appcast file entries for those versions with a too-large build number (so must manually upgrade from 0.9.7/8 to a new version after all).
- Improve Sparkle setup in GitHub workflow, automating appcast file generation which required making the .zip archive contain only the .app.
- Made GitHub workflow build .dmg containing app and readme (now the disk image is the recommended file to download), other GitHub workflow fixes.

## version 0.9.8 (2024-05-18)

- Changed what is left on the clipboard when collecting clipboard items in queue mode, keep last copied item on clipboard and when Paste & Advance switch to desired item before invoking application's paste.
- Fixed bug where Delete History Item wasn't enabled sometimes, particularly when there's only one history item in the menu.
- Fixed bug affecting performace where all history items were added to the menu on first launch, instead of the count in the settings, most of which then have to be removed when the menu is first opened.
- Implemented some Cleepp specific UI Tests, adapting some Mappy tests and then adding ones for using queue copy and paste.

## version 0.9.7 (2024-05-14)

- Prevent double paste when using Cleepp shortcut, or paste while Paste All / Paste Multiple is occurring.
- Disable necessary menu items when Paste & Advance, or Paste All / Paste Multiple, are occurring.
- Improve timing when copying and pasting so they work more reliably in general.
- Changed old fix for Microsoft applications support so it only applied to those applications and doesn't apply to ones for which it causes problems (specifically LibreOffice).
- Attempt completion of Sparkle support, the next version after 0.9.7 should be offered as an automatic update.

## version 0.9.6 (2024-04-16)

- Fixed regression, replay from history wasn't putting head-of-queue item onto the clipboard.
- Fixed queue item menu separator was sometimes getting left behind.
- Made ARM also use a (shorter) delay between paste and advance in hopes of avoiding timing issue seen on Intel systems.
- Fixed misplaced delay when using Paste All / Paste Multiple, was letting queue advance to happen immediately after invoking paste after all.
- Created credits and licenses window containing app license, plus mentioning each swift package used and including their licenses.
- Simplified about box, added link that opens credits and licenses window.

## version 0.9.5 (2024-04-13)

- Increased the delay between issuing paste to the frontmost application and advancing the clipboard to the next item, present on Macs with Intel CPUs and for all systems in-between each paste when using Paste All.
- Used 3rd party library to draw animated GIF in the first page of the Intro window, hopefully that will work on all systems.

## version 0.9.4 (2024-04-07)

- New app icon, seen in the Finder and the about box (though your Mac may cache the old one until your next restart), and in the logo in the Intro window's first page, the GitHub README, and start of the documentation pages in the GitHub wiki. Unfortunately it's kind of a blurry mess in the small rendering in the Get Info window 😕 and I might end up changing it again.
- Made last page of the Intro window for non-App Store builds advertise the in-app purchase of the App Store build and provide button to go the app's page (although goes to a placeholder page in the GitHub wiki for now).
- Changed the support email address and documentation web address in the Intro window's last page and About box.
- Minor other changes to the Intro window's last page: fixed Copy Documentation Link button (shown when option key down) was opening it instead, added Make A Donation button opening my buymeacoffee.com link.
- Removed some unused Maccy assets.

Known issues: on either macOS versions older than 14.(tbd) Sonoma, or with less likelihood on all models with Intel CPUs, the animated GIF in the Intro window will be blank. The next release may simply show just the static logo on systems pre-Sonoma.

The app still needs to be opened the first time by right clicking the app icon and choosing Open from the contextual menu. Thank you for you patience for this last build before I deliver signed betas (or maybe one more subsequent build without).

## version 0.9.3 (2024-04-03)

- Attempted work-around for timing issues with first paste noticed on macOS 12 MacBook Air.
- Fixed menu behavior on pre-macOS14, workaround longstanding bugs, fix my logic errors.
- Stopped marking head-of-the-queue menu item (displayed at the bottom) with an underline on macOS before 14, instead put a separator line below it.
- Fixed history menu item deletion sometimes not working.
- Reordered Settings panels moving Appearance right next to General.
- Changed number of menu items in Appearance Settings panel to 20, and now say the right default in the tooltip.
- Permit entering a value of 0 for the number of menu items again, and altering the blurb below when it's 0.
- Fixed tabbing between fields in the Appearance Settings.
- Fixed preview popup to always include the line hinting how to copy a single history item.
- Fixed delete intent in case those still do something after migrating from Maccy to Cleepp.
- Improved wording in the third page of the intro, better directing what to do in System Settings/Prefs.
- Attempted work-arounds to fix the logo gif on the first page of the intro not animating on older OS versions.
- Inherit improvements to the Ignore settings panel.
- Minor code cleanup and merge upstream changes all having no effect.

## version 0.9.2 (2024-03-28)

- Restore English strings file accidentally removed while I was stripping the localizations.
- In the Intro window page 2, override the default button to be the one opening the System Settings app.
- Copying support email address by option-clicking the Intro window button was getting the mailto part also, fixed that.
- Using the Purchase or Restore buttons of the purchase settings panel now progresses through simulated states of the forthcoming purchase process.
- The purchase settings panel panel now has a link to web page about the bonus features.
- Fixed something causing settings window to frequently open with the wrong size.

Important: Found these builds I've been making myself have all been ARM-only, though the last two simplified variants done by GitHub actions perhaps were universal. Was finally able to test on an Intel MacBook Air and there's a timing issues with the first paste from the queue. These should be fixed in 0.9.3.

## version 0.9.1 (2024-03-25)

- Hide search field options from the settings for github build or when bonus features not purchased.
- Minor improvements to the Intro window, giving pages a little more horizontal space, polished some wording, removed localization email button for now.
- Stripped localizations for now.
- Setup github continuous integration on commits to main branch, and build release when a version is tagged. Script ready to sign and notarize though not doing so yet.
- Note: Withdrawing download b/c a mistake removed made while removing localizations ended up removing some English language text as well.

## version 0.9 (2024-03-23)

- Migrated all code that modifies Maccy to turn it into Cleepp out of the experimental branch, and in the process improve the organization of the modifications. This should allow the Maccy unit test to continue to run (though untested so far) and better support future merges of upstream changes (if so desired).
- If user had started ignoring clipboard events, reset to resume monitoring the clipboard when the user starts collecting a set of item (with the shortcut, the Copy & Collect menu item, the Start Collecting menu item, or control-clicking the menu icon).
- Minor tweak to the intro: if permission has already been granted in the system settings, omit a sentence on the first page that implies that setup is still needed.
- Minor improvement when checking for purchases on launch, omitting the process (and its related code) altogether in the direct download version.

## version 0.8.5 (2024-03-19)

- Moved bonus features to app store build, for now hardcoded to be as if features have been purchased. The separate simplified build is what will eventually be available on GitHub.
- Animated logo in the intro window and the project readme (build in Drama, from PixelCut the makers of PaintCode). Something like this animation was envisioned when the name "Cleepp" was chosen.
- Simplified preview popup more still, removing last copy time line since Cleepp doesn't collapse duplicates like Maccy does.
- Fixed case where menu items could get stuck in all-disabled state (after using a feature leads to the accessibility-permissions-not-granted alert opening).
- More edits and additions to the project readme file.

## version 0.8.4 (2024-03-17)

- Added Paste All / Paste Multiple menu item, mention of it in the purchases settings panel.
- Fixed command-delete to delete history menu item, regression introduced at some point where it no longer work whenever the history filter menu item was hidden. Feature is no longer isn't implemented by the input handling in that item's text field, but by a new menu item "Delete History Item" linked to "Clear". It's enabled only when highlighting a history menu item and so can only be activated with its keyboard shortcut.
- Additional minor fixes to menu behavior.
- Feature for disabling all menu items when the app is busy commanding the frontmost application to copy or paste (especially when using Paste All). A work in progress and might require more tweaks and fixes later but I think it's the right thing to do to prevent possibility of starting another action while one is currently still in progress.
- Removed the redundant copy count line from history menu item preview pop-up window.
- Under the hood preparations for in-app purchases, eg. bringing in libraries for validating purchase receipts.

## version 0.8.3 (2024-03-12)

- New purchases settings panel, not functional yet but demonstrates its 2 states, progress spinner and error text field.
- Some sizing and minor language changes in some of the other panels.
- Added new feature where menu shown entire history (can be long, have to scroll).
- Reduces default number of history items shown normally.
- Some fixes, refactoring, simplification of the invisible menu anchor items used when not macOS 13 and earlier.
- Fixed some other menu bugs relating to deleting menu items and operation.
- Fixed minor issues with the menu bar icons, which images are used in different states of the app and transitions between them.
- Fixed preview blurb which labels actions backwards.
- Minor changes to the intro.

## version 0.8.2 (2024-03-08)

- An intro window opens up the first time running the app to help walkthrough granting the permission needed in the System Settings app, plus giving essential information for basic usage.
- It can be opened again later via a link in the text of the about box.
- If trying to use the app before granting permission and the alert is shown, the app ends up in a more predictable state afterwards.
- Menubar icons are images again so they work in older OS versions.
- Has a new app icon that's distinct from Maccy's, though perhaps it will get replaced again before 1.0.

## version 0.8.1 (2024-03-01)

- Menu bar icon based on SF Symbols clipboard when running on macOS 13.0 Ventura and later, changes appearance when collecting & replaying clips
- Reversed the actions needing the option key when clicking on history items
- Prepare for replay from history, history filtering, and undo copy features to be bonus features
- Updates to repo's readme

## version 0.8 (2024-02-23)

Cleepp is fork of Maccy that adds a new mode to the clipboard letting you copy multiple times from one place then paste them all in order someplace else. Many features of Maccy have been stripped away for the sake of simplicity.

Built off a temporary development branch, will shortly be rebasing/redoing these changes off a later commit of the main branch with some improvements to the code along the way.
