import SwiftUI
import AuthenticationServices
import CryptoKit

@MainActor
final class AuthStore: NSObject, ObservableObject {
    /// Whether the user is signed in
    @Published var isSignedIn: Bool = false
    /// Any error messages
    @Published var errorMessage: String?

    private var currentNonce: String?

    /// Kick off a new Sign in with Apple flow
    func signInWithApple() {
        let nonce = Self.randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    /// Signs the user out by flipping `isSignedIn` back to false.
    func signOut() {
        isSignedIn = false
    }

    // MARK: — Nonce helpers

    private static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length

        while remaining > 0 {
            let randoms = (0..<16).map { _ in UInt8.random(in: 0...255) }
            for byte in randoms where remaining > 0 {
                if byte < charset.count {
                    result.append(charset[Int(byte)])
                    remaining -= 1
                }
            }
        }
        return result
    }

    private static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: — ASAuthorizationControllerDelegate

extension AuthStore: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            authorization.credential is ASAuthorizationAppleIDCredential,
            let _ = currentNonce
        else {
            errorMessage = "Invalid response from Apple Sign In."
            return
        }
        isSignedIn = true
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        errorMessage = error.localizedDescription
    }
}

// MARK: — Presentation Context

extension AuthStore: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
