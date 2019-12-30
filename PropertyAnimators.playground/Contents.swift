/*:
 # Quick Guide To Property Animators

 There are at least three ways to animate views in iOS. In the early days we had the begin/commit style. The block based API has been around since iOS 4 and since iOS 10 we have property animators which saw some updates in iOS 11. If you are familiar with the block-based API but have been avoiding the more complex property animators here is my quick guide comparing the two.

 The blog post that accompanies this playground:

 * [Quick Guide To Property Animators](https://useyourloaf.com/blog/quick-guide-to-property-animators/)

 © 2018 Keith Harrison [useyourloaf.com](https://useyourloaf.com)
 */
import UIKit
import PlaygroundSupport
/*:
 A view controller showing a red square that we can then animate in variety of ways.
 */
class AnimationViewController : UIViewController {

    var squareSize: CGFloat = 200.0 {
        didSet {
            sizeConstraint.constant = squareSize
        }
    }

    var centerOffset: CGFloat = 200.0 {
        didSet {
            centerConstraint.constant = centerOffset
        }
    }

    lazy var redSquare: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.layer.borderWidth = 10.0
        return view
    }()

    lazy var centerConstraint: NSLayoutConstraint = redSquare.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: centerOffset)

    lazy var sizeConstraint: NSLayoutConstraint = redSquare.heightAnchor.constraint(equalToConstant: squareSize)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.backgroundColor = .yellow
        view.addSubview(redSquare)
        NSLayoutConstraint.activate([
            redSquare.widthAnchor.constraint(equalTo: redSquare.heightAnchor),
            redSquare.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sizeConstraint,
            centerConstraint
            ])
    }
}


extension AnimationViewController {

/*:
 ### Basic Animation

 Using begin/commit based animation was discouraged in iOS 4.
 Formally deprecated since iOS 13.0
 */
    func beginCommitAnimation(withDuration duration: TimeInterval, delay: TimeInterval) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationDelay(delay)
        redSquare.backgroundColor = .green
        UIView.commitAnimations()
    }

/*:
 Block based API - now also discouraged - but not yet deprecated.
 */
    func blockAnimation(withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.redSquare.backgroundColor = .green
        }
    }

/*:
 Property Animator
 */
    func runningProperty(withDuration duration: TimeInterval) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [], animations: {
            self.redSquare.backgroundColor = .green
        })
    }

/*:
 ### UIKit Timing Curve
 */

    func linearBlockAnimation(withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            self.redSquare.backgroundColor = .green
        })
    }

    func linearPropertyAnimator(withDuration duration: TimeInterval) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            self.redSquare.backgroundColor = .green
        })
    }

    func propertyAnimator(withDuration duration: TimeInterval) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            self.redSquare.backgroundColor = .green
        }
        animator.startAnimation()
    }

/*:
 ### Delaying The Start
 */
    func delayedBlockAnimation(withDuration duration: TimeInterval, delay: TimeInterval) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
            self.redSquare.backgroundColor = .green
        })
    }

    func delayedPropertyAnimator(withDuration duration: TimeInterval, delay: TimeInterval) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            self.redSquare.backgroundColor = .green
        }
        animator.startAnimation(afterDelay: delay)
    }

/*:
 ### Completion Handlers
 */

    func blockAnimationCompletion(withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, options: [], animations: {
            self.redSquare.backgroundColor = .green
        }, completion: { finished in
            print("animation finished: \(finished)")
        })
    }

    func propertyAnimatorCompletion(withDuration duration: TimeInterval) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            self.redSquare.backgroundColor = .green
        }

        animator.addCompletion { position in
            if position == .end {
                print("First completion")
            }
        }

        animator.addCompletion { position in
            if position == .end {
                print("Second completion")
            }
        }

        animator.startAnimation()
    }

/*:
 ### Adding Animations
 */
    func multipleAnimations(withDuration duration: TimeInterval, delay: TimeInterval = 0) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            self.redSquare.backgroundColor = .green
        }

        animator.addAnimations {
            self.redSquare.layer.cornerRadius = 50.0
        }

        animator.startAnimation(afterDelay: delay)
/*:
 Animations added to a running animator start immediately
*/
        animator.addAnimations({
            self.redSquare.alpha = 0.0
        }, delayFactor: 0.8)
    }

/*:
 ### Reversing Animations
 The .autoreverse option does not work with property animators
 */
    func reverseBlockAnimation(withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, options: [.autoreverse], animations: {
            self.redSquare.backgroundColor = .green
        }, completion: {_ in
            self.redSquare.backgroundColor = .red
        })
    }

    func reversePropertyAnimation(withDuration duration: TimeInterval) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            self.redSquare.backgroundColor = .green
        }, completion: { _ in
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
                self.redSquare.backgroundColor = .red
            })
        })
    }

/*:
 ### Timing Curves
 */
    func bezierPropertyAnimator(withDuration duration: TimeInterval, delay: TimeInterval = 0) {
        let point1 = CGPoint(x: 1.0, y: 0.1)
        let point2 = CGPoint(x: 1.0, y: 1.0)
        view.layoutIfNeeded()
        centerConstraint.constant = 0.0
        let animator = UIViewPropertyAnimator(duration: duration, controlPoint1: point1, controlPoint2: point2) {
            self.view.layoutIfNeeded()
        }
        animator.startAnimation(afterDelay: delay)

//    let cubicTiming = UICubicTimingParameters(controlPoint1: point1, controlPoint2: point2)
//    let springTiming = UISpringTimingParameters(dampingRatio: 0.2)
//    let customAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: cubicTiming)
    }

/*:
 ### Spring Animations
 */
    func blockSpring(withDuration duration: TimeInterval, damping: CGFloat, delay: TimeInterval = 0) {
        view.layoutIfNeeded()
        centerConstraint.constant = 0.0
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: 0.0, options: [], animations: {
            self.view.layoutIfNeeded()
        })
    }

/*:
 New in iOS 11
 */
    func propertySpring(withDuration duration: TimeInterval, damping: CGFloat, delay: TimeInterval = 0) {
        view.layoutIfNeeded()
        centerConstraint.constant = 0.0
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: damping, animations: {
            self.view.layoutIfNeeded()
        })
        animator.startAnimation(afterDelay: delay)
    }

/*:
 ### Key Frame Animations
 */
    func blockKeyFrame(withDuration duration: TimeInterval, delay: TimeInterval = 0) {
        view.layoutIfNeeded()
        UIView.animateKeyframes(withDuration: duration, delay: delay, animations: {
            self.centerConstraint.constant = 0.0
            self.view.layoutIfNeeded()

            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                self.redSquare.layer.cornerRadius = 50.0
            }

            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.view.backgroundColor = .green
            }
        })
    }

    func propertyKeyFrame(withDuration duration: TimeInterval, delay: TimeInterval = 0) {
        view.layoutIfNeeded()
        let animation = UIViewPropertyAnimator(duration: duration, curve: .linear)

        animation.addAnimations {

            UIView.animateKeyframes(withDuration: duration, delay: delay, animations: {
                self.centerConstraint.constant = 0.0
                self.view.layoutIfNeeded()

                UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                    self.redSquare.layer.cornerRadius = 50.0
                }

                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                    self.view.backgroundColor = .green
                }
            })
        }
        animation.startAnimation(afterDelay: delay)
    }
}

/*:
 Uncomment an animation function to see the effect
 */
let vc = AnimationViewController()
PlaygroundPage.current.liveView = vc

let animationDuration: TimeInterval = 3.0
let animationDelay: TimeInterval = 1.0
let animationDamping: CGFloat = 0.2

// vc.beginCommitAnimation(withDuration: animationDuration, delay: animationDelay)
// vc.blockAnimation(withDuration: animationDuration)
// vc.runningProperty(withDuration: animationDuration)
// vc.linearBlockAnimation(withDuration: animationDuration)
// vc.linearPropertyAnimator(withDuration: animationDuration)
// vc.propertyAnimator(withDuration: animationDuration)
// vc.blockAnimationCompletion(withDuration: animationDuration)
// vc.propertyAnimatorCompletion(withDuration: animationDuration)
// vc.multipleAnimations(withDuration: animationDuration, delay: animationDelay)
// vc.reverseBlockAnimation(withDuration: animationDuration)
// vc.reversePropertyAnimation(withDuration: animationDuration)
// vc.blockSpring(withDuration: animationDuration, damping: animationDamping, delay: animationDelay)
vc.propertySpring(withDuration: animationDuration, damping: animationDamping, delay: animationDelay)
// vc.bezierPropertyAnimator(withDuration: animationDuration, delay: animationDelay)
// vc.blockKeyFrame(withDuration: animationDuration, delay: animationDelay)
// vc.propertyKeyFrame(withDuration: animationDuration, delay: animationDelay)
