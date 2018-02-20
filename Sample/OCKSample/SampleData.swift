/*
 Copyright (c) 2017, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import ResearchKit
import CareKit

class SampleData: NSObject {
    
    // MARK: Properties

    /// An array of `Activity`s used in the app.
    let activities: [Activity] = [
        OutdoorWalk(),
        HamstringStretch(),
        TakeMedication(),
        BackPain(),
        Mood(),
        BloodGlucose(),
        Weight(),
        Caffeine()
    ]
    /**
     An `OCKPatient` object to assign contacts to.
     */
    
    var patient: OCKPatient
    
    /**
        An array of `OCKContact`s to display on the Connect view.
    */
    let contacts: [OCKContact] = [
        OCKContact(contactType: .careTeam,
            name: "Dr. Maria Ruiz",
            relation: "Physician",
            contactInfoItems: [OCKContactInfo.phone("888-555-5512"), OCKContactInfo.sms("888-555-5512"), OCKContactInfo.email("mruiz2@mac.com")],
            tintColor: Colors.blue.color,
            monogram: "MR",
            image: nil),
        
        OCKContact(contactType: .careTeam,
            name: "Bill James",
            relation: "Nurse",
            contactInfoItems: [OCKContactInfo.phone("888-555-5512"), OCKContactInfo.sms("888-555-5512"), OCKContactInfo.email("billjames2@mac.com")],
            tintColor: Colors.green.color,
            monogram: "BJ",
            image: nil),
        
        OCKContact(contactType: .personal,
            name: "Tom Clark",
            relation: "Father",
            contactInfoItems: [.phone("314-555-1234"),
                               .phone("314-555-4321"),
                               .email("ewodehouse@example.com"),
                               .sms("314-555-4321"),
                               .facetimeVideo("user@example.com", display: nil),
                               .facetimeVideo("3145554321", display: "314-555-4321"),
                               .facetimeAudio("3145554321", display: "314-555-4321"),
                               OCKContactInfo(type: .message, display: "ezra.wodehouse", actionURL: URL(string: "starstuffchat://ezra.wodehouse")!, label: "starstuff chat", icon: UIImage(named: "starstuff"))],
            tintColor: Colors.yellow.color,
            monogram: "TC",
            image: nil)


    ]
    
    /**
     Connect message items
     */
    
    let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
    let replyDateString = DateFormatter.localizedString(from: Date().addingTimeInterval(1000), dateStyle: .short, timeStyle: .short)
    var connectMessageItems = [OCKConnectMessageItem]()
    var contactsWithMessageItems = [OCKContact]()
    
    
    // MARK: Initialization
    
    required init(carePlanStore: OCKCarePlanStore) {

        let app =  OCKContact(contactType: .personal, name: "XClaim",relation: "App",contactInfoItems:[],tintColor: Colors.lightBlue.color,monogram: "XC",image: UIImage(named:"logo_xclaim"))

        let announcement = OCKConnectMessageItem(messageType: OCKConnectMessageType.received, sender: app, message: NSLocalizedString("Note that there are some hidden command line goodies here:\n\nemojis:\n:-1: | :m: | :man: | :machine: | :block-a: | :block-b: | :bowtie: | :boar: | :boat: | :book: | :bookmark: | :neckbeard: | :metal: | :fu: | :feelsgood:\n\ncommands:\n/msg | /call | /text | /skype | /kick | /invite\n\nmarkdown: \n* Bold | _ Italics | ~ Strike | ` Code | ``` Preformatted | > Quote",  comment: ""), icon: nil, dateString:dateString)

        let contact =  OCKContact(contactType: .personal, name: "Johan Sellström",relation: "Myself",contactInfoItems:[],tintColor: Colors.lightBlue.color,monogram: "TC",image: UIImage(named:"photo"))

        self.patient = OCKPatient(identifier: "patient", carePlanStore: carePlanStore, contact: contact, name: "Johan Sellström", detailInfo: nil, careTeamContacts: contacts, tintColor: Colors.lightBlue.color, monogram: "JD", image: UIImage(named:"photo"), categories: nil, userInfo: ["Age": "21", "Gender": "M", "Phone":"888-555-5512"])
        
        for contact in contacts {
            if contact.type == .careTeam {
                self.connectMessageItems = [announcement]
                contactsWithMessageItems.insert(contact, at: 0)
                self.connectMessageItems.insert(
                        OCKConnectMessageItem(messageType: OCKConnectMessageType.sent, sender: patient.contact, message: NSLocalizedString("I am feeling good after taking the medication! Thank you.",  comment: ""), icon: nil, dateString:dateString), at: 0)

                self.connectMessageItems.insert(
                    OCKConnectMessageItem(messageType: .received, sender: contact, message: NSLocalizedString("That is great! Keep up the good work.",  comment: ""), icon: nil, dateString: dateString), at: 0)
                break;
            }
        }
        
        super.init()

        // Populate the store with the sample activities.
        for sampleActivity in activities {
            let carePlanActivity = sampleActivity.carePlanActivity()
            
            carePlanStore.add(carePlanActivity) { success, error in
                if !success {
                    print(error!.localizedDescription)
                }
            }
        }
        
    }
    
    // MARK: Convenience
    
    /// Returns the `Activity` that matches the supplied `ActivityType`.
    func activityWithType(_ type: ActivityType) -> Activity? {
        for activity in activities where activity.activityType == type {
            return activity
        }
        
        return nil
    }
    
    func generateSampleDocument() -> OCKDocument {
        let subtitle = OCKDocumentElementSubtitle(subtitle: "First subtitle")
        
        let paragraph = OCKDocumentElementParagraph(content: "Lorem ipsum dolor sit amet, vim primis noster sententiae ne, et albucius apeirian accusata mea, vim at dicunt laoreet. Eu probo omnes inimicus ius, duo at veritus alienum. Nostrud facilisi id pro. Putant oporteat id eos. Admodum antiopam mel in, at per everti quaeque. Lorem ipsum dolor sit amet, vim primis noster sententiae ne, et albucius apeirian accusata mea, vim at dicunt laoreet. Eu probo omnes inimicus ius, duo at veritus alienum. Nostrud facilisi id pro. Putant oporteat id eos. Admodum antiopam mel in, at per everti quaeque. Lorem ipsum dolor sit amet, vim primis noster sententiae ne, et albucius apeirian accusata mea, vim at dicunt laoreet. Eu probo omnes inimicus ius, duo at veritus alienum. Nostrud facilisi id pro. Putant oporteat id eos. Admodum antiopam mel in, at per everti quaeque.")
            
        let document = OCKDocument(title: "Sample Document Title", elements: [subtitle, paragraph])
        document.pageHeader = "App Name: OCKSample, User Name: John Appleseed"
        
        return document
    }
}
