import UIKit

class ViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "whisk"
        label.font = UIFont.systemFont(ofSize: 42, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = """
        Whisk: Hi, I'm here to keep you company on your commute.

        Whisk: You can tell me how you're feeling, ask a question, or use the quick buttons for comfort, emergency help, and check-ins.
        """
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let inputContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type your message..."
        textField.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        textField.layer.cornerRadius = 12
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)

        var config = UIButton.Configuration.filled()
        config.title = "Send"
        config.image = UIImage(systemName: "paperplane.fill")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.baseBackgroundColor = UIColor(red: 0.95, green: 0.52, blue: 0.22, alpha: 1.0)
        config.baseForegroundColor = .white

        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let helperLabel: UILabel = {
        let label = UILabel()
        label.text = "Comfort, emergency help, and a quick trusted-contact check-in."
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let comfortButton = QuickActionButton(title: "Comfort", emoji: "🐟")
    private let emergencyButton = QuickActionButton(title: "Emergency", emoji: "🆘")
    private let checkInButton = QuickActionButton(title: "Check in", emoji: "👤")

    private lazy var quickButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [comfortButton, emergencyButton, checkInButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let catImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cat")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let tableView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        view.layer.cornerRadius = 26
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .interactive
        return scroll
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupLayout()
        setupKeyboardDismiss()
        messageTextField.setLeftPadding(14)
    }

    private func setupBackground() {
        view.backgroundColor = UIColor(red: 0.95, green: 0.64, blue: 0.49, alpha: 1.0)
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(messageContainerView)
        messageContainerView.addSubview(messageLabel)

        contentView.addSubview(inputContainerView)
        inputContainerView.addSubview(messageTextField)
        inputContainerView.addSubview(sendButton)

        contentView.addSubview(helperLabel)
        contentView.addSubview(quickButtonsStackView)
        contentView.addSubview(tableView)
        contentView.addSubview(catImageView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            messageContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            messageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            messageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),

            messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 18),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -18),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -20),

            inputContainerView.topAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: 24),
            inputContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            inputContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            inputContainerView.heightAnchor.constraint(equalToConstant: 56),

            messageTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
            messageTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
            messageTextField.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor),

            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 12),
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor),
            sendButton.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
            sendButton.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 120),

            helperLabel.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 18),
            helperLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            helperLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),

            quickButtonsStackView.topAnchor.constraint(equalTo: helperLabel.bottomAnchor, constant: 22),
            quickButtonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            quickButtonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            quickButtonsStackView.heightAnchor.constraint(equalToConstant: 110),

            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 110),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            catImageView.topAnchor.constraint(equalTo: quickButtonsStackView.bottomAnchor, constant: 8),
            catImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            catImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
            catImageView.heightAnchor.constraint(equalToConstant: 260),
            catImageView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 85)
        ])
    }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

final class QuickActionButton: UIButton {

    init(title: String, emoji: String) {
        super.init(frame: .zero)
        setup(title: title, emoji: emoji)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setup(title: String, emoji: String) {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = imageFromEmoji(emoji)
        config.imagePlacement = .top
        config.imagePadding = 12
        config.baseForegroundColor = .black

        self.configuration = config
        self.backgroundColor = UIColor(white: 0.95, alpha: 0.92)
        self.layer.cornerRadius = 22
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    private func imageFromEmoji(_ emoji: String) -> UIImage? {
        let size = CGSize(width: 34, height: 34)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 30)
            ]

            let textSize = emoji.size(withAttributes: attributes)
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            emoji.draw(in: rect, withAttributes: attributes)
        }
    }
}

extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
        leftView = paddingView
        leftViewMode = .always
    }
}
