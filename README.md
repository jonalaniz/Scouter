# Scouter

**Scouter** is an open-source macOS menu bar app designed to help you stay on top of your [FreeScout](https://freescout.net/) mailbox. Written entirely in Swift, Scouter provides a convenient way to monitor new messages and interact with your mailbox right from your menu bar.

<p align="center">
    <img alt="Scouter Screenshot" src="http://www.jonalaniz.com/wp-content/uploads/2024/12/scouter-1.0.9.png" width="640">


## Features
- **Monitoring**: Select a FreeScout mailbox for Scouter to continually check for new messages.
- **Overview**: Clicking the scouter icon shows the latest messages in each mailbox folder.
- **Conversation Previews**: Hovering over a message shows a preview of the message contents
- **Actions**: Click on any message to open it in your default web browser.
- **Updates**: Scouter implements Sparkle for automatic update fetching and installing.

## Requirements
- macOS 14.0 (Sonoma)
- FreeScout instance with the API & Webhooks Module.
  - More information on API & Webhooks can be found [here](https://freescout.net/module/api-webhooks/).

## Installation
- Latest binary can be found in the releases section on GitHub.
- Once installed, application automatically check for updates.

Scouter was built on Xcode 16 with Swift 5. It has no dependencies, so you should be able to just clone and run.

## Setup
1. Add your FreeScout instance URL and API in Scouter Preferences.
2. Click 'Get Mailboxes'.
3. Select the mailbox you would like to monitor and the interval to check for new conversations.
4. Uncheck any folders you wish to ignore *(optional)*.

## Contributions
Contributions are welcome, feel free to submit issues or pull requests to help improve Scouter.

## Support
This is currenlty all I got going in my life, so why not buy me some coffee to keep me going?

<a href="https://www.buymeacoffee.com/jonalaniz" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png" alt="Buy Me A Coffee" height="41" width="174"></a>
