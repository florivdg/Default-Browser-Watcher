# Default Browser Watcher (macOS)

Watch changes to the default browser setting on macOS and submit to a Deno backend.

## What's this?

This tiny command line utility is used for displaying my current default browser on my personal website.  
It uses the [`NSWorkspace.shared.urlForApplication(toOpen:)`](https://developer.apple.com/documentation/appkit/nsworkspace/1533391-urlforapplication) API to get information about the current default web browser on my system.

It then submits the corresponding bundle identifier of the default browser application to a Deno backend, which can be used to feed this data to a widget displaying my current default browser on my website using WebSockets.

## Environment variables

Make sure to export these env variables to run the tool in the terminal:

```shell
export BROWSER_WATCHER_BACKEND_API_TOKEN="the_api_token"
```

## LaunchAgent

To run this thing in the background and keep it running after reboots, make it an `LaunchAgent`:

```shell
cp dev.flori.DefaultBrowserWatcher.agent.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/dev.flori.DefaultBrowserWatcher.agent.plist
launchctl start dev.flori.DefaultBrowserWatcher
```

The file above expects the tool to be installed at `/usr/local/bin/default-browser-watcher`.  
Also make sure to edit the environment variables within the `dev.flori.DefaultBrowserWatcher.agent.plist` accordingly.
