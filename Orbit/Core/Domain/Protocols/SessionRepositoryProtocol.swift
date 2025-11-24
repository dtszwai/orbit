import Foundation

// MARK: - Session Repository Protocol
/// Protocol defining the interface for focus session data access
protocol SessionRepositoryProtocol {
    /// Save a new focus session
    func save(_ session: FocusSession) throws

    /// Fetch sessions for a specific week offset (0 = current week, -1 = last week, etc.)
    func fetchSessions(for weekOffset: Int) -> [FocusSession]

    /// Delete all sessions
    func deleteAll() throws

    /// Calculate total focus time for a collection of sessions
    func totalFocusTime(for sessions: [FocusSession]) -> TimeInterval

    /// Get the date range string for a specific week offset
    func weekDateRange(for offset: Int) -> String
}
