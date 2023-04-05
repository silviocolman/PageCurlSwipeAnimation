//
//  ContentView.swift
//  PageCurlSwipeAnimation
//
//  Created by Silvio Colmán on 2023-04-05.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("Peel Effect")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
