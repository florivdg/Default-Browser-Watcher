# Default Browser Watcher (macOS)

Watch changes to the default browser setting on macOS and submit to Vercel Edge Config.

## What's this?

This tiny command line utility is used for displaying my current default browser on my personal website.  
It uses the [`NSWorkspace.shared.urlForApplication(toOpen:)`](https://developer.apple.com/documentation/appkit/nsworkspace/1533391-urlforapplication) API to get information about the current default web browser on my system.

It then submits the corresponding bundle identifier of the default browser application to [Vercel Edge Config](https://vercel.com/docs/concepts/edge-network/edge-config), which can be used to feed this data to a widget displaying my current default browser on my website.

## Environment variables

Make sure to export these env variables to run the tool.

```shell
export VERCEL_API_TOKEN="your_api_token"
export VERCEL_EDGE_CONFIG_ID="your_edge_config_id"
```
