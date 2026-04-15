//
//  ViewController.swift
//  whisk
//
//  Created by Brianna Shen on 2024-08-11.
//

import UIKit

struct WhiskChatEngine {
    private let fallbackResponses = [
        "You're not alone. Stay with me and keep moving toward a bright, populated area.",
        "I'm here with you. Take a breath and keep your phone nearby.",
        "You're doing well. If anything feels off, trust that feeling and get to safety first.",
        "Let's focus on the next safe step together. Tell me what is happening."
    ]

    private let comfortResponses = [
        "You've got this. Keep your head up, your route simple, and your phone ready.",
        "A slow breath can help. In for four, out for four, and keep walking toward people and light.",
        "You deserve to feel safe. Stay in public areas and let someone know where you are.",
        "You're doing the right thing by checking in. I'm right here with you."
    ]

    func welcomeMessage() -> String {
        """
        Whisk: Hi, I'm here to keep you company on your commute.
        Whisk: You can tell me how you're feeling, ask a question, or use the quick buttons for comfort, emergency help, and check-ins.
        """
    }

    func comfortMessage() -> String {
        comfortResponses.randomElement() ?? "I'm here with you."
    }

    func safetyChecklist() -> String {
        """
        1. Move toward a well-lit, populated place.
        2. Keep your phone unlocked and ready.
        3. Call emergency services if you are in immediate danger.
        4. Share your location or route with someone you trust if you can.
        """
    }

    func checkInMessage() -> String {
        "Hi, I'm heading home now. Can you stay available until I arrive safely?"
    }

    func response(for rawMessage: String) -> String {
        let message = rawMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = message.lowercased()

        if normalized.isEmpty {
            return "Send me a message whenever you're ready."
        }

        if containsAny(normalized, words: ["911", "emergency", "attack", "danger", "unsafe"]) {
            return "If you're in immediate danger, call 911 right now and move toward the nearest safe public place if possible."
        }

        if containsAny(normalized, words: ["scared", "nervous", "anxious", "worried", "alone"]) {
            return "It's okay to feel that way. Stay in a bright, public area if you can, and tell me what would help most right now."
        }

        if normalized.contains("help") {
            return "I can stay with you, suggest next safety steps, or help you prepare a check-in message for someone you trust."
        }

        if normalized.contains("?") || normalized.hasPrefix("what") || normalized.hasPrefix("how") || normalized.hasPrefix("why") {
            return answerQuestion(normalized)
        }

        if containsAny(normalized, words: ["home", "commute", "walking", "train", "bus", "ride"]) {
            return "Thanks for checking in. Keep me posted on how the commute is going, and stay where there are people and light when possible."
        }

        return fallbackResponses.randomElement() ?? "Stay safe. I'm here with you."
    }

    private func answerQuestion(_ message: String) -> String {
        if containsAny(message, words: ["what should i do", "how do i stay safe", "tips"]) {
            return "Start with the safest next move: head toward people and light, keep your phone ready, and contact emergency services if the risk feels immediate."
        }

        if containsAny(message, words: ["call", "911", "emergency"]) {
            return "Use the emergency button if you need to call 911 quickly. If you can, move somewhere visible while the call is connecting."
        }

        if containsAny(message, words: ["check in", "text", "friend", "contact"]) {
            return "Use the contact button to share a quick check-in message with someone you trust."
        }

        return "I can help with safety tips, emotional support, or preparing a message to someone you trust."
    }

    private func containsAny(_ message: String, words: [String]) -> Bool {
        words.contains(where: { message.contains($0) })
    }
}

final class ViewController: UIViewController {
    private let chatEngine = WhiskChatEngine()

    private let titleLabel = UILabel()
    private let chatTextView = UITextView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let helperLabel = UILabel()
    private let comfortButton = UIButton(type: .system)
    private let emergencyButton = UIButton(type: .system)
    private let contactButton = UIButton(type: .system)
    private let mascotImageView = UIImageView()
    private let surfaceImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureSubviews()
        setupLayout()
        chatTextView.text = chatEngine.welcomeMessage()
        chatTextView.accessibilityValue = chatTextView.text
    }

    private func configureView() {
        view.backgroundColor = UIColor(red: 1.0, green: 0.64, blue: 0.47, alpha: 1.0)
    }

    private func configureSubviews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "whisk"
        titleLabel.font = UIFont(name: "ArialRoundedMTBold", size: 40) ?? .boldSystemFont(ofSize: 40)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        chatTextView.backgroundColor = .white
        chatTextView.textColor = .label
        chatTextView.font = .preferredFont(forTextStyle: .body)
        chatTextView.adjustsFontForContentSizeCategory = true
        chatTextView.isEditable = false
        chatTextView.layer.cornerRadius = 20
        chatTextView.textContainerInset = UIEdgeInsets(top: 16, left: 14, bottom: 16, right: 14)
        chatTextView.accessibilityIdentifier = "chatTextView"

        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.borderStyle = .roundedRect
        messageTextField.placeholder = "Type your message..."
        messageTextField.delegate = self
        messageTextField.returnKeyType = .send
        messageTextField.clearButtonMode = .whileEditing
        messageTextField.autocapitalizationType = .sentences
        messageTextField.accessibilityIdentifier = "messageTextField"

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.configuration = filledButtonConfiguration(title: "Send", symbol: "paperplane.fill")
        sendButton.accessibilityIdentifier = "sendButton"
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        helperLabel.translatesAutoresizingMaskIntoConstraints = false
        helperLabel.text = "Comfort, emergency help, and a quick trusted-contact check-in."
        helperLabel.font = .preferredFont(forTextStyle: .subheadline)
        helperLabel.adjustsFontForContentSizeCategory = true
        helperLabel.textColor = .white
        helperLabel.textAlignment = .center
        helperLabel.numberOfLines = 0

        comfortButton.translatesAutoresizingMaskIntoConstraints = false
        comfortButton.configuration = circleButtonConfiguration(title: "🐟", subtitle: "Comfort")
        comfortButton.accessibilityIdentifier = "comfortButton"
        comfortButton.addTarget(self, action: #selector(comfortButtonTapped), for: .touchUpInside)

        emergencyButton.translatesAutoresizingMaskIntoConstraints = false
        emergencyButton.configuration = circleButtonConfiguration(title: "🆘", subtitle: "Emergency")
        emergencyButton.accessibilityIdentifier = "emergencyButton"
        emergencyButton.addTarget(self, action: #selector(emergencyButtonTapped), for: .touchUpInside)

        contactButton.translatesAutoresizingMaskIntoConstraints = false
        contactButton.configuration = circleButtonConfiguration(title: "👤", subtitle: "Check in")
        contactButton.accessibilityIdentifier = "contactButton"
        contactButton.addTarget(self, action: #selector(contactButtonTapped), for: .touchUpInside)

        mascotImageView.translatesAutoresizingMaskIntoConstraints = false
        mascotImageView.image = UIImage(named: "cat")
        mascotImageView.contentMode = .scaleAspectFit

        surfaceImageView.translatesAutoresizingMaskIntoConstraints = false
        surfaceImageView.image = UIImage(named: "table")
        surfaceImageView.contentMode = .scaleAspectFit
        surfaceImageView.alpha = 0.9

        [surfaceImageView, mascotImageView, titleLabel, chatTextView, messageTextField, sendButton, helperLabel, comfortButton, emergencyButton, contactButton].forEach {
            view.addSubview($0)
        }
    }

    private func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide
        let buttonsStack = UIStackView(arrangedSubviews: [comfortButton, emergencyButton, contactButton])
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.axis = .horizontal
        buttonsStack.alignment = .fill
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 14
        view.addSubview(buttonsStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),

            chatTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            chatTextView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            chatTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            chatTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            chatTextView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.28),

            messageTextField.topAnchor.constraint(equalTo: chatTextView.bottomAnchor, constant: 16),
            messageTextField.leadingAnchor.constraint(equalTo: chatTextView.leadingAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12),
            messageTextField.heightAnchor.constraint(equalToConstant: 44),

            sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: chatTextView.trailingAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 112),
            sendButton.heightAnchor.constraint(equalToConstant: 44),

            helperLabel.topAnchor.constraint(equalTo: messageTextField.bottomAnchor, constant: 16),
            helperLabel.leadingAnchor.constraint(equalTo: chatTextView.leadingAnchor, constant: 8),
            helperLabel.trailingAnchor.constraint(equalTo: chatTextView.trailingAnchor, constant: -8),

            buttonsStack.topAnchor.constraint(equalTo: helperLabel.bottomAnchor, constant: 18),
            buttonsStack.leadingAnchor.constraint(equalTo: chatTextView.leadingAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: chatTextView.trailingAnchor),

            comfortButton.heightAnchor.constraint(equalToConstant: 84),
            emergencyButton.heightAnchor.constraint(equalTo: comfortButton.heightAnchor),
            contactButton.heightAnchor.constraint(equalTo: comfortButton.heightAnchor),

            mascotImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -20),
            mascotImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20),
            mascotImageView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            mascotImageView.topAnchor.constraint(greaterThanOrEqualTo: buttonsStack.bottomAnchor, constant: 12),

            surfaceImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -30),
            surfaceImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 30),
            surfaceImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 30),
            surfaceImageView.topAnchor.constraint(greaterThanOrEqualTo: buttonsStack.bottomAnchor, constant: 18)
        ])
    }

    private func filledButtonConfiguration(title: String, symbol: String) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.image = UIImage(systemName: symbol)
        configuration.imagePlacement = .leading
        configuration.imagePadding = 8
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = UIColor(red: 0.95, green: 0.48, blue: 0.21, alpha: 1.0)
        configuration.baseForegroundColor = .white
        return configuration
    }

    private func circleButtonConfiguration(title: String, subtitle: String) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.subtitle = subtitle
        configuration.titleAlignment = .center
        configuration.baseForegroundColor = .label
        configuration.baseBackgroundColor = .white.withAlphaComponent(0.92)
        configuration.cornerStyle = .large
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 30)
            return outgoing
        }
        configuration.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .preferredFont(forTextStyle: .caption1)
            return outgoing
        }
        return configuration
    }

    @objc private func sendButtonTapped() {
        sendCurrentMessage()
    }

    @objc private func comfortButtonTapped() {
        appendSpeakerLine("Whisk", message: chatEngine.comfortMessage())
    }

    @objc private func contactButtonTapped() {
        let defaultMessage = chatEngine.checkInMessage()
        let shareController = UIActivityViewController(activityItems: [defaultMessage], applicationActivities: nil)

        if let popover = shareController.popoverPresentationController {
            popover.sourceView = contactButton
            popover.sourceRect = contactButton.bounds
        }

        present(shareController, animated: true)
        appendSpeakerLine("Whisk", message: "I opened a quick check-in message you can share with someone you trust.")
    }

    @objc private func emergencyButtonTapped() {
        let alert = UIAlertController(
            title: "Emergency Help",
            message: "If you are in immediate danger, call 911 now. You can also review a quick safety checklist below.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Call 911", style: .destructive) { [weak self] _ in
            self?.callEmergencyServices()
        })
        alert.addAction(UIAlertAction(title: "Safety Checklist", style: .default) { [weak self] _ in
            self?.appendSpeakerLine("Whisk", message: self?.chatEngine.safetyChecklist() ?? "")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    private func sendCurrentMessage() {
        guard let userMessage = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !userMessage.isEmpty else {
            return
        }

        appendSpeakerLine("You", message: userMessage)
        messageTextField.text = ""

        let response = chatEngine.response(for: userMessage)
        appendSpeakerLine("Whisk", message: response)
    }

    private func appendSpeakerLine(_ speaker: String, message: String) {
        let separator = chatTextView.text.isEmpty ? "" : "\n\n"
        chatTextView.text += "\(separator)\(speaker): \(message)"
        chatTextView.accessibilityValue = chatTextView.text
        let bottom = NSRange(location: max(chatTextView.text.count - 1, 0), length: 1)
        chatTextView.scrollRangeToVisible(bottom)
    }

    private func callEmergencyServices() {
        #if targetEnvironment(simulator)
        showErrorAlert(message: "Phone calls are not available in the iOS Simulator. To test this flow, use the alert and checklist here, or run the app on a real iPhone.")
        #else
        guard let phoneURL = URL(string: "tel://911"),
              UIApplication.shared.canOpenURL(phoneURL) else {
            showErrorAlert(message: "This device cannot place phone calls. Please use another phone or contact nearby help immediately.")
            return
        }

        UIApplication.shared.open(phoneURL, options: [:]) { [weak self] success in
            if !success {
                self?.showErrorAlert(message: "Whisk couldn't place the call. Please dial 911 manually if you can.")
            }
        }
        #endif
    }

    private func showErrorAlert(message: String) {
        let errorAlert = UIAlertController(title: "Unable to Complete Action", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(errorAlert, animated: true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCurrentMessage()
        return true
    }
}
