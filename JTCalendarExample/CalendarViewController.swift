//
//  CalendarViewController.swift
//  JTCalendarExample
//
//  Created by Jim Hildensperger on 05/10/2018.
//  Copyright © 2018 Jim Hildensperger. All rights reserved.
//

import Foundation
import JTAppleCalendar

let width = UIScreen.main.bounds.width
let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero

class CalendarViewController: UIViewController {
    private struct Constants {
        static let buttonHeight: CGFloat = 50.0
        static let monthLabelHeight: CGFloat = 50.0
        static let dayLabelHeight: CGFloat = 20.0
    }
    
    private var isRangeSelected = false
    private var selectedFrom: Date?
    private var selectedTo: Date?
    
    lazy var calendarView: JTAppleCalendarView = {
        let calendar = JTAppleCalendarView(frame: .zero)
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.backgroundColor = .clear
        calendar.minimumInteritemSpacing = 0
        calendar.allowsMultipleSelection = true
        calendar.isRangeSelectionUsed = true
        
        calendar.calendarDelegate = self
        calendar.calendarDataSource = self
        
        calendar.scrollingMode = .stopAtEachSection
        
        calendar.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseIdentifier)
        
        return calendar
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentVerticalAlignment = .top
        button.titleEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        button.backgroundColor = .blue
        button.setTitle("Select Dates", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        button.addTarget(self, action: #selector(didTapSelectDates), for: .touchUpInside)
        return button
    }()
    
    lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .blue
        label.font = UIFont.systemFont(ofSize: 18.0)
        return label
    }()
    
    lazy var daysStackView: UIStackView = {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let now = Date()

        let labels: [UILabel] = (1...7).compactMap {
            var dateComponents = gregorianCalendar.dateComponents([.year, .month, .weekOfMonth], from: now)
            dateComponents.weekday = $0
            
            guard let date = gregorianCalendar.date(from: dateComponents) else {
                return nil
            }
            
            let label = UILabel()
            label.text = DateFormatter.weekDay.string(from: date)
            label.textAlignment = .center
            label.textColor = .blue
            label.font = UIFont.boldSystemFont(ofSize: 12.0)
            return label
        }
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    var didSelectDates: ((Date, Date) -> Void)?
    
    override func loadView() {
        let width = UIScreen.main.bounds.width
        let height = width + Constants.buttonHeight + Constants.monthLabelHeight + Constants.dayLabelHeight + safeAreaInsets.bottom
        view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = true
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(calendarView)
        view.addSubview(doneButton)
        view.addSubview(monthLabel)
        view.addSubview(daysStackView)
        
        monthLabel.text = DateFormatter.calendarMonthYear.string(from: Date())
        
        NSLayoutConstraint.activate([
            monthLabel.heightAnchor.constraint(equalToConstant: Constants.monthLabelHeight),
            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            monthLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            monthLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            daysStackView.heightAnchor.constraint(equalToConstant: Constants.dayLabelHeight),
            daysStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor),
            daysStackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            daysStackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            calendarView.heightAnchor.constraint(equalToConstant: view.frame.width),
            calendarView.topAnchor.constraint(equalTo: daysStackView.bottomAnchor),
            calendarView.leftAnchor.constraint(equalTo: view.leftAnchor),
            calendarView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            doneButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.buttonHeight),
            doneButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            doneButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            ])
    }
    
    /// Mark:- Public
    
    func selectDates(startDate: Date?, endDate: Date?) {
        calendarView.deselectAllDates(triggerSelectionDelegate: false)
        
        guard let startDate = startDate ?? endDate else {
            return
        }
        
        let endDate = endDate ?? startDate
        selectedFrom = startDate
        selectedTo = endDate
        isRangeSelected = true
        calendarView.selectDates(from: startDate, to: endDate, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
    }
    
    /// Mark:- Private
    
    @objc
    private func didTapSelectDates() {
        if let first = calendarView.selectedDates.first, let last = calendarView.selectedDates.last {
            didSelectDates?(first, last)
        }
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate = Date()
        let endDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 365)
        
        return ConfigurationParameters(startDate: startDate,
                                       endDate: endDate,
                                       numberOfRows: 6,
                                       calendar: Calendar.current,
                                       generateInDates: .forFirstMonthOnly,
                                       generateOutDates: .off,
                                       firstDayOfWeek: .sunday,
                                       hasStrictBoundaries: false)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? CalendarCell else { fatalError() }
        let selectedPosition = cellState.selectedPosition()
        cell.updateSelection(selectedPosition)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarCell.reuseIdentifier, for: indexPath) as? CalendarCell else { fatalError() }
        return cell.configure(date, state: cellState)
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard visibleDates.monthDates.indices.contains(6) else { return }
        monthLabel.text = DateFormatter.calendarMonthYear.string(from: visibleDates.monthDates[6].date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        return date.isTodayOrLater
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard !isRangeSelected else {
            return selectFirstDateResettingRange(date, in: calendar)
        }
        
        guard let startDate = selectedFrom else {
            selectedFrom = date
            return calendar.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        }
        
        guard date < startDate else {
            selectedTo = date
            isRangeSelected = true
            return calendar.selectDates(from: startDate, to: date, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
//            Uncommenting the line below and removing the return from line above fixes the issue
//            return calendar.reloadData()
        }
        
        selectFirstDateResettingRange(date, in: calendar)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        calendarView.deselectAllDates(triggerSelectionDelegate: false)
        selectedFrom = date

        if isRangeSelected {
            selectedTo = nil
            isRangeSelected = false
        }
        calendarView.selectDates([selectedFrom!], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
    }
    
    /// MARK:- Private
    
    private func selectFirstDateResettingRange(_ date: Date, in calendar: JTAppleCalendarView) {
        calendar.deselectAllDates(triggerSelectionDelegate: false)
        selectedFrom = date
        selectedTo = nil
        isRangeSelected = false
        calendar.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
    }
}
