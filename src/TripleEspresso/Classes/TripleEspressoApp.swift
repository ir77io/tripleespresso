//
//  TripleEspressoApp.swift
//  TripleEspresso
//
//  Created by Dominic Rodemer on 11.11.25.
//

import SwiftUI

@main
struct TripleEspressoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
