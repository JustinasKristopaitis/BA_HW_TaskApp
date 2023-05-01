import Foundation

final class UserListViewModel: ObservableObject {
    private let contentLoader: ContentLoading
    private let contentCaching: ContentCaching
    
    init(
        contentLoader: ContentLoading,
        contentCaching: ContentCaching
    ) {
        self.contentLoader = contentLoader
        self.contentCaching = contentCaching
    }
    
    @Published var loadedPosts: [UserPost] = []
    @Published var loadedUsers: [UserDetails] = []
    
    @MainActor
    func loadPosts() async throws {
        do {
            let posts = try await contentLoader.loadUserPosts()
            loadedPosts = posts
        } catch {
            throw error
        }
    }
    
    func getUserName(forPostId id: Int) -> String {
        loadedUsers.first(where: { $0.id == id})?.name ?? ""
    }
    
    @MainActor
    func loadUserDetails() async throws {
        do {
            var uniqueUserIds = Set<Int>()
            for post in loadedPosts {
                uniqueUserIds.insert(post.userId)
            }
            
            let userDetails = try await contentLoader.loadUserDetails()
            loadedUsers = userDetails
        } catch {
            throw error
        }
    }
    
    @MainActor
    func loadPostsAndDetails() async throws {
        try await loadPosts()
        try await loadUserDetails()
    }
    
    @MainActor
    func reloadDate() async throws {
        try await contentCaching.resetCache()
        try await loadPosts()
        try await loadUserDetails()
    }
}
