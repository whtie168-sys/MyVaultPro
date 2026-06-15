//
//  SearchViewModel.swift
//  MyVaultPro
//
//  Global search across all modules with real-time filtering.
//

import SwiftUI
import Combine

struct SearchResult: Identifiable {
    enum Module: String {
        case asset = "Asset"
        case collection = "Collection"
        case document = "Document"
        case subscription = "Subscription"
        case maintenance = "Maintenance"
    }
    let id: UUID
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let module: Module
}

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""

    func results(from store: DataStore) -> [SearchResult] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }

        var results: [SearchResult] = []

        for a in store.assets where matches(q, a.name, a.category, a.serialNumber, a.notes) {
            results.append(SearchResult(id: a.id, title: a.name, subtitle: "\(a.category) · Asset",
                                        icon: a.categoryEnum.icon, tint: a.categoryEnum.tint, module: .asset))
        }
        for c in store.collections where matches(q, c.name, c.category, c.notes) {
            results.append(SearchResult(id: c.id, title: c.name, subtitle: "\(c.category) · Collection",
                                        icon: c.categoryEnum.icon, tint: c.categoryEnum.tint, module: .collection))
        }
        for d in store.documents where matches(q, d.title, d.category, d.notes) {
            results.append(SearchResult(id: d.id, title: d.title, subtitle: "\(d.category) · Document",
                                        icon: d.categoryEnum.icon, tint: d.categoryEnum.tint, module: .document))
        }
        for s in store.subscriptions where matches(q, s.serviceName, s.category, s.notes) {
            results.append(SearchResult(id: s.id, title: s.serviceName, subtitle: "\(s.category) · Subscription",
                                        icon: s.categoryEnum.icon, tint: s.categoryEnum.tint, module: .subscription))
        }
        for m in store.maintenance where matches(q, m.itemName, m.type, m.notes) {
            results.append(SearchResult(id: m.id, title: m.itemName, subtitle: "\(m.type) · Maintenance",
                                        icon: m.typeEnum.icon, tint: m.typeEnum.tint, module: .maintenance))
        }
        return results
    }

    private func matches(_ query: String, _ fields: String?...) -> Bool {
        for field in fields {
            if let field, field.lowercased().contains(query) { return true }
        }
        return false
    }
}
