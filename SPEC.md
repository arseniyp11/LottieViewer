The application should allow a user to:

Paste a Google Drive link containing a Lottie .json animation.

Download the animation.

Parse the downloaded JSON using the Lottie library.

Open a new screen.

Play and control the animation.

The project must use the MVVM architecture pattern.

The goal of this task is to practice:

Creating a SwiftUI project.

Adding a third-party Swift Package.

SwiftUI navigation.

MVVM architecture.

ObservableObject / state management.

Async networking with URLSession.

Error handling.

Working with JSON files.

Integrating UIKit-based components into SwiftUI.

Working with the Lottie animation library.

Expected Application Flow

Launch App
    ↓
Animation Import Screen
    ↓
Paste Google Drive Link
    ↓
Tap "Load Animation"
    ↓
Download JSON
    ↓
Parse Lottie Animation
    ↓
Open Player Screen
    ↓
Play Animation


1. Create a New Project

Create a completely new project in Xcode.

Use:

Platform: iOS
Template: App
Language: Swift
Interface: SwiftUI


Do not start from the existing sample project.

2. Add Lottie

Add the official Lottie iOS package using Swift Package Manager.

Package:

https://github.com/airbnb/lottie-ios


After adding the package, you should be able to use:

import Lottie


3. Use MVVM Architecture

Organize the project using this structure:

LottieViewer
│
├── App
│   └── LottieViewerApp.swift
│
├── Models
│   └── RemoteLottie.swift
│
├── Services
│   └── LottieLinkLoader.swift
│
├── ViewModels
│   ├── LinkImportViewModel.swift
│   └── AnimationPlayerViewModel.swift
│
└── Views
    ├── LinkImportScreen.swift
    ├── AnimationPreviewScreen.swift
    └── LottiePlayerView.swift


The important rule is:

View
 ↓
ViewModel
 ↓
Service
 ↓
Model


The View should not download files directly.

4. Create the Model

Create:

RemoteLottie.swift


It should describe a successfully downloaded animation.

Architecture example:

struct RemoteLottie {
    let animation: LottieAnimation
    let sourceURL: URL
    let fileName: String
}


You may add additional properties if needed.

For example:

file size

animation dimensions

duration

5. Create the Animation Loading Service

Create:

LottieLinkLoader.swift


This class/service is responsible for downloading and parsing the animation.

It should:

Receive a link as String.

Validate the link.

Detect whether it is a Google Drive link.

Extract the Google Drive file ID.

Convert the Google Drive share URL into a direct-download URL.

Download the file using URLSession.

Check the HTTP response.

Check that returned data is not empty.

Parse the downloaded data using Lottie.

Return RemoteLottie.

Architecture example:

protocol LottieLoading {
    func load(from link: String) async throws -> RemoteLottie
}


Implementation:

final class LottieLinkLoader: LottieLoading {
    // Networking and Lottie parsing
}


Do not put UI code inside this service.

6. Support Google Drive Links

The user should be able to paste a normal Google Drive share URL.

Example:

https://drive.google.com/file/d/FILE_ID/view?usp=sharing


Your application should find:

FILE_ID


and internally create a downloadable URL.

The user should not need to manually convert the URL.

For this assignment, the Google Drive file can be required to have:

Share
→ General access
→ Anyone with the link


Google Sign-In or Google authentication is not required.

7. Create LinkImportViewModel

Create:

LinkImportViewModel.swift


This ViewModel should control the first screen.

It should contain state similar to:

@Published var link: String
@Published var isLoading: Bool
@Published var errorMessage: String?
@Published var loadedAnimation: RemoteLottie?


It should also contain a method such as:

func loadAnimation()


loadAnimation() should:

Validate input
    ↓
Set isLoading = true
    ↓
Call LottieLinkLoader
    ↓
Receive RemoteLottie
    ↓
Update loadedAnimation

OR

Receive Error
    ↓
Update errorMessage


The networking code itself should remain inside LottieLinkLoader.

8. Create the First Screen

Design Reference: `/Users/arseniy/Desktop/LottieViewer/design/screen_1.png`  
(AI instruction: Always inspect `/Users/arseniy/Desktop/LottieViewer/design/screen_1.png` and reproduce the layout, spacing, colors, and components strictly according to the mockup).

Create:

LinkImportScreen.swift


This is the first screen the user should see.

The screen should contain:

Lottie Animation Viewer

[ Google Drive Link              ]

[ Paste from Clipboard ]

[ Load Animation ]

Loading...

Error message


The screen must use:

@StateObject


or the appropriate modern SwiftUI observable-state approach for the LinkImportViewModel.

Architecture example:

struct LinkImportScreen: View {
    @StateObject var viewModel = LinkImportViewModel()

    var body: some View {
        // UI only
    }
}


Do not put URLSession calls directly inside this View.

9. Add Paste From Clipboard

Add a button:

Paste from Clipboard


When the user presses it, copy the text from the iOS clipboard into the URL field.

You may use:

UIPasteboard.general.string


10. Add Loading State

When downloading the animation, display:

Loading...


or:

ProgressView()


Disable the Load button while the request is running.

The user should not be able to start the same download multiple times simultaneously.

11. Add Error Handling

Display a readable error message when loading fails.

Handle at least:

Empty link
Invalid URL
Invalid Google Drive URL
File is not publicly available
HTTP error
Empty downloaded file
Invalid JSON
Invalid Lottie animation


The application must not crash because an invalid link was entered.

12. Add Navigation

Use:

NavigationStack


When the animation loads successfully, open:

AnimationPreviewScreen


Flow:

LinkImportScreen
        ↓
LinkImportViewModel
        ↓
Animation successfully loaded
        ↓
AnimationPreviewScreen


13. Create AnimationPlayerViewModel

Create:

AnimationPlayerViewModel.swift


It should contain state related to animation playback.

For example:

@Published var isPlaying = true
@Published var progress: CGFloat = 0
@Published var speed: CGFloat = 1
@Published var loopEnabled = true


You may also store:

Selected background
Scrubbing state


Do not store networking logic inside this ViewModel.

14. Create LottiePlayerView

Create:

LottiePlayerView.swift


Lottie uses LottieAnimationView, which is a UIKit view.

Create a SwiftUI wrapper using:

UIViewRepresentable


Architecture example:

struct LottiePlayerView: UIViewRepresentable {
    let animation: LottieAnimation

    @Binding var isPlaying: Bool
    @Binding var progress: CGFloat

    var speed: CGFloat
}


LottiePlayerView should be responsible only for communication between:

SwiftUI
    ↕
LottieAnimationView


It should not:

Download files.

Parse Google Drive links.

Perform navigation.

15. Create Animation Preview Screen

Design Reference: `/Users/arseniy/Desktop/LottieViewer/design/screen_2.png`  
(AI instruction: Inspect `/Users/arseniy/Desktop/LottieViewer/design/screen_2.png` for controls layout, playback slider style, and preview area).

Create:

AnimationPreviewScreen.swift


The screen should receive the loaded RemoteLottie.

Display the animation using:

LottiePlayerView


The screen should contain these controls:

Play / Pause

Restart

Timeline

Playback Speed

Loop On / Off


16. Add Playback Speed

Allow the user to select:

0.5x
1x
2x


Optionally add:

0.25x


Changing this value should immediately change the Lottie animation speed.

17. Add Timeline

Add a Slider representing animation progress.

Expected range:

0.0 ---------------------- 1.0
Start                       End


The slider should move while the animation plays.

The user should also be able to move the slider manually to preview another part of the animation.

18. Add Loop Control

Add:

Loop On / Off


When enabled:

Animation ends
    ↓
Starts again


When disabled:

Animation ends
    ↓
Stops


19. Add Preview Background

Allow the animation to be previewed on at least:

Dark
Light


Optional:

Checkerboard


The checkerboard background is useful for testing animations containing transparency.

20. Optional Animation Information

Add an information button:

ⓘ


It can display:

File Name
Source URL
File Size
Animation Width
Animation Height
Duration
Frame Rate
Frame Count


This part is optional but recommended.

Final Architecture

The finished application should follow this relationship:

┌─────────────────────────┐
│    LinkImportScreen     │
│          View           │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  LinkImportViewModel    │
│       ViewModel         │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│    LottieLinkLoader     │
│        Service          │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│      RemoteLottie       │
│         Model           │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│ AnimationPreviewScreen  │
│          View           │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│ AnimationPlayerViewModel│
│       ViewModel         │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│    LottiePlayerView     │
│ UIViewRepresentable     │
└─────────────────────────┘


Minimum Requirements

The minimum working version must support:

New SwiftUI project created from scratch.

Lottie added using Swift Package Manager.

MVVM architecture.

Google Drive URL input.

Paste from clipboard.

Google Drive share-link conversion.

Async animation download.

Loading state.

Error handling.

Lottie JSON parsing.

Navigation to a second screen.

Lottie animation playback.

Play/Pause.

Restart.

Loop On/Off.

Playback speed.

Acceptance Criteria

A completely new Xcode project is created.

Project uses SwiftUI.

Lottie is added through Swift Package Manager.

Project follows MVVM architecture.

Models, Views, ViewModels, and Services have clear responsibilities.

Views do not contain networking logic.

User can enter a Google Drive link.

User can paste a link from the clipboard.

Normal Google Drive share links are supported.

Google Drive URL conversion happens automatically.

Animation is downloaded asynchronously.

A loading indicator is displayed during download.

Invalid links display an error.

Private/unavailable Google Drive files display an error.

Invalid Lottie JSON does not crash the application.

Successful download opens the player screen.

Animation starts playing.

Animation keeps its aspect ratio.

Play/Pause works.

Restart works.

Loop On/Off works.

Playback speed works.

Code is separated according to MVVM responsibilities.

Project builds without warnings or errors.

Expected Result

The final application should look conceptually like:

Screen 1

┌──────────────────────────────┐
│   Lottie Animation Viewer    │
│                              │
│ Google Drive Link            │
│ ┌──────────────────────────┐ │
│ │ https://drive.google...  │ │
│ └──────────────────────────┘ │
│                              │
│ [ Paste from Clipboard ]     │
│                              │
│ [     Load Animation     ]   │
└──────────────────────────────┘


After loading:

Screen 2

┌──────────────────────────────┐
│      Animation Preview       │
│                              │
│                              │
│       Lottie Animation       │
│                              │
│                              │
├──────────────────────────────┤
│     ▶ / ⏸     Restart        │
│                              │
│ ─────────●──────────────     │
│                              │
│ 0.5x  |  1x  |  2x          │
│                              │
│ Loop: ON                     │
└──────────────────────────────┘


Learning Goal

After completing this task, you should understand how data travels through an MVVM application:

User action
    ↓
View
    ↓
ViewModel
    ↓
Service
    ↓
Network
    ↓
Model
    ↓
ViewModel
    ↓
View updates automatically


Do not copy the existing sample application directly. Build the application step by step and use the sample only as a reference if you are stuck.

