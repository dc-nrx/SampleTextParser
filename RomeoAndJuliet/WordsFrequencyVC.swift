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
	
	private typealias SortOption = (WordFrequencySortingKey, String)
	private let sortOptions: [SortOption] = [
		SortOption(.alphabetical, "Alphabetical"),
		SortOption(.mostFrequent, "Frequency"),
		SortOption(.wordLength, "Length")
	]
	
	private var cancellables = Set<AnyCancellable>()
	
	required init?(coder: NSCoder) {
		self.vm = WordsFrequencyVC.testVM
		super.init(coder: coder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupBindings()
		setupSortKeySegmentControl()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		vm.onAppear()
	}
	
	private static var testVM: WordsFrequencyVM {
		let textProvider = FileTextProvider(LocalTextFile.romeoAndJuliet.path)
		return WordsFrequencyVM(textProvider, wordCounter: StandardWordsCounter(), indexBuilder: StandardIndexBuilder())
	}

}

extension WordsFrequencyVC {
	
	// MARK: - Actions
	@IBAction func onIndexSelectionChanged(sender: UISegmentedControl) {
		// TODO: make proper map & setup initial
		let indexKey = sortOptions[sender.selectedSegmentIndex].0
		vm.onIndexKeyChanged(indexKey)
	}
}

// MARK: - Private
private extension WordsFrequencyVC {
	
	func setupSortKeySegmentControl() {
		indexSegmentControl.removeAllSegments()
		for option in sortOptions.reversed() {
			indexSegmentControl.insertSegment(withTitle: option.1, at: 0, animated: false)
		}
		indexSegmentControl.selectedSegmentIndex = sortOptions.firstIndex { vm.sortingKey == $0.0 }!
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
