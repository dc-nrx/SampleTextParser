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

	let vm: WordsFrequencyVM
	
	private var cancellables = Set<AnyCancellable>()
	
	init(vm: WordsFrequencyVM) {
		self.vm = vm

		super.init()
		self.setupBindings()
	}
	
	required init?(coder: NSCoder) {
		self.vm = WordsFrequencyVC.testVM
		super.init(coder: coder)
		self.setupBindings()
//		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		vm.onAppear()
	}
	
	private static var testVM: WordsFrequencyVM {
		let str = try! String(contentsOfFile: LocalTextFile.romeoAndJuliet.path)
		return WordsFrequencyVM(str, wordCounter: StandardWordsCounter(), indexBuilder: StandardIndexBuilder())
	}
	
	private func setupBindings() {
		vm.state
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				self?.updateStateLabel(with: state)
			}
			.store(in: &cancellables)
		
		vm.rowItems
			.receive(on: DispatchQueue.main)
			.sink { [weak self] items in
				self?.tableView.reloadData()
			}
			.store(in: &cancellables)
	}
	
	private func updateStateLabel(with state: WordsFrequencyVM.State) {
		stateLabel.text = "\(state)"
	}
}

extension WordsFrequencyVC {
	
	// MARK: - Actions
	@IBAction func onIndexSelectionChanged(sender: UISegmentedControl) {
		// TODO: make proper map & setup initial
		let indexKey: WordFrequencyIndexKey = sender.selectedSegmentIndex == 0 ? .mostFrequent : .alphabetical
		vm.onIndexKeyChanged(indexKey)
	}
}

// MARK: - Private
private extension WordsFrequencyVC {
	
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
