import Foundation

@MainActor
final class MenuDetailViewModel: ObservableObject {
    @Published private(set) var loadState: LoadingState<MenuVersionDetail> = .idle

    private let menuVersionID: UUID
    private let menuService: MenuService

    init(menuVersionID: UUID, menuService: MenuService = .shared) {
        self.menuVersionID = menuVersionID
        self.menuService = menuService
    }

    init(detail: MenuVersionDetail, menuService: MenuService = .shared) {
        self.menuVersionID = detail.id
        self.menuService = menuService
        self.loadState = .loaded(detail)
    }

    func load() async {
        loadState = .loading

        do {
            let detail = try await menuService.fetchMenuVersionDetail(id: menuVersionID)
            loadState = .loaded(detail)
        } catch {
            loadState = .failed(NetworkError.map(error))
        }
    }
}
