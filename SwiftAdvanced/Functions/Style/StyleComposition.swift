import UIKit

extension UIView {
    static let roundedStyle: (UIView) -> Void = {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    static func borderStyle(
        color: UIColor, width: CGFloat
    ) -> (UIView) -> Void {
        return {
            $0.layer.borderColor = color.cgColor
            $0.layer.borderWidth = width
        }
    }
}

func <> <A: AnyObject>(
    f: @escaping (A) -> Void,
    g: @escaping (A) -> Void
) -> (A) -> Void {
    return { a in
        f(a)
        g(a)
    }
}

final class StyleComposition {
    func baseStyle(_ button: UIButton) {
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: 12, leading: 16, bottom: 12, trailing: 16
        )
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }

    lazy var roundedStyle = self.baseStyle
    <> UIButton.roundedStyle
    <> UIButton.borderStyle(color: .white, width: 1.0)

    lazy var filledStyle = roundedStyle
    <> {
        $0.backgroundColor = .black
        $0.tintColor = .white
    }
    
    func createBtn() {
        let btn = UIButton()
        filledStyle(btn)
    }
}
