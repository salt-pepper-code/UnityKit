
import UIKit

extension UIImage {

    func resize(to size: CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }

}
