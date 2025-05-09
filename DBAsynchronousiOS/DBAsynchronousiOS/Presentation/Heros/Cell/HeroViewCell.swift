import UIKit

class HeroViewCell: UICollectionViewCell {
    static let identifier = String(describing: HeroViewCell.self)
    
    // MARK: UI Components
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var photoAsyncImageView: AsyncImageView!
    @IBOutlet private var nameLabel: UILabel!
    
    // MARK: Binding
    func bind(_ hero: Hero) {
        contentStackView.layer.cornerRadius = 8
        contentStackView.layer.borderWidth = 1
        contentStackView.layer.borderColor = UIColor.line.cgColor
        photoAsyncImageView.layer.cornerRadius = 8
        nameLabel.text = hero.name
        photoAsyncImageView.setImage(hero.photo)
    }
}
