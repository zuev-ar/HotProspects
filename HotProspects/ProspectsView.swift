//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Arkasha Zuev on 19.08.2021.
//

import SwiftUI
import CodeScanner
import UserNotifications

enum FilterType {
    case none, contacted, uncontacted
}

enum SortType {
    case none, name, email
}

struct ProspectsView: View {
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScaner = false
    @State private var showingActionSheet = false
    @State private var sort: SortType = .none
    
    let filter: FilterType
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return sortArray(unsortedProspects: prospects.people)
        case .contacted:
            return sortArray(unsortedProspects: prospects.people.filter { $0.isContacted })
        case .uncontacted:
            return sortArray(unsortedProspects: prospects.people.filter { !$0.isContacted })
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prospect in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        .contextMenu {
                            Button(prospect.isContacted ? "Mark uncontacted" : "Mark contacted") {
                                self.prospects.toggle(prospect)
                            }
                            if !prospect.isContacted {
                                Button("Remind me") {
                                    self.addNotification(for: prospect)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: prospect.isContacted ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.xmark")
                            .resizable()
                            .frame(width: 25, height: 22)
                            .foregroundColor(prospect.isContacted ? .blue : .black)
                            .padding([.trailing], 5)
                    }
                    .actionSheet(isPresented: $showingActionSheet) {
                        ActionSheet(title: Text("Sort list"), message: Text("Choose the way:"), buttons: [
                                .default(Text("None"), action: { self.sort = .none }),
                                .default(Text("Name"), action: { self.sort = .name }),
                                .default(Text("Email"), action: { self.sort = .email })
                            ])
                    }
                }
            }
            .navigationBarTitle(title)
            .navigationBarItems(leading: Button(action: {
                self.showingActionSheet = true
            }, label: {
                Image(systemName: "arrow.up.arrow.down.square")
                Text("Sort")
            }), trailing: Button(action: {
//                let prospect = Prospect()
//                prospect.name = "Paul Hudson"
//                prospect.emailAddress = "paul@hackingwithswift.com"
//                self.prospects.people.append(prospect)
                self.isShowingScaner = true
            }, label: {
                Image(systemName: "qrcode.viewfinder")
                Text("Scan")
            }))
            .sheet(isPresented: $isShowingScaner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "\(Int.random(in: 1..<100)). Paul Hudson\npaul\(Int.random(in: 1..<100))@hackingwithswift.com", completion: self.handleScan)
            }
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScaner = false
        
        switch result {
        case .success(let code):
            
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            
            self.prospects.add(person)
            
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    private func sortArray(unsortedProspects: [Prospect]) -> [Prospect] {
        switch sort {
        case .none:
            return unsortedProspects
        case .name:
            return unsortedProspects.sorted {
                $0.name < $1.name
            }
        case .email:
            return unsortedProspects.sorted {
                $0.emailAddress < $1.emailAddress
            }
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            
//            let triger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let triger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: triger)
            
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print(error?.localizedDescription ?? "D'oh")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
