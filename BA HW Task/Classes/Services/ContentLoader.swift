import Foundation

protocol ContentLoading {
    func loadUserPosts() async throws -> [UserPost]
    func loadUserDetails() async throws -> [UserDetails]
}

final class ContentLoader: ContentLoading {
    private let contentCacher: ContentCaching
    private let dataFetcher: DataFetching
    
    init(contentCacher: ContentCaching, dataFetcher: DataFetching) {
        self.contentCacher = contentCacher
        self.dataFetcher = dataFetcher
    }
    
    func loadUserPosts() async throws -> [UserPost] {
        do {
            let userPosts = try await contentCacher.loadUserPosts()
            return userPosts
        } catch {
            let posts = try await dataFetcher.fetchUserPosts()
            try await contentCacher.saveUserPosts(posts: posts)
            return posts
        }
    }
    
    func loadUserDetails() async throws -> [UserDetails] {
        do {
            let userDetails = try await contentCacher.loadUserDetailsFromCache()
            return userDetails
        } catch {
            let userPosts = try await loadUserPosts()
            let uniqueUserIds = getUniqueUserIds(from: userPosts)
            let userDetails = try await fetchUserDetails(for: uniqueUserIds)
            try await contentCacher.saveUserDetails(userDetailsArray: userDetails)
            return userDetails
        }
    }
    
    private func getUniqueUserIds(from userPosts: [UserPost]) -> [Int] {
        var uniqueUserIds = Set<Int>()
        for post in userPosts {
            uniqueUserIds.insert(post.userId)
        }
        return Array(uniqueUserIds)
    }
    
    private func fetchUserDetails(for userIds: [Int]) async throws -> [UserDetails] {
        var userDetails: [UserDetails] = []
        for id in userIds {
            let userDetail = try await dataFetcher.fetchUserDetails(userId: id)
            userDetails.append(userDetail)
        }
        return userDetails
    }
}
