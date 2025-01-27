//
//  Settings.swift
//  platicador
//
//  Created by Miguel de Icaza on 3/21/23.
//

import Foundation
import SwiftUI

let openAIkeytag = "OpenAI-key"
func getOpenAIKey () -> String {
    let key = NSUbiquitousKeyValueStore.default.string(forKey: openAIkeytag) ?? ""
    
    print ("Key is: \(key)")
    return key
}

func setOpenAIKey (_ value: String) {
    NSUbiquitousKeyValueStore.default.set(value, forKey: openAIkeytag)
    NSUbiquitousKeyValueStore.default.synchronize()
}

#if os(macOS)
let showDockIconKey = "ShowDockIcon-key"

func getShowDockIcon() -> Bool {
    if NSUbiquitousKeyValueStore.default.object(forKey: showDockIconKey) == nil {
        return true
    }

    return NSUbiquitousKeyValueStore.default.bool(forKey: showDockIconKey)
}

func setShowDockIcon(_ showDockIcon: Bool) {
    NSUbiquitousKeyValueStore.default.set(showDockIcon, forKey: showDockIconKey)
    NSUbiquitousKeyValueStore.default.synchronize()
    setApplicationActivationPolicy()
}

func setApplicationActivationPolicy() {
    if getShowDockIcon() {
        NSApp.setActivationPolicy(.regular)
    } else {
        NSApp.setActivationPolicy(.accessory)
        NSApp.activate(ignoringOtherApps: true)
    }
}
#endif

class OpenAIKey: ObservableObject {
    @Published var key: String = getOpenAIKey()
}

var openAIKey = OpenAIKey ()

struct GeneralSettings: View {
    @Binding var settingsShown: Bool
    @Binding var temperature: Float
    @Binding var newModel: Bool
    @State var key = getOpenAIKey()
#if os(macOS)
    @State var showDockIcon = getShowDockIcon()
#endif
    var dismiss: Bool
    
    var body: some View {
        Form {
            Picker("Model", selection: $newModel) {
                Text("GPT-3.5-turbo").tag(false)
                Text("GPT-4").tag(true)
            }
            LabeledContent ("Temperature") {
                Slider(value: $temperature, in: 0.4...1.6, step: 0.2) {
                    EmptyView()
                } minimumValueLabel: {
                    Text("Focused").font(.footnote).fontWeight(.thin)
                } maximumValueLabel: {
                    Text("Random").font(.footnote).fontWeight(.thin)
                }
            }.padding([.leading, .trailing])
            VStack (alignment: .leading) {
                TextField ("OpenAI Key", text: $key)
                    .onSubmit {
                        setOpenAIKey(key)
                        openAIKey.key = key
                    }
                Text ("Create or get an OpenAI key from the [API keys](https://platform.openai.com/account/api-keys) dashboard.")
                    .foregroundColor(.secondary)
                    .font (.caption)
            }
            .padding ()
#if os(macOS)
            LabeledContent("Show Dock Icon") {
                Toggle(isOn: $showDockIcon) {
                    Text(" ")
                }
                .onChange(of: showDockIcon, perform: { newValue in
                    setShowDockIcon(newValue)
                })
            }.padding([.leading, .trailing])
#endif
            if dismiss {
                HStack {
                    Spacer ()
                    Button ("Ok") {
                        setOpenAIKey(key)
                        openAIKey.key = key
                        settingsShown = false
                    }
                    Spacer ()
                }
            }
        }
    }
}

struct iOSGeneralSettings: View {
    @Binding var settingsShown: Bool
    @Binding var temperature: Float
    @Binding var newModel: Bool
    var dismiss: Bool
    var body: some View {
        NavigationView {
            GeneralSettings(settingsShown: $settingsShown, temperature: $temperature, newModel: $newModel, dismiss: dismiss)
        }
        .navigationTitle("Settings")
    }
}
struct SettingsView: View {
    @Binding var settingsShown: Bool
    @Binding var temperature: Float
    @Binding var newModel: Bool
    var dismiss: Bool
    
    var body: some View {
        TabView {
            GeneralSettings (settingsShown: $settingsShown, temperature: $temperature, newModel: $newModel, dismiss: dismiss)
                .tabItem {
                    Label ("General", systemImage: "person")
                }
        }.frame (width: 350, height: 250)
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsShown: .constant (true), temperature: .constant(1.0), newModel: .constant(false), dismiss: false)
    }
}
