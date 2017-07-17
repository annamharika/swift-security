//
//  ViewController.swift
//  swift-security
//
//  Created by Harika Annam on 7/13/17.
//  Copyright © 2017 Innominds Mobility. All rights reserved.
//

import UIKit
import InnoSecurity

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var keyChainWrapperObj = InnoKeyChainWrapper()
    @IBOutlet weak var valuesTableView: UITableView!
    let cellReUseIdentifier = "cell"
    let keychainValues = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        valuesTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReUseIdentifier)
        print("getAllKeyChainItemsOfClass  \(keyChainWrapperObj.getAllKeyChainItemsOfClass("serviceName"))")
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
        self.keychainValues.removeAllObjects()
        guard let keychainValue = keyChainWrapperObj.getAllKeyChainItemsOfClass("serviceName") as? [Any] else {
            return
        }
        self.keychainValues.addObjects(from: keychainValue)
        self.valuesTableView.reloadData()
    }
    // MARK: - Tableview data source methods
    /// Asks the data source to return the number of sections in the table view.
    ///
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    ///   - section: section in tableview
    /// - Returns: The number of sections in tableView. The default value is 1.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keychainValues.count
    }
    /// Asks the data source for a cell to insert in a particular location of the table view.
    ///
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that
    /// the table view can use for the specified row. An assertion is raised if you return nil.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// create a new cell if needed or reuse an old one
        let cell: UITableViewCell = tableView.dequeueReusableCell(
            withIdentifier: cellReUseIdentifier) as UITableViewCell!
        cell.textLabel?.text =
            ((self.keychainValues.object(at: indexPath.row) as AnyObject).value(forKey: "name")  as? String)
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let addValues = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:
            "AddValuesViewController") as? AddValuesViewController {
            if let navigator = navigationController {
                addValues.fromEdit = true
                addValues.userName =
                    ((self.keychainValues.object(at: indexPath.row) as AnyObject).value(forKey: "name")  as? String)!
                navigator.pushViewController(addValues, animated: true)
            }
        }
    }
    @IBAction func addValuesToKeyChainBtnAction(_ sender: Any) {
        if let addValues = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:
            "AddValuesViewController") as? AddValuesViewController {
            if let navigator = navigationController {
                navigator.pushViewController(addValues, animated: true)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
