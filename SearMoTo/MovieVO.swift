import Foundation
import UIKit

//MARK:- 영화 정보를 담는 객체
class MovieVO {
    var thumbnail: String?      // 영화 썸네일 이미지 주소
    var title: String?          // 영화 제목 (원어)
    var titleKR: String?        // 영화 제목 (한국어)
    var opendate: String?       // 개봉일
    var rating: Double?         // 평점
    var overView: String?       // 미리보기
    
    // 섬네일 이미지를 저장할 객체
    var thumbnailImage: UIImage?
}
