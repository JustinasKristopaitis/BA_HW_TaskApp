import SwiftUI

struct UsersListView: View {
    @StateObject private var viewModel: UserListViewModel = UserListViewModel(
        contentLoader: ContentLoader(
            contentCacher: ContentCacher(),
            dataFetcher: DataFetcher()
        ),
        contentCaching: ContentCacher()
    )
    @StateObject var networkReachability = NetworkReachability()
    @State private var isLoading: Bool = true
    @State private var error: HWError?
    
    enum ViewState {
        case loading
        case loaded([UserPost])
        case error(HWError)
        
        var posts: [UserPost] {
            switch self {
            case .loaded(let posts):
                return posts
            default:
                return []
            }
        }
    }
    
    @State private var viewState: ViewState = .loading
    
    var body: some View {
        switch viewState {
        case .loading:
            if networkReachability.status == .disconnected {
                ErrorView(error: HWError.noInternetConnection)
            } else {
                ProgressView()
                    .onAppear {
                        Task {
                            try await viewModel.loadPostsAndDetails()
                            viewState = .loaded(viewModel.loadedPosts)
                        }
                    }
            }
            
        case .loaded(let posts):
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(posts) { post in
                        UserCellView(
                            userName: viewModel.getUserName(forPostId: post.userId),
                            postTitle: post.title
                        )
                    }
                }
            }
            .padding(.all, 20)
            .refreshable {
                do {
                    try await viewModel.reloadDate()
                } catch {
                    print(error)
                }
            }
            
        case .error(let error):
            ErrorView(error: error)
        }
    }
    
    @ViewBuilder
    private func ErrorView(error: Error) -> some View {
        VStack(alignment: .center, spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.red)
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .font(.title2)
                .bold()
            
            ProgressView()
            
            Button(action: {
                if networkReachability.status == .connected {
                    Task {
                        try await viewModel.loadPostsAndDetails()
                    }
                }
            }) {
                Text("Retry")
            }
            .padding(.all, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(.horizontal, 15)
    }
}
