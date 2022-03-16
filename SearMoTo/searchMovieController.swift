import UIKit

class searchMovieController: UIViewController {
    var page = 1
    var total = 0
    
    @IBOutlet var search: UISearchBar!
    @IBOutlet var moreBtn: UIButton!
    @IBAction func more(_ sender: Any) {
        page += 1
        callSearchAPI()
        movieCollection.reloadData()
    }
    
    lazy var list: [MovieVO] = {
        var datalist = [MovieVO]()
        return datalist
    }()
    
    @IBOutlet var movieCollection: UICollectionView!
    
    override func viewDidLoad() {
        self.movieCollection.delegate = self
        self.movieCollection.dataSource = self
        
        // TextField 속성 설정
        self.search.placeholder = "영화 검색"
        self.search.enablesReturnKeyAutomatically = true
        self.search.delegate = self
        self.search.backgroundImage = UIImage()
        self.search.setValue("취소", forKey: "cancelButtonText")
        
        self.moreBtn.isHidden = true
                
    }
    
    // MARK:- 검색 API 호출
    func callSearchAPI() {
        let apiKey = "7c66710db8b122046109d589ebaf3c31"
        let url = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&language=ko-KR&query=\(self.search.text!)&include_adult=true&page=\(self.page)"
        
        // URL에 한글이 있기때문에 인코딩 설정
        let encodedString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let apiURI: URL! = URL(string: encodedString)
        
        // RestAPI 호출
        let apidata = try! Data(contentsOf: apiURI)
        
        do {
            let apiDictionary = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSDictionary
            
            let result = apiDictionary["results"] as! NSArray
            
            // 검색 총 갯수
            total = apiDictionary["total_results"] as! Int
            for row in result {
                let r = row as! NSDictionary
                let mvo = MovieVO()
                
                mvo.title = r["original_title"] as? String
                mvo.titleKR = r["title"] as? String
                mvo.thumbnail = r["poster_path"] as? String
                mvo.opendate = r["release_date"] as? String
                mvo.rating = r["vote_average"] as? Double
                mvo.overView = r["overview"] as? String
                
                // 개봉한 영화인지 아닌지 판단
                if mvo.opendate == nil{
                    mvo.opendate = "미개봉"
                }
                
                // 줄거리 미리보기가 있는지 판단
                if mvo.overView == "" {
                    mvo.overView = "영화사에서 제공된 줄거리가 없습니다."
                }
                
                // 영화 포스터 있는지 없는지 판단
                if mvo.thumbnail != nil {
                    // 웹상에 있는 이미지주소를 읽어와 UIImage 객체로 생성
                    let url: URL! = URL(string: "https://www.themoviedb.org/t/p/w220_and_h330_face\(mvo.thumbnail!)")
                    let imagedata = try! Data(contentsOf: url)
                    mvo.thumbnailImage = UIImage(data: imagedata)
                } else {
                    let path = Bundle.main.path(forResource: "noPoster", ofType: "png")
                    mvo.thumbnailImage = UIImage(contentsOfFile: path!)
                }
                
                // list 배열에 추가
                self.list.append(mvo)
            }
        } catch { }
    }
}

// MARK:- Collection View의 내용
extension searchMovieController: UICollectionViewDelegateFlowLayout {
    // 위 아래 간격
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 5
     }

     // 옆 간격
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         return 1
     }

     // cell 사이즈( 옆 라인을 고려하여 설정 )
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

         let width = collectionView.frame.width / 3 - 1
         let size = CGSize(width: width, height: 200)
         return size
     }
}
// MARK:- 화면 전환 시 값을 넘겨주기 위한 세그웨이 관련 처리
extension searchMovieController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_detail" {
            let path = self.movieCollection.indexPath(for: sender as! UICollectionViewCell)
            
            // 행 정보를 통해 선택된 영화 데이터를 찾고, 목적지 뷰 컨트롤러의 mvo 변수에 대입한다.
            let detailVC = segue.destination as? movieInfoViewController
            detailVC?.param = self.list[path!.row]
        }
    }
}

// MARK:- CollectionView Delegate & DataSource
extension searchMovieController: UICollectionViewDelegate {
    // cell 클릭시 뭘 할꺼야?
    
}

extension searchMovieController: UICollectionViewDataSource {
    // Cell에는 무엇을 보여줄꺼야?
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 주어진 행에 맞는 데이터 소스 읽어오기
        let row = self.list[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "titleCell", for: indexPath) as! MovieCell
        
        // 데이터 소스에 저장된 값을 각 아울렛 변수에 할당
        cell.title?.text = row.title
        
        // 비동기 방식으로 섬네일 이미지를 읽어옴
        DispatchQueue.main.async(execute: {
            cell.thumbnail.image = self.getThumbnailImage(indexPath.row)
        })
                
        if self.list.count < total {
            self.moreBtn.isHidden = false
        } else {
            self.moreBtn.isHidden = true
        }
        return cell
    }
    
    // 이미지 받아오는 메모이제이션 기법의 함수
    func getThumbnailImage(_ index: Int) -> UIImage {
        // 인자값으로 받은 인덱스를 기반으로 해당하는 배열 데이터를 읽어옴
        let mvo = self.list[index]
        
        // 메모이제이션 : 저장된 이미지가 있으면 그것을 반환하고, 없을 경우 내려받아 저장한 후 반환
        if let savedImage = mvo.thumbnailImage {
            return savedImage
        } else {
            if mvo.thumbnail != nil {
                let url: URL! = URL(string: "https://www.themoviedb.org/t/p/w220_and_h330_face\(mvo.thumbnail!)")
                let imageData = try! Data(contentsOf: url)
                mvo.thumbnailImage = UIImage(data: imageData) // UIImage를 MovieVO 객체에 우선 저장
                
                return mvo.thumbnailImage!
            } else {
                let path = Bundle.main.path(forResource: "noPoster", ofType: "png")
                return UIImage(contentsOfFile: path!)!
            }
        }
    }
}

// MARK:- SearchBar Delegate
extension searchMovieController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.page = 1
        self.list = []
        self.search.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.search.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.callSearchAPI()
        self.movieCollection.reloadData()
        self.search.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
}

