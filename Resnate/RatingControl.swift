
import UIKit

class RatingControl: UIView {
    
    var rating = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var ratingButtons = [UIButton]()
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        var x = 0
        
        let filledStarImage = UIImage(named: "filledStar")
        let emptyStarImage = UIImage(named: "emptyStar")
        
        for _ in 0..<5 {
            
            let button = UIButton(frame: CGRect(x: x, y: 0, width: 44, height: 44))
            
            
            button.setImage(emptyStarImage, forState: .Normal)
            button.setImage(filledStarImage, forState: .Selected)
            button.setImage(filledStarImage, forState: .Highlighted | .Selected)
            
            button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: "ratingButtonTapped:", forControlEvents: .TouchDown)
            ratingButtons += [button]
            
            
            addSubview(button)
            
            x += 50
        }
    }
    
    func ratingButtonTapped(button: UIButton) {
        rating = find(ratingButtons, button)! + 1
        
        updateButtonSelectionStates()
    }
    
    func updateButtonSelectionStates() {
        
        for (index, button) in enumerate(ratingButtons) {
            // If the index of a button is less than the rating, that button shouldn't be selected.
            button.selected = index < rating
        }
        
    }
    
}