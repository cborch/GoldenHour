//
//  ListVC.swift
//  GoldenHour
//
//  Created by Carter Borchetta on 12/4/19.
//  Copyright © 2019 Carter Borchetta. All rights reserved.
//

import UIKit
import GooglePlaces

class ListVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    var currentPage = 0
    var solarDetials = SolarDetails()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToPageVC" {
            let destiantion = segue.destination as! PageVC
            currentPage = tableView.indexPathForSelectedRow!.row
            destiantion.currentPage = currentPage
            destiantion.solarDetails = solarDetials
        }
    }
    

    
    @IBAction func editBarButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editBarButton.title = "Edit"
            addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            editBarButton.title = "Done"
            addBarButton.isEnabled = false
        }
    }
    
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue:UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue) |
            GMSPlaceField.addressComponents.rawValue |
            GMSPlaceField.formattedAddress.rawValue)!
            
            //GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            //UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields
        autocompleteController.tableCellBackgroundColor = UIColor.black
        autocompleteController.primaryTextColor = UIColor.gray
        autocompleteController.secondaryTextColor = UIColor.gray
        autocompleteController.primaryTextHighlightColor = UIColor.white
        autocompleteController.tableCellSeparatorColor = UIColor.white
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    



}

extension ListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solarDetials.solarDetailsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = solarDetials.solarDetailsArray[indexPath.row].name
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            solarDetials.solarDetailsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            //saveLocations()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = solarDetials.solarDetailsArray[sourceIndexPath.row]
        solarDetials.solarDetailsArray.remove(at: sourceIndexPath.row)
        solarDetials.solarDetailsArray.insert(itemToMove, at: destinationIndexPath.row)
        //saveLocations()
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return (proposedDestinationIndexPath.row == 0 ? sourceIndexPath : proposedDestinationIndexPath)
    }
    
    func updateTable(place: GMSPlace) {
        let newIndexPath = IndexPath(row: solarDetials.solarDetailsArray.count, section: 0)
        
        let newSolarDetail = SolarDetail()
        newSolarDetail.name = place.name!
        newSolarDetail.coordinate = place.coordinate
        newSolarDetail.location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        newSolarDetail.getTimes(date: Date())
        
        solarDetials.solarDetailsArray.append(newSolarDetail)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        //saveLocations()
    }
}

extension ListVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        print("\(place.coordinate)")
        updateTable(place: place)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
