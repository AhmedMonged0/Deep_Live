import SwiftUI

struct CrashReportView: View {
    @StateObject private var crashReporter = CrashReporter.shared
    @State private var showingDetails = false
    @State private var selectedReport: CrashReport?
    
    var body: some View {
        NavigationView {
            List {
                if crashReporter.getCrashReports().isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("No Crash Reports")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Your app is running smoothly!")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(crashReporter.getCrashReports(), id: \.id) { report in
                        CrashReportRow(report: report) {
                            selectedReport = report
                            showingDetails = true
                        }
                    }
                }
            }
            .navigationTitle("Crash Reports")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        crashReporter.clearCrashReports()
                    }
                    .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showingDetails) {
                if let report = selectedReport {
                    CrashReportDetailView(report: report)
                }
            }
        }
    }
}

struct CrashReportRow: View {
    let report: CrashReport
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(report.type.rawValue.capitalized)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(formatDate(report.timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                if let message = report.message {
                    Text(message)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let error = report.error {
                    Text(error)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconName: String {
        switch report.type {
        case .signal:
            return "exclamationmark.triangle.fill"
        case .exception:
            return "xmark.circle.fill"
        case .error:
            return "exclamationmark.circle.fill"
        case .fatal:
            return "xmark.octagon.fill"
        }
    }
    
    private var iconColor: Color {
        switch report.type {
        case .signal:
            return .orange
        case .exception:
            return .red
        case .error:
            return .yellow
        case .fatal:
            return .red
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CrashReportDetailView: View {
    let report: CrashReport
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Crash Report Details")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Report ID: \(report.id.uuidString)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Basic Info
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Basic Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        InfoRow(title: "Type", value: report.type.rawValue.capitalized)
                        InfoRow(title: "Timestamp", value: formatDate(report.timestamp))
                        InfoRow(title: "Thread", value: report.thread)
                        
                        if let signal = report.signal {
                            InfoRow(title: "Signal", value: "\(signal)")
                        }
                        
                        if let exception = report.exception {
                            InfoRow(title: "Exception", value: exception)
                        }
                        
                        if let error = report.error {
                            InfoRow(title: "Error", value: error)
                        }
                        
                        if let message = report.message {
                            InfoRow(title: "Message", value: message)
                        }
                        
                        if let context = report.context {
                            InfoRow(title: "Context", value: context)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Call Stack
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Call Stack")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(report.callStack.enumerated()), id: \.offset) { index, symbol in
                                    Text("\(index): \(symbol)")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Crash Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    CrashReportView()
}
