# youth_card

Youth Card Mobile Application

## About

The Youth Card Mobile Application was created in the Erasmus+ funded Youth Card project.
It is written in Flutter/Dart and published for Android and iOS operating systems.
For more information, please visit the [Project Website](https://www.youthcard.eu) 

The modernization work is published in the private [app-youthcard](https://github.com/Innoventum-oy/app-youthcard) repository. See the [modernization notes](docs/modernization.md) for the toolchain, design, Core API integration, cache decision, and release workflow.

## Debugging

Open this folder in VS Code with the Dart and Flutter extensions installed. In **Run and Debug**, select **Youth Card (Chrome)** or **Youth Card (iOS Simulator)** and press **F5**. The iOS configuration starts the simulator if needed. It requires macOS with Xcode and an installed iOS simulator runtime.

For terminal debugging, use `flutter run -d chrome`. For iOS, start a simulator with `flutter emulators --launch apple_ios_simulator`, then use `flutter devices` to find its device ID and run `flutter run -d <device-id>`.
