import Foundation

protocol AffiliateConfigSource {
    func currentConfig() -> AffiliateLinkBuilder.Config?
}

struct AffiliateLinkBuilder {
    struct DomainRule: Equatable {
        let domain: String
        var queryParameters: [String: String]
        var replaceHost: String?

        init(domain: String, queryParameters: [String: String] = [:], replaceHost: String? = nil) {
            self.domain = domain
            self.queryParameters = queryParameters
            self.replaceHost = replaceHost
        }
    }

    struct Config: Equatable {
        var enabled: Bool
        var globalQueryParameters: [String: String]
        var domainRules: [DomainRule]

        static let disabled = Config(enabled: false, globalQueryParameters: [:], domainRules: [])
    }

    private let configSource: AffiliateConfigSource?
    private let fallbackConfig: Config

    init(configSource: AffiliateConfigSource? = nil, fallbackConfig: Config = .disabled) {
        self.configSource = configSource
        self.fallbackConfig = fallbackConfig
    }

    func build(_ url: URL) -> URL {
        let config = configSource?.currentConfig() ?? fallbackConfig
        guard config.enabled else { return url }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }

        var queryItems = components.queryItems ?? []
        apply(parameters: config.globalQueryParameters, to: &queryItems)

        if let host = components.host {
            let matchingRules = config.domainRules.filter { matches(host: host, ruleDomain: $0.domain) }
            for rule in matchingRules {
                apply(parameters: rule.queryParameters, to: &queryItems)
                if let replaceHost = rule.replaceHost {
                    components.host = replaceHost
                }
            }
        }

        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url ?? url
    }

    private func apply(parameters: [String: String], to queryItems: inout [URLQueryItem]) {
        for (key, value) in parameters {
            if queryItems.contains(where: { $0.name == key }) { continue }
            queryItems.append(URLQueryItem(name: key, value: value))
        }
    }

    private func matches(host: String, ruleDomain: String) -> Bool {
        host == ruleDomain || host.hasSuffix(".\(ruleDomain)")
    }
}

struct NoopAffiliateConfigSource: AffiliateConfigSource {
    func currentConfig() -> AffiliateLinkBuilder.Config? {
        nil
    }
}
