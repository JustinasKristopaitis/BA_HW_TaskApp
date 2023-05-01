import Foundation

protocol DataFetching {
    func fetchUserDetails(userId: Int) async throws -> UserDetails
    func fetchUserPosts() async throws -> [UserPost]
}

struct DataFetcher: DataFetching {
    let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func fetchUserDetails(userId: Int) async throws -> UserDetails {
        guard let url = URL(string: Constants.UserDetails.userDetailUrl(userId: userId)) else {
            throw HWError.badURL
        }
        
        let (data, _) = try await urlSession.data(from: url)
        return try JSONDecoder().decode(UserDetails.self, from: data)

    }
    
    func fetchUserPosts() async throws -> [UserPost] {
        guard let url = URL(string: Constants.UserPosts.postDetailUrl) else {
            throw HWError.badURL
        }
        
        let (data, _) = try await urlSession.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([UserPost].self, from: data)
    }
}
