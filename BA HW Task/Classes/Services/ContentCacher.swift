import Foundation
import CoreData

protocol ContentCaching {
    func loadUserDetailsFromCache() async throws -> [UserDetails]
    func loadUserPosts() async throws -> [UserPost]
    func saveUserDetails(userDetailsArray: [UserDetails]) async throws
    func saveUserPosts(posts: [UserPost]) async throws
    func resetCache() async throws
}

final class ContentCacher: ContentCaching {
    private let cache = Cache()
    
    func loadUserDetailsFromCache() async throws -> [UserDetails] {
        let cachedData = try await cache.load(entityName: Constants.UserDetails.entityName)
        let decodedData = try JSONDecoder().decode([UserDetails].self, from: cachedData)
        return decodedData
    }
    func loadUserPosts() async throws -> [UserPost] {
        let cachedData = try await cache.load(entityName: Constants.UserPosts.entityName)
        let decodedData = try JSONDecoder().decode([UserPost].self, from: cachedData)
        return decodedData
    }
    
    func saveUserDetails(userDetailsArray: [UserDetails]) async throws {
        let entityName = Constants.UserDetails.entityName
        let encodedData = try JSONEncoder().encode(userDetailsArray)
        try await cache.save(entityName: entityName, data: encodedData)
    }
    
    func saveUserPosts(posts: [UserPost]) async throws {
        let entityName = Constants.UserPosts.entityName
        let encodedData = try JSONEncoder().encode(posts)
        try await cache.save(entityName: entityName, data: encodedData)
    }
    
    func resetCache() async throws {
        try await cache.reset()
    }
}

final class Cache {
    private let cache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private lazy var cacheDirectory: URL = {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectory = urls[urls.count - 1].appendingPathComponent("cache")
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        return cacheDirectory
    }()
    
    func load(entityName: String) async throws -> Data {
        if let cachedData = cache.object(forKey: entityName as NSString) {
            return cachedData as Data
        }
        let cacheFileURL = cacheDirectory.appendingPathComponent(entityName)
        let fileData = try Data(contentsOf: cacheFileURL)
        cache.setObject(fileData as NSData, forKey: entityName as NSString)
        return fileData
    }
    
    func save(entityName: String, data: Data) async throws {
        let cacheFileURL = cacheDirectory.appendingPathComponent(entityName)
        try data.write(to: cacheFileURL, options: .atomic)
        cache.setObject(data as NSData, forKey: entityName as NSString)
    }
    
    func reset() async throws {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }
}
