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

class WordsFrequencyVC: UIViewController {
	
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var controlsView: UIView!
	@IBOutlet var stateLabel: UILabel!
	@IBOutlet var totalWordsLabel: UILabel!
	@IBOutlet var indexSegmentControl: UISegmentedControl!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	/**
	 The view model. Must be injected right after initialization, and must not be changed afterwards.
	 
	 - Note: I was tempted to make it a `let` and pass on init, as suggested here
	 https://www.kodeco.com/books/advanced-ios-app-architecture ,
	 but the proposed implementation has a significant downside of forbiding interface files usage
	 (see `NiblessViewController` file from the book materials:
	 https://github.com/kodecocodes/arch-materials/blob/editions/4.0/05-architecture-mvvm/projects/final/KooberApp/Packages/KooberUIKit/Sources/KooberUIKit/Reusable/UIKit/NiblessComponents/NiblessViewController.swift )
	 Thus, the decision has been made in favor of `var` + injection right after init,
	 which is still perfectly safe if used properly. And even if overlooked,
	 it would just lead to an instant and obvious crash during development.
	 */
	@Injected var vm: WordsFrequencyVM!
	
	private typealias SortOption = (key: WordFrequencySortingKey, title: String)
	private let sortOptions: [SortOption] = [
		SortOption(.alphabetical, "Alphabetical"),
		SortOption(.mostFrequent, "Frequency"),
		SortOption(.wordLength, "Length")
	]
	
	private var cancellables = Set<AnyCancellable>()

	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupBindings()
		setupSortKeySegmentControl()
		updateControlsViewShadow()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		vm.onAppear()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateControlsViewShadow()
	}
}

// MARK: - Actions
extension WordsFrequencyVC {
		
	@IBAction func onIndexSelectionChanged(sender: UISegmentedControl) {
		let indexKey = sortOptions[sender.selectedSegmentIndex].key
		vm.onSortingKeyChanged(indexKey)
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
			vm.onSortingKeyChanged(sortOptions[0].key)
			indexSegmentControl.selectedSegmentIndex = 0
			return
		}
		
		indexSegmentControl.selectedSegmentIndex = selectedIndex
	}
	
	func updateControlsViewShadow() {
		switch view.traitCollection.userInterfaceStyle {
		case .dark:
			controlsView.layer.shadowColor = UIColor.white.cgColor
		default: // .light, .unspecified and potential future cases
			controlsView.layer.shadowColor = UIColor.black.cgColor
		}
		controlsView.layer.shadowOpacity = 0.8
		controlsView.layer.shadowOffset = CGSize(width: 0, height: 4)
		controlsView.layer.shadowRadius = 4
	}
	
	func setupBindings() {
		vm.state
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.updateStateLabel()
			}
			.store(in: &cancellables)
		
		vm.rowItems
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.reloadWithNewItems()
			}
			.store(in: &cancellables)
	}
	
	func updateStateLabel() {
		stateLabel.text = "State: \(vm.state.value)"
		if vm.loadingInProgress && !activityIndicator.isAnimating {
			activityIndicator.startAnimating()
		} else if !vm.loadingInProgress {
			activityIndicator.stopAnimating()
		}
	}
	
	func reloadWithNewItems() {
		totalWordsLabel.text = "Total words: \(vm.rowItems.value.count)"
		
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
