//
//  Prospect.swift
//  HotProspects
//
//  Created by Arkasha Zuev on 19.08.2021.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
}

class Prospects: ObservableObject {
    static let saveKey = "SavedData"
    
    @Published private(set) var people: [Prospect]
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    private static func getDocumentsDirectoriy() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func save() {
        do {
            let fileName = Prospects.getDocumentsDirectoriy().appendingPathComponent(Prospects.saveKey)
            let data = try JSONEncoder().encode(self.people)
            try data.write(to: fileName, options: [.atomic, .completeFileProtection])
        } catch {
            print(error.localizedDescription)
        }
    }
    
//    private func save() {
//        if let encoded = try? JSONEncoder().encode(people) {
//            UserDefaults.standard.set(encoded, forKey: Prospects.saveKey)
//        }
//    }
    
    init() {
        let fileName = Prospects.getDocumentsDirectoriy().appendingPathComponent(Prospects.saveKey)
        if let data = try? Data(contentsOf: fileName) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                self.people = decoded
                return
            }
        }
        
        self.people = []
        
//        if let data = UserDefaults.standard.data(forKey: Prospects.saveKey) {
//            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
//                self.people = decoded
//                return
//            }
//        }
    }
}
