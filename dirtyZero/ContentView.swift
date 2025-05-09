//
//  ContentView.swift
//  dirtyZero
//
//  Created by Skadz on 5/8/25.
//

import SwiftUI
import DeviceKit
import notify

struct ContentView: View {
    let device = Device.current
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        HStack {
                            Spacer()
                            ZStack {
                                LogView()
                                    .padding(3)
                                    .frame(width: 340, height: 260)
                            }
                            Spacer()
                        }
                        .onAppear(perform: {
                            print("[*] Welcome to dirtyZero!\n[*] Running on \(device.systemName!) \(device.systemVersion!), \(device.description)")
                        })
                    } header: {
                        HStack {
                            Image(systemName: "terminal.fill")
                            Text("Logs")
                        }
                    }
                    Section {
                        VStack {
                            HStack {
                                Button(action: {
                                    dirtyZeroHide(path: "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe")
                                    dirtyZeroHide(path: "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe")
                                }) {
                                    HStack {
                                        Image(systemName: "dock.rectangle")
                                        Text("Hide Dock")
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(.green.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Button(action: {
                                    dirtyZeroHide(path: "/System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car")
                                }) {
                                    HStack {
                                        Image(systemName: "line.3.horizontal")
                                        Text("Hide Home Bar")
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(.green.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            Button(action: {
                                Alertinator.shared.prompt(title: "Enter custom path", placeholder: "/path/to/the/file/to/hide") { path in
                                    if let isEmpty = path, !path!.isEmpty {
                                        dirtyZeroHide(path: path!)
                                    } else {
                                        Alertinator.shared.alert(title: "Invalid path", body: "Enter an actual path to what you want to hide/zero.")
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: "terminal.fill")
                                    Text("Custom Path")
                                }
                                .foregroundStyle(.red)
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(.red.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    } header: {
                        HStack {
                            Image(systemName: "hammer.fill")
                            Text("Tweaks")
                        }
                    } footer: {
                        Text("All writes are done in memory, so if something goes wrong, you can force reboot.\n\nExploit discovered by Ian Beer of Google Project Zero. Created by the jailbreak.party team.")
                    }
                }
            }
            .navigationTitle("dirtyZero")
        }
    }
    
    func dirtyZeroHide(path: String) {
        let args = ["permasign", path]
        var argv = args.map { strdup($0) }
        
        _ = permasign(Int32(args.count), &argv)
    }
}

#Preview {
    ContentView()
}
