import Foundation

@MainActor
final class MenuDetailViewModel: ObservableObject {
    @Published private(set) var loadState: LoadingState<MenuVersionDetail> = .idle
    @Published private(set) var isValidating = false
    @Published private(set) var validationError: NetworkError?

    private let menuVersionID: UUID
    private let menuService: MenuService
    private var previousVersionID: UUID?

    init(menuVersionID: UUID, menuService: MenuService = .shared) {
        self.menuVersionID = menuVersionID
        self.menuService = menuService
    }

    init(detail: MenuVersionDetail, menuService: MenuService = .shared) {
        self.menuVersionID = detail.id
        self.menuService = menuService
        self.loadState = .loaded(detail)
    }

    func load(previousVersionID: UUID? = nil) async {
        self.previousVersionID = previousVersionID
        loadState = .loading

        do {
            var detail = try await menuService.fetchMenuVersionDetail(id: menuVersionID)

            if detail.comparison == nil, let previousVersionID {
                let comparison = try await menuService.fetchMenuComparison(
                    currentVersionID: menuVersionID,
                    previousVersionID: previousVersionID
                )
                detail.comparison = comparison
            }

            loadState = .loaded(detail)
        } catch {
            loadState = .failed(NetworkError.map(error))
        }
    }

    func confirmMenu() async {
        guard var detail = loadState.value else { return }
        isValidating = true
        validationError = nil

        do {
            let updatedVersion = try await menuService.confirmMenu(versionID: detail.id)
            detail = updatedDetail(detail, version: updatedVersion, hasConfirmed: true)
            loadState = .loaded(detail)
            HapticFeedback.success()
        } catch {
            validationError = NetworkError.map(error)
            HapticFeedback.error()
        }

        isValidating = false
    }

    func reportOutdated() async {
        guard var detail = loadState.value else { return }
        isValidating = true
        validationError = nil

        do {
            let updatedVersion = try await menuService.reportMenuOutdated(versionID: detail.id)
            detail = updatedDetail(detail, version: updatedVersion, hasReportedOutdated: true)
            loadState = .loaded(detail)
            HapticFeedback.light()
        } catch {
            validationError = NetworkError.map(error)
            HapticFeedback.error()
        }

        isValidating = false
    }

    private func updatedDetail(
        _ detail: MenuVersionDetail,
        version: MenuVersion,
        hasConfirmed: Bool = false,
        hasReportedOutdated: Bool = false
    ) -> MenuVersionDetail {
        var viewerState = detail.viewerState
        if hasConfirmed { viewerState = MenuViewerState(hasConfirmed: true, hasReportedOutdated: viewerState.hasReportedOutdated) }
        if hasReportedOutdated { viewerState = MenuViewerState(hasConfirmed: viewerState.hasConfirmed, hasReportedOutdated: true) }

        return MenuVersionDetail(
            version: version,
            images: detail.images,
            cocktails: detail.cocktails,
            comparison: detail.comparison,
            viewerState: viewerState
        )
    }
}
