import UIKit

public protocol LongPressSortTableViewDelegate: class {
    func didMoveRow(at initialIndexPath: IndexPath, to indexPath: IndexPath)
}

public class LongPressSortTableView: UITableView {
    
    public weak var moveDelegate: LongPressSortTableViewDelegate?
    
    private var longPressGesture: UILongPressGestureRecognizer?
    private var snapshot: UIImageView?
    private var initialIndexPath: IndexPath?
    private var scrollRate: CGFloat = 0
    private var scrollDisplayLink: CADisplayLink?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        prepareLongPressGesture()
    }
    
    private func prepareLongPressGesture() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(LongPressSortTableView.longPressGestureRecognized(gestureRecognizer:)))
        self.addGestureRecognizer(longPressGesture!)
    }
    
    @objc
    private func longPressGestureRecognized(gestureRecognizer: UILongPressGestureRecognizer) {
        let state = gestureRecognizer.state
        let location = gestureRecognizer.location(in: self)
        let indexPath = indexPathForRow(at: location)
        switch state {
        case .began:
            guard let indexPath = indexPath else { break }
            guard let cell = cellForRow(at: indexPath) else { break }
            initialIndexPath = indexPath
            snapshot = snapshop(of: cell)
            guard let snapshot = snapshot else { return }
            var center = cell.center
            snapshot.center = center
            snapshot.alpha = 0
            addSubview(snapshot)
            
            addScrollDisplayLink()
            
            UIView.animate(
                withDuration: 0.25,
                animations: { [weak self] _ in
                    center.y = location.y
                    self?.snapshot?.center = center
                    self?.snapshot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    self?.snapshot?.alpha = 0.98
                    cell.alpha = 0
                },
                completion: { finished in
                    guard finished else { return }
                    cell.isHidden = true
            }
            )
        case .changed:
            updateCurrentLocation(at: gestureRecognizer)
            
            var rect = bounds
            rect.size.height -= contentInset.top
            let scrollZoneHeight = rect.size.height / 6.0
            let bottomScrollBeginning = contentOffset.y + contentInset.top + rect.size.height - scrollZoneHeight
            let topScrollBeginning = contentOffset.y + contentInset.top  + scrollZoneHeight
            
            if location.y >= bottomScrollBeginning {
                scrollRate = (location.y - bottomScrollBeginning) / scrollZoneHeight
            } else if location.y <= topScrollBeginning {
                scrollRate = (location.y - topScrollBeginning) / scrollZoneHeight
            } else {
                scrollRate = 0
            }
            
            
            
        default:
            guard
                let initialIndexPath = initialIndexPath,
                let cell = cellForRow(at: initialIndexPath),
                let snapshot = snapshot
                else { break }
            
            removeScrollDisplayLink()
            scrollRate = 0
            
            cell.isHidden = false
            cell.alpha = 0
            
            UIView.animate(
                withDuration: 0.25,
                animations: { [weak self] _ in
                    self?.snapshot?.center = cell.center
                    self?.snapshot?.transform = CGAffineTransform.identity
                    self?.snapshot?.alpha = 0
                    cell.alpha = 1
                },
                completion: { [weak self] finished in
                    guard finished else { return }
                    self?.initialIndexPath = nil
                    snapshot.removeFromSuperview()
                    self?.snapshot = nil
                    self?.reloadData()
                }
            )
        }
    }
    
    private func addScrollDisplayLink() {
        scrollDisplayLink = CADisplayLink(target: self, selector: #selector(LongPressSortTableView.scrollTableWithCell(at:)))
        scrollDisplayLink?.add(to: .main, forMode: .defaultRunLoopMode)
    }
    
    private func removeScrollDisplayLink() {
        scrollDisplayLink?.invalidate()
        scrollDisplayLink = nil
    }
    
    private func updateCurrentLocation(at gestureRecognizer: UILongPressGestureRecognizer) {
        guard let snapshot = snapshot else { return }
        let location = gestureRecognizer.location(in: self)
        let indexPath = indexPathForRow(at: location)
        var center = snapshot.center
        center.y = location.y
        snapshot.center = center
        if let indexPath = indexPath, let initialIndexPath = initialIndexPath, indexPath != initialIndexPath {
            moveRow(at: initialIndexPath, to: indexPath)
            moveDelegate?.didMoveRow(at: initialIndexPath, to: indexPath)
            self.initialIndexPath = indexPath
        }
    }
    
    @objc
    private func scrollTableWithCell(at displayLink: CADisplayLink) {
        guard let longPressGesture = longPressGesture else { return }
        let location = longPressGesture.location(in: self)
        
        guard !location.x.isNaN && !location.y.isNaN else { return }
        
        let offsetY = contentOffset.y + scrollRate * 10
        var newOffset = CGPoint(x: contentOffset.x, y: offsetY)
        
        if newOffset.y < -contentInset.top {
            newOffset.y = -contentInset.top
        } else if contentSize.height + contentInset.bottom < frame.size.height {
            newOffset = contentOffset
        } else if newOffset.y > contentSize.height + contentInset.bottom - frame.size.height {
            newOffset.y = contentSize.height + contentInset.bottom - frame.size.height
        }
        
        updateCurrentLocation(at: longPressGesture)
        contentOffset = newOffset
    }
    
    private func snapshop(of cell: UITableViewCell) -> UIImageView {
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0.0)
        cell.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0
        snapshot.layer.shadowOffset = CGSize(width: -5, height: 0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        snapshot.alpha = 0.6
        return snapshot
    }
    
}
