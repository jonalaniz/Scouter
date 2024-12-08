//
//  FreeScoutService.swift
//  Scouter
//
//  Created by Jon Alaniz on 7/21/24.
//

import Foundation

final class FreeScoutService {
    static let shared = FreeScoutService()

    private let apiManager = APIManager.shared
    private let configurator = Configurator.shared

    private var folders = [Folder]()

    private init() {}

    func fetchConversations() async throws -> ConversationContainer {
        guard let secret = configurator.getConfiguration()?.secret else {
            throw APIManagerError.configurationMissing
        }

        var urlWithEndpoint = secret.url.appendingPathComponentSafely(Endpoint.conversations.path)

        urlWithEndpoint.append(queryItems: [URLQueryItem(name: "pageSize", value: "200")])

        return try await apiManager.request(url: urlWithEndpoint,
                                            httpMethod: .get,
                                            body: nil,
                                            headers: defaultHeaders(withKey: secret.key),
                                            expectingReturnType: ConversationContainer.self)
    }

    func fetchFolders() async throws -> Folders {
        guard
            let mailboxID = configurator.getConfiguration()?.mailboxID,
            let secret = configurator.getConfiguration()?.secret
        else {
            throw APIManagerError.configurationMissing
        }

        let urlWithEndpoint = secret.url.appendingPathComponentSafely(Endpoint.folders(mailboxID).path)

        return try await apiManager.request(url: urlWithEndpoint,
                                            httpMethod: .get,
                                            body: nil,
                                            headers: defaultHeaders(withKey: secret.key),
                                            expectingReturnType: Folders.self)
    }

    func fetchMailboxes(key: String,
                        url: URL) async throws -> MailboxContainer {
        let urlWithEndpoint = url.appendingPathComponentSafely(Endpoint.mailbox.path)

        return try await apiManager.request(url: urlWithEndpoint,
                                            httpMethod: .get,
                                            body: nil,
                                            headers: defaultHeaders(withKey: key),
                                            expectingReturnType: MailboxContainer.self)
    }

    func set(_ folders: Folders) {
        self.folders = folders.container.folders.sorted(by: { $0.id < $1.id })
    }

    func mainFolders() -> [Folder] {
        return folders.filter { $0.userId == nil }
    }

    private func defaultHeaders(withKey key: String) -> [String: String] {
        let headers: [String: String] = [
            HeaderKeyValue.apiKey.rawValue: key,
            HeaderKeyValue.accept.rawValue: HeaderKeyValue.applicationJSON.rawValue,
            HeaderKeyValue.contentType.rawValue: HeaderKeyValue.jsonCharset.rawValue
        ]

        return headers
    }

    func isConfigured() -> Bool {
        return configurator.getConfiguration() != nil
    }

    func timeInterval() -> FetchInterval? {
        return configurator.getConfiguration()?.fetchInterval
    }

    func urlFor(_ conversation: Int) -> URL? {
        let secret = configurator.getConfiguration()?.secret
        var components = URLComponents(url: (secret?.url)!, resolvingAgainstBaseURL: false)
        components?.path += "/conversation/\(conversation)"
        return components?.url
    }
}
