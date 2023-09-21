//
//  ViewController.swift
//  RomeoAndJuliet
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import UIKit
import RJCore
import RJViewModel

import RJServiceImplementations

class WordsFrequencyVC: UIViewController {
	
	@IBOutlet var indexSegmentControl: UISegmentedControl!
	@IBOutlet var tableView: UITableView!

	let vm: WordsFrequencyVM
	
	init(vm: WordsFrequencyVM) {
		self.vm = vm
//		self.vm = WordsFrequencyVC.testVM

		super.init()
	}
	
	required init?(coder: NSCoder) {
		self.vm = WordsFrequencyVC.testVM
		super.init(coder: coder)
//		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		vm.onAppear()
	}
	
	private static var testVM: WordsFrequencyVM {
		let filepath = Bundle.main.path(forResource: "Romeo-and-Juliet", ofType: "txt")!
		let data = try! Data(contentsOf: URL(fileURLWithPath: filepath)) //String(contentsOfFile: filepath)
		return WordsFrequencyVM(data, wordCounter: StandardWordsCounter(), indexBuilder: StandardIndexBuilder())
	}
}

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

// Just to bind it in the storyboard beforehand
extension WordsFrequencyVC: UITableViewDelegate { }
