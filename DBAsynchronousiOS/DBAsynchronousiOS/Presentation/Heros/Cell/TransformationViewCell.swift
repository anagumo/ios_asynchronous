import UIKit

class TransformationViewCell: UICollectionViewCell {
    static let identifier = String(describing: TransformationViewCell.self)
    @IBOutlet private var photoAsyncImageView: AsyncImageView!
    @IBOutlet private var nameLabel: UILabel!
    
    func bind(_ transformation: Transformation) {
        photoAsyncImageView.setImage(transformation.photo)
        nameLabel.text = transformation.name
    }
}
