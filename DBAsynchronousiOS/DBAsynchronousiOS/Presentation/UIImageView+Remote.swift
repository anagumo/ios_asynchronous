import UIKit
import Combine

class AsyncImageView: UIImageView {
    private var cancellable: AnyCancellable?
    
    func setImage(_ stringURL: String?) {
        guard let stringURL, let url = URL(string: stringURL) else {
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .compactMap {
                UIImage(data: $0.data)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    debugPrint("Image downloaded")
                case let .failure(failure):
                    debugPrint("Occurs an error downloading the image: \(failure)")
                }
            }, receiveValue: { [weak self] uiImage in
                self?.image = uiImage
            })
    }
}
