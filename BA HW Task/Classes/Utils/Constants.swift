import Foundation

struct Constants {
    struct UserDetails {
        static func userDetailUrl(userId: Int) -> String {
            "https://jsonplaceholder.typicode.com/users/\(userId)"
        }
        static let entityName: String = "UserDetailsEntity"
    }
    struct UserPosts {
        static let postDetailUrl = "https://jsonplaceholder.typicode.com/posts"
        static let entityName: String = "UserPostEntity"
    }
}
