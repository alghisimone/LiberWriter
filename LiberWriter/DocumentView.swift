//
//  DocumentView.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 16/03/2025.
//

import SwiftUI

struct DocumentView: View {
    let fileURL: URL

    @State private var document: ODTFile?
    @State private var loadingError: String?
    @State private var isLoading = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading document…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let loadingError {
                ContentUnavailableView(
                    "Unable to Open Document",
                    systemImage: "exclamationmark.triangle",
                    description: Text(loadingError)
                )
            } else if let document {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        DocumentSummaryView(document: document, fileURL: fileURL)

                        Divider()

                        DocumentCanvasView(document: document)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(nsColor: .textBackgroundColor))
            } else {
                ContentUnavailableView(
                    "No Document Loaded",
                    systemImage: "doc.text",
                    description: Text("Select an OpenDocument text file to inspect its contents.")
                )
            }
        }
        .navigationTitle(documentTitle)
        .task(id: fileURL) {
            await loadDocument()
        }
    }

    private var documentTitle: String {
        if let title = document?.metadata.title, !title.isEmpty {
            return title
        }
        return fileURL.lastPathComponent
    }

    @MainActor
    private func loadDocument() async {
        isLoading = true
        loadingError = nil

        do {
            document = try ODTFile(fileURL: fileURL)
        } catch {
            document = nil
            loadingError = error.localizedDescription
        }

        isLoading = false
    }
}

private struct DocumentSummaryView: View {
    let document: ODTFile
    let fileURL: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(document.metadata.title ?? fileURL.deletingPathExtension().lastPathComponent)
                .font(.largeTitle)
                .fontWeight(.semibold)

            if let creator = document.metadata.creator, !creator.isEmpty {
                Text("Author: \(creator)")
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 180), alignment: .leading)
            ], alignment: .leading, spacing: 12) {
                SummaryChip(label: "MIME Type", value: document.mimetype)
                SummaryChip(label: "Manifest Entries", value: "\(document.manifest.fileEntries.count)")
                SummaryChip(label: "Styles", value: "\(document.styles.styles.count + document.styles.automaticStyles.count)")
                SummaryChip(label: "Resources", value: "\(document.resources.count)")
                SummaryChip(label: "Version", value: document.contentDocument.version ?? "Unknown")
                SummaryChip(label: "Path", value: fileURL.lastPathComponent)
            }
        }
    }
}

private struct SummaryChip: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .textSelection(.enabled)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct DocumentCanvasView: View {
    let document: ODTFile

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array((document.textBody?.blocks ?? []).enumerated()), id: \.offset) { _, block in
                    BlockView(block: block)
                }
            }
            .padding(36)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 14, y: 6)
        }
        .frame(maxWidth: 900, alignment: .leading)
    }
}

private struct BlockView: View {
    let block: ODTTextBlock

    var body: some View {
        switch block {
        case .heading(let heading):
            Text(attributedString(for: heading.content))
                .font(font(for: heading.level))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

        case .paragraph(let paragraph):
            Text(attributedString(for: paragraph.content))
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)

        case .list(let list):
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(list.items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1).")
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(item.blocks.enumerated()), id: \.offset) { _, nestedBlock in
                                BlockView(block: nestedBlock)
                            }
                        }
                    }
                }
            }

        case .table(let table):
            TableBlockView(table: table)

        case .section(let section):
            VStack(alignment: .leading, spacing: 10) {
                if let name = section.name, !name.isEmpty {
                    Text(name.uppercased())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                ForEach(Array(section.blocks.enumerated()), id: \.offset) { _, nestedBlock in
                    BlockView(block: nestedBlock)
                }
            }

        case .trackedChanges:
            EmptyView()

        case .generic(let node):
            if !node.normalizedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(node.normalizedText)
                    .italic()
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func font(for level: Int) -> Font {
        switch level {
        case 1: return .system(size: 28)
        case 2: return .system(size: 24)
        case 3: return .system(size: 20)
        default: return .headline
        }
    }

    private func attributedString(for inlineNodes: [ODTInlineNode]) -> AttributedString {
        var result = AttributedString()

        for node in inlineNodes {
            switch node {
            case .text(let text):
                result += AttributedString(text)

            case .span(let span):
                var spanString = attributedString(for: span.content)
                if let styleName = span.styleName?.lowercased() {
                    if styleName.contains("emphasis") {
                        spanString.inlinePresentationIntent = .emphasized
                    }
                    if styleName.contains("strong") {
                        spanString.inlinePresentationIntent = .stronglyEmphasized
                    }
                }
                result += spanString

            case .link(let link):
                var linkString = attributedString(for: link.content)
                if let href = link.href, let url = URL(string: href) {
                    linkString.link = url
                }
                result += linkString

            case .lineBreak:
                result += AttributedString("\n")

            case .tab:
                result += AttributedString("\t")

            case .spaces(let count):
                result += AttributedString(String(repeating: " ", count: max(count, 1)))

            case .noteCitation(let citation):
                var citationString = AttributedString("[\(citation)]")
                citationString.foregroundColor = .secondary
                result += citationString

            case .generic(let node):
                result += AttributedString(node.normalizedText)
            }
        }

        return result
    }
}

private struct TableBlockView: View {
    let table: ODTTable

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let name = table.name, !name.isEmpty {
                Text(name)
                    .font(.headline)
            }

            VStack(spacing: 0) {
                ForEach(Array(table.rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 0) {
                        ForEach(Array(expandedCells(in: row).enumerated()), id: \.offset) { _, cell in
                            Text(cell.blocks.map(\.plainText).joined(separator: "\n"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                                .border(Color.gray.opacity(0.25))
                                .textSelection(.enabled)
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func expandedCells(in row: ODTTableRow) -> [ODTTableCell] {
        row.cells.flatMap { cell in
            Array(repeating: cell, count: max(cell.repeatedColumns, 1))
        }
    }
}

#Preview {
    DocumentView(fileURL: URL(fileURLWithPath: "/tmp/sample.odt"))
}
