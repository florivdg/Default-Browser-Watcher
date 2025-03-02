//
//  main.swift
//  Default Browser Watcher
//
//  Created by Florian van der Galiën on 10.03.23.
//

import Foundation
import AppKit

// Grab the backend API token from environment
guard let apiToken = ProcessInfo.processInfo.environment["BROWSER_WATCHER_BACKEND_API_TOKEN"] else {
    print("Missing env var \"BROWSER_WATCHER_BACKEND_API_TOKEN\". Bye bye...")
    exit(0)
}

// Backend API endpoint
let apiEndpoint = "https://van-der-hub.flori.dev/browser/set"

// Set the URL of the webhook to submit the default browser changes to
let webhookURL = URL(string: apiEndpoint)!

// Shared workspace
let workspace = NSWorkspace.shared

// Set up a JSON encoder for encoding the default browser data as JSON
let jsonEncoder = JSONEncoder()

// Set up a session configuration with a short timeout interval
let sessionConfig = URLSessionConfiguration.default
sessionConfig.timeoutIntervalForResource = 10

// Set up a session with the configured session configuration
let session = URLSession(configuration: sessionConfig)

// The web url to check against
let webURL = URL(string: "https://flori.dev")!

// Get the URL of the current default browser
var oldURL = workspace.urlForApplication(toOpen: webURL)

// Set up a signal handler for the INT signal (Ctrl+C)
signal(SIGINT) { signal in
    print("\nBye bye...")
    exit(0)
}

print("Watching for changes in the default browser setting...")

func getMacModelIdentifier() -> String? {
    // Determine the size of the data needed.
    var size: Int = 0
    sysctlbyname("hw.model", nil, &size, nil, 0)
    
    // Create a buffer with the appropriate size.
    var model = [CChar](repeating: 0, count: size)
    
    // Get the model identifier.
    let result = sysctlbyname("hw.model", &model, &size, nil, 0)
    if result == 0 {
        return String(cString: model)
    } else {
        return nil
    }
}

while true {
    // Get the URL of the current default browser
    let newURL = workspace.urlForApplication(toOpen: webURL)
    
    // Check if the URL has changed
    if newURL != oldURL {
        
        // If the URL has changed, create a dictionary with the new default browser data
        let bundle = Bundle(url: newURL!)
        let browserIdentifier = bundle?.bundleIdentifier ?? "unknown"
        let machine = getMacModelIdentifier() ?? "undetermined"
        let defaultBrowserData = [
            "browser": browserIdentifier,
            "machine": machine
        ]
        
        // Encode the default browser data as JSON
        let jsonData = try! jsonEncoder.encode(defaultBrowserData)
        
        // If the URL has changed, print a message and do something
        print("Default browser has changed to \(browserIdentifier) on \(machine)")
        
        // Create a POST request with the JSON data
        var request = URLRequest(url: webhookURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Submit the request asynchronously
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error submitting default browser data:", error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Default browser data submitted successfully.")
            } else {
                if let data = data, let output = String(data: data, encoding: .utf8) {
                    print(output)
                }
            }
        }
        task.resume()
    }
    
    // Set the old URL to the current URL
    oldURL = newURL
    
    // Wait for 1 second before checking again
    sleep(1)
}
