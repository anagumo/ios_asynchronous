import UIKit
import Combine
import CombineCocoa

enum HeroSection {
    case main
}

class HerosController: UIViewController {
    // MARK: UI Components
    @IBOutlet private var errorStackView: UIStackView!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var tryAgainButton: UIButton!
    @IBOutlet private var collectionView: UICollectionView!
    
    // MARK: Data Source
    typealias DataSource = UICollectionViewDiffableDataSource<HeroSection, Hero>
    typealias Snapshot = NSDiffableDataSourceSnapshot<HeroSection, Hero>
    typealias CellRegistration = UICollectionView.CellRegistration<HeroViewCell, Hero>
    private var dataSource: DataSource?
    
    // MARK: Observed Objects
    private var herosViewModel: HerosViewModel
    private var subscribers: Set<AnyCancellable>
    
    // MARK: Lifecycle
    init(herosViewModel: HerosViewModel) {
        self.herosViewModel = herosViewModel
        self.dataSource = nil
        self.subscribers = Set()
        super.init(nibName: "HerosView", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIComponents()
        bind()
        herosViewModel.load()
    }
    
    // MARK: Binding
    private func bind() {
        herosViewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .loading:
                    self?.renderLoading()
                case let .error(message):
                    self?.renderError(message)
                case .none:
                    self?.renderNone()
                }
            }.store(in: &subscribers)
        
        herosViewModel.$heroList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] heroList in
                var snapshot = Snapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems(heroList)
                self?.dataSource?.apply(snapshot)
            }.store(in: &subscribers)
        
        tryAgainButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.herosViewModel.load()
            }.store(in: &subscribers)
        
        // Do this invalidates the collection view delegates by the flow layout one
        /*collectionView.didSelectItemPublisher
            .receive(on: DispatchQueue.main)
            .sink { indexPath in }
         .store(in: &subscribers)*/
    }
    
    // MARK: Rendering state
    private func renderLoading() {
        activityIndicatorView.startAnimating()
        errorStackView.isHidden = true
        collectionView.isHidden = true
    }
    
    private func renderError(_ message: String) {
        activityIndicatorView.stopAnimating()
        errorStackView.isHidden = false
        collectionView.isHidden = true
    }
    
    private func renderNone() {
        activityIndicatorView.stopAnimating()
        errorStackView.isHidden = true
        collectionView.isHidden = false
    }
}

extension HerosController {
    // MARK: UI Components Configuration
    private func configureUIComponents() {
        title = "Heros"
        let nib = UINib(nibName: HeroViewCell.identifier, bundle: Bundle(for: type(of: self)))
        let cell = CellRegistration.init(cellNib: nib) { cell, indexPath, hero in
            cell.bind(hero)
        }
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, hero in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: hero)
        })
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
}

// MARK: - Collection View Delegates
extension HerosController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (collectionView.frame.size.width - 60) / 2
            return CGSize(width: width, height: 200)
        }
}
