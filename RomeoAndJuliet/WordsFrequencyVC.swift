//
//  ViewController.swift
//  RomeoAndJuliet
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import UIKit
import Combine

import RJServices
import RJViewModel
import RJImplementations
import RJResources

class WordsFrequencyVC: UIViewController {
	
	@IBOutlet var indexSegmentControl: UISegmentedControl!
	@IBOutlet var stateLabel: UILabel!
	@IBOutlet var tableView: UITableView!

	var vm: WordsFrequencyVM!
	
	private typealias SortOption = (key: WordFrequencySortingKey, title: String)
	private let sortOptions: [SortOption] = [
		SortOption(.alphabetical, "Alphabetical"),
		SortOption(.mostFrequent, "Frequency"),
		SortOption(.wordLength, "Length")
	]
	
	private var cancellables = Set<AnyCancellable>()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupBindings()
		setupSortKeySegmentControl()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		vm.onAppear()
	}
}

extension WordsFrequencyVC {
	
	// MARK: - Actions
	@IBAction func onIndexSelectionChanged(sender: UISegmentedControl) {
		// TODO: make proper map & setup initial
		let indexKey = sortOptions[sender.selectedSegmentIndex].key
		vm.onIndexKeyChanged(indexKey)
	}
}

// MARK: - Private
private extension WordsFrequencyVC {
	
	func setupSortKeySegmentControl() {
		indexSegmentControl.removeAllSegments()
		for option in sortOptions.reversed() {
			indexSegmentControl.insertSegment(withTitle: option.title, at: 0, animated: false)
		}
		
		guard let selectedIndex = sortOptions.firstIndex(where: { vm.sortingKey == $0.key }) else {
			assertionFailure("\(vm.sortingKey) is not in \(sortOptions)")
			vm.onIndexKeyChanged(sortOptions[0].key)
			indexSegmentControl.selectedSegmentIndex = 0
			return
		}
		
		indexSegmentControl.selectedSegmentIndex = selectedIndex
	}
	
	func setupBindings() {
		vm.state
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				self?.stateUpdated(to: state)
			}
			.store(in: &cancellables)
		
		vm.rowItems
			.receive(on: DispatchQueue.main)
			.sink { [weak self] items in
				self?.itemsUpdated(to: items)
			}
			.store(in: &cancellables)
	}
	
	func stateUpdated(to state: WordsFrequencyVM.State) {
		stateLabel.text = "\(state)"
	}
	
	func itemsUpdated(to items: [WordsFrequencyVM.Item]) {
		self.tableView.beginUpdates()
		self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
		self.tableView.endUpdates()
	}
}

// MARK: - Protocol Conformance
// MARK: - Table View Data Source
extension WordsFrequencyVC: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		vm.rowItems.value.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .value1, reuseIdentifier: "WordFrequencyCell")
		let item = vm.rowItems.value[indexPath.row]
		cell.textLabel?.text = item.word
		cell.detailTextLabel?.text = "\(item.frequency)"
		return cell
	}
	
}

// MARK: - Table View Delegate
// Just to bind it in the storyboard beforehand
extension WordsFrequencyVC: UITableViewDelegate { }
