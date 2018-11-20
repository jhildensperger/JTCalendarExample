//
//  CalendarCell.swift
//  JTCalendarExample
//
//  Created by Jim Hildensperger on 05/10/2018.
//  Copyright © 2018 Jim Hildensperger. All rights reserved.
//

import JTAppleCalendar

class CalendarCell: JTAppleCell {
    static let reuseIdentifier = String(describing: self)
    
    struct Constants {
        static let selectionViewHeight: CGFloat = 36.0
        static let selectionViewOffset: CGFloat = 1.0
    }
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    lazy var fullSelectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0.7, alpha: 1)
        return view
    }()
    
    lazy var rightSelectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        return view
    }()
    
    lazy var leftSelectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(rightSelectionView)
        contentView.addSubview(leftSelectionView)
        contentView.addSubview(fullSelectionView)
        contentView.addSubview(dateLabel)
        
        fullSelectionView.layer.cornerRadius = Constants.selectionViewHeight/2.0
        
        contentView.clipsToBounds = false
        clipsToBounds = false
        
        configureLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateSelection(.none)
    }
    
    /// required Init
    ///
    /// - Parameter aDecoder: aDecoder
    /// - Warning: unimplemented!
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ date: Date, state: CellState) -> Self {
        dateLabel.text = DateFormatter.calendarDay.string(from: date)
        
        let disabledDate = !date.isTodayOrLater
        let selectedPosition = disabledDate ? .none : state.selectedPosition()
        
        updateSelection(selectedPosition)
        
        if disabledDate {
            dateLabel.textColor = UIColor.blue.withAlphaComponent(0.5)
        }
        
        return self
    }
    
    func updateSelection(_ position: SelectionRangePosition) {
        dateLabel.textColor = position == .none ? .blue : .white
        
        switch position {
        case .full:
            fullSelectionView.isHidden = false
            rightSelectionView.isHidden = true
            leftSelectionView.isHidden = true
        case .middle:
            fullSelectionView.isHidden = true
            rightSelectionView.isHidden = false
            leftSelectionView.isHidden = false
        case .left:
            fullSelectionView.isHidden = false
            rightSelectionView.isHidden = true
            leftSelectionView.isHidden = false
        case .right:
            fullSelectionView.isHidden = false
            rightSelectionView.isHidden = false
            leftSelectionView.isHidden = true
        case .none:
            fullSelectionView.isHidden = true
            rightSelectionView.isHidden = true
            leftSelectionView.isHidden = true
        }
    }
    
    private func configureLayout() {
        let centerXView = UIView()
        centerXView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(centerXView)
        
        NSLayoutConstraint.activate([
            centerXView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            centerXView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dateLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            dateLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            fullSelectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            fullSelectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            fullSelectionView.widthAnchor.constraint(equalToConstant: Constants.selectionViewHeight),
            fullSelectionView.heightAnchor.constraint(equalToConstant: Constants.selectionViewHeight),
            
            rightSelectionView.rightAnchor.constraint(equalTo: centerXView.leftAnchor),
            rightSelectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: -Constants.selectionViewOffset),
            rightSelectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightSelectionView.heightAnchor.constraint(equalToConstant: Constants.selectionViewHeight),
            
            leftSelectionView.leftAnchor.constraint(equalTo: centerXView.rightAnchor),
            leftSelectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: Constants.selectionViewOffset),
            leftSelectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftSelectionView.heightAnchor.constraint(equalToConstant: Constants.selectionViewHeight),
            ])
    }
}
