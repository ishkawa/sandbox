import UIKit
import RxSwift
import RxCocoa

class Cell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}

class ViewController: UICollectionViewController {
    private let dataSource = DataSource()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let values = Array(1...100)

        Observable
            .just(values)
            .bindTo(collectionView!.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
    }

    class DataSource: NSObject, UICollectionViewDataSource, RxCollectionViewDataSourceType {
        typealias Element = [Int]

        var values = [Int]()

        func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
            if case .next(let element) = observedEvent {
                values = element
                collectionView.reloadData()
            }
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return values.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
            cell.label.text = String(indexPath.row)

            return cell
        }
    }
}
