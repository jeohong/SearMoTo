import UIKit

class movieInfoViewController: UIViewController {
    // 아울렛 변수 선언
    @IBOutlet var MovieImage: UIImageView!
    @IBOutlet var MovieTitle: UILabel!
    @IBOutlet var openDate: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var overView: UITextView!
    
    var param: MovieVO!
    
    override func viewDidLoad() {
        MovieTitle.text = param.titleKR
        openDate.text = param.opendate
        rating.text = "\(param.rating!)"
        overView.text = "줄거리 정보\n\n\(param.overView!)"
        MovieImage.image = param.thumbnailImage
    }
}
