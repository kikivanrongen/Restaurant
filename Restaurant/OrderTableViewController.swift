//
//  OrderTableViewController.swift
//  Restaurant
//
//  Created by Kiki van Rongen on 07-05-18.
//  Copyright © 2018 Kiki van Rongen. All rights reserved.
//

import UIKit

protocol AddToOrderDelegate {
    func added(menuItem: MenuItem)
}

class OrderTableViewController: UITableViewController, AddToOrderDelegate {
    
    // MARK: Actions
    
    // confirm order and pass data
    @IBAction func submitTapped(_ sender: UIBarButtonItem) {
        let orderTotal = menuItems.reduce(0.0) { (result, menuItem) -> Double in
            return result + menuItem.price
        }
        let formattedOrder = String(format: "$%.2f", orderTotal)
        let alert = UIAlertController(title: "Confirm Order", message: "You are about to submit your order with a total of \(formattedOrder)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { action in
            self.uploadOrder()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // exit to order list
    @IBAction func unwindToOrderList(segue: UIStoryboardSegue) {
        if segue.identifier == "DismissConfirmation" {
            menuItems.removeAll()
            tableView.reloadData()
            updateBadgeNumber()
        }
    }
    
    // MARK: Variables
    
    var menuItems = [MenuItem]()
    var orderMinutes: Int?
    
    // MARK: --- Functions
    
    // add order to collection
    func added(menuItem: MenuItem) {
        menuItems.append(menuItem)
        let count = menuItems.count
        let indexPath = IndexPath(row: count-1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        updateBadgeNumber()
    }
    
    // match size of collection
    func updateBadgeNumber() {
        let badgeValue = menuItems.count > 0 ?
            "\(menuItems.count)" : nil
        navigationController?.tabBarItem.badgeValue = badgeValue
    }
    
    // upload order data
    func uploadOrder() {
        let menuIds = menuItems.map { $0.id }
        MenuController.shared.submitOrder(menuIds: menuIds)
        { (minutes) in DispatchQueue.main.async {
            if let minutes = minutes {
                self.orderMinutes = minutes
                self.performSegue(withIdentifier:
                "ConfirmationSegue", sender: nil)
            }
        }
        }
    }
    
    // MARK: Table view functions
    
    // set number of rows equal to number of menu items
    override func tableView(_ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    // create cells
    override func tableView(_ tableView: UITableView, cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier:
                "OrderCellIdentifier", for: indexPath)
        
            configure(cell: cell, forItemAt: indexPath)
            return cell
    }
    
    // enable deleting
    override func tableView(_ tableView: UITableView, canEditRowAt
        indexPath: IndexPath) -> Bool {
            return true
    }
    
    // remove deleted item and update badge number
    override func tableView(_ tableView: UITableView, commit
    editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        menuItems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)

        updateBadgeNumber()
        }
    }
    
    // adjust cell height
    override func tableView(_ tableView: UITableView, heightForRowAt
        indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: Loading and configuring
    
    func configure(cell: UITableViewCell, forItemAt indexPath:
        IndexPath) {
        
            // insert text in cells
            let menuItem = menuItems[indexPath.row]
            cell.textLabel?.text = menuItem.name
            cell.detailTextLabel?.text = String(format: "$%.2f", menuItem.price)
        
            // set image
            MenuController.shared.fetchImage(url: menuItem.imageURL)
            { (image) in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    if let currentIndexPath =
                        self.tableView.indexPath(for: cell),
                        currentIndexPath != indexPath {
                        return
                    }
                    cell.imageView?.image = image
                }
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // enable editing
        navigationItem.leftBarButtonItem = editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmationSegue" {
            let orderConfirmationViewController = segue.destination as! OrderConfirmationViewController
            orderConfirmationViewController.minutes = orderMinutes
        }
    }

}
