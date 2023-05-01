import Foundation

struct UserPost: Codable, Identifiable, Equatable {
    var id: String { title + "\(userId)" }
    var title: String
    var userId: Int
}
