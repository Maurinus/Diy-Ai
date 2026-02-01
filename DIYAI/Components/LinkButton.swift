import SwiftUI

struct LinkButton: View {
    let title: String
    let url: URL
    let style: ButtonStyleVariant
    var builder: AffiliateLinkBuilder? = nil
    var onTap: (() -> Void)? = nil

    @Environment(\.openURL) private var openURL

    enum ButtonStyleVariant {
        case primary
        case secondary
    }

    var body: some View {
        let finalURL = builder?.build(url) ?? url
        switch style {
        case .primary:
            Button(title) {
                onTap?()
                openURL(finalURL)
            }
            .buttonStyle(PrimaryButtonStyle())
        case .secondary:
            Button(title) {
                onTap?()
                openURL(finalURL)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}
