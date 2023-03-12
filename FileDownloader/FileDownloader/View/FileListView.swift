//
//  FileListView.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import SwiftUI

/// The main list of available for download files.
struct FileListView: View {
    let fileFetcher: FileFetcher
    let fileListFetcher: FileListFetcher
    let usageQuotaFetcher: UsageQuotaFetcher
    
    /// The file list.
    @State var files: [File] = []
    /// The server status message.
    @State var status = ""
    /// The file to present for download.
    @State var selected = File.empty {
        didSet {
            isDisplayingDownload = true
        }
    }
    @State var isDisplayingDownload = false
    
    /// The latest error message.
    @State var lastErrorMessage = "None" {
        didSet {
            isDisplayingError = true
        }
    }
    
    @State var isDisplayingError = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // The list of files available for download.
                List {
                    Section(content: {
                        if files.isEmpty {
                            ProgressView().padding()
                        }
                        ForEach(files) { file in
                            Button(action: {
                                selected = file
                            }, label: {
                                FileRowView(file: file)
                            })
                        }
                    }, header: {
                        Label(" FileDownloader", systemImage: "externaldrive.badge.icloud")
                            .font(.custom("SerreriaSobria", size: 27))
                            .foregroundColor(.accentColor)
                            .padding(.bottom, 20)
                    }, footer: {
                        Text(status)
                    })
                }
                .listStyle(.insetGrouped)
                .animation(.easeOut(duration: 0.33), value: files)
            }
            .alert("Error", isPresented: $isDisplayingError, actions: {
                Button("Close", role: .cancel) { }
            }, message: {
                Text(lastErrorMessage)
            })
            .task {
                guard files.isEmpty else { return }
                
                do {
                    // MARK: If we code try await fileListFetcher.fetchFileList() and try await usageQuotaFetcher.fetchUsageQuota(), both calls are asynchronous and, in theory, could happen at the same time. However, by explicitly marking them with await, the call to status() doesn’t start until the call to availableFiles() completes. Sometimes, you need to perform sequential asynchronous calls — like when you want to use data from the first call as a parameter of the second call. Both server calls can be made at the same time because they don’t depend on each other. But how can you await both calls without them blocking each other? Swift solves this problem with a feature called structured concurrency, via the async let syntax. Swift offers a special syntax that lets you group several asynchronous calls and await them all together.
                    async let files = try fileListFetcher.fetchFileList()
                    async let status = try usageQuotaFetcher.fetchUsageQuota()
                    
                    // MARK: To read the binding results, you need to use await. If the value is already available, we'll get it immediately. Otherwise, our code will suspend at the await until the result becomes available. To group concurrent bindings and extract their values, we have two options: Group them in a collection, such as an array OR Wrap them in parentheses as a tuple and then destructure the result.
                    let (filesResult, statusResult) = try await (files, status)
                    /// Update the view
                    self.files = filesResult
                    self.status = statusResult
                } catch {
                    lastErrorMessage = error.localizedDescription
                }
            }
            .navigationDestination(isPresented: $isDisplayingDownload) {
                DownloadView(file: selected).environmentObject(fileFetcher)
            }
        }
    }
}
