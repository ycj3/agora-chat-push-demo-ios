//
//  BasicMessageCell.swift

//
//  Created by Carlson Yuan on 2023/8/9.
//

import UIKit
import AgoraChat

open class BasicMessageCell: UITableViewCell {
    
    public lazy var profileLabel: UILabel = {
        let profileLabel: UILabel = UILabel()
        profileLabel.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.textColor = .secondaryLabel
        profileLabel.font = .systemFont(ofSize: 14)
        return profileLabel
    }()
    
    public lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    public lazy var profileImageView: UIImageView = {
        let profileImageView: UIImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 16
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .secondarySystemBackground
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),
        ])
        return profileImageView
    }()
    
    public lazy var messageLabel: UILabel = {
        let messageLabel: UILabel = UILabel()
        messageLabel.textColor = .label
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 17)
        messageLabel.numberOfLines = 0
        return messageLabel
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(profileLabel)
        contentStackView.addArrangedSubview(messageLabel)

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),
        ])
                
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            contentStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        profileLabel.text = nil
        profileImageView.image = nil
        messageLabel.text = nil
    }

    open func configure(with message: AgoraChatMessage) {
        profileLabel.text = "\(message.from)"
        if let body = message.body as? AgoraChatTextMessageBody {
            messageLabel.text = body.text
        }
    }
    
}
