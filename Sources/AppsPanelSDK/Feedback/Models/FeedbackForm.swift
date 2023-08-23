//
//  FeedbackForm.swift
//  Notation
//
//  Created by AppsPanel on 24/03/2022.
//

import Foundation

struct Feedback: Encodable {
    
    let categoryID: FeedbackCategory.ID
    let comment: String
    let contact: String?
    
    enum CodingKeys: String, CodingKey {
        case categoryID = "categoryId"
        case comment
        case contact
    }
    
}
//    func isValid() -> Bool {
//        return subjectIsValid() && commentIsValid()
//    }
//}
//
//private extension FeedbackForm {
//
//    func subjectIsValid() -> Bool {
//        return !subject.trimmingCharacters(in: .whitespaces).isEmpty
//    }
//
//    func commentIsValid() -> Bool {
//        return !comment.trimmingCharacters(in: .whitespaces).isEmpty
//    }
//}
