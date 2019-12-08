//
//  PageVC.swift
//  GoldenHour
//
//  Created by Carter Borchetta on 12/4/19.
//  Copyright © 2019 Carter Borchetta. All rights reserved.
//

import UIKit
import CoreLocation

class PageVC: UIPageViewController {
    
    var currentPage = 0
    var solarDetails = SolarDetails()
    var pageControl: UIPageControl!
    var listButton: UIButton!
    var barButtonWidth: CGFloat = 44
    var barButtonHeight: CGFloat = 44

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self
        
        //var newLocation = SolarDetail(date: Date(), location: CLLocation())
        //solarDetials.solarDetailsArray.append(newLocation)
        
        var currentLocation = CLLocation(latitude: 40.38, longitude: -118.83)
        var newLocation = CLLocation(latitude: 42.339, longitude: -71.1586)
        var newSolarDetail = SolarDetail()
        solarDetails.solarDetailsArray.append(newSolarDetail)
        print("^ I am in PageVC getting the times for an empty location \(solarDetails.solarDetailsArray[currentPage].location)")
        print("^ In page VC the times from the empty locationa are \(solarDetails.solarDetailsArray[currentPage].sunset)")
        //let solarDetail1 = SolarDetail(date: Date(), location: currentLocation)
        //let solarDetail2 = SolarDetail(date: Date(), location: newLocation)
        
        //solarDetails.solarDetailsArray.append(solarDetail1)
        //solarDetails.solarDetailsArray.append(solarDetail2)

        setViewControllers([createViewController(forPage: 0)], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configurePageControl()
        configureListButton()
    }
    
    func configureListButton() {
        let safeHeight = view.frame.height - view.safeAreaInsets.bottom
        listButton = UIButton(frame: CGRect(x: view.frame.width - barButtonWidth - 10, y: safeHeight - barButtonHeight, width: barButtonWidth, height: barButtonHeight))
        listButton.setImage(UIImage(named: "listbutton"), for: .normal)
        listButton.setImage(UIImage(named: "listbutton-highlighted"), for: .highlighted)
        listButton.addTarget(self, action: #selector(segueToListVC), for: .touchUpInside)
        listButton.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(listButton)
        view.bringSubviewToFront(listButton)
    }
    
    @objc func segueToListVC() {
        performSegue(withIdentifier: "ToListVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToListVC" {
            let destination = segue.destination as! ListVC
            destination.solarDetials = solarDetails
            destination.currentPage = currentPage
            
        }
    }
    
    @IBAction func unwindFromListVC(sender: UIStoryboardSegue) {
        pageControl.numberOfPages = solarDetails.solarDetailsArray.count
        pageControl.currentPage = currentPage
        setViewControllers([createViewController(forPage: currentPage)], direction: .forward, animated: false, completion: nil)
    }
    
    func configurePageControl() {
        let pageControlHeight: CGFloat = barButtonHeight
        let pageControlWidth: CGFloat = view.frame.width - (barButtonWidth * 2)
        let safeHeight = view.frame.height - view.safeAreaInsets.bottom
        pageControl = UIPageControl(frame: CGRect(x: (view.frame.width - pageControlWidth) / 2, y: safeHeight - pageControlHeight, width: pageControlWidth, height: pageControlHeight))
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.backgroundColor = UIColor.black
        pageControl.numberOfPages = solarDetails.solarDetailsArray.count
        pageControl.currentPage = currentPage
        pageControl.addTarget(self, action: #selector(pageControlPressed), for: .touchUpInside)
        
        view.addSubview(pageControl)
    }
    
    func createViewController(forPage page: Int) -> ViewController {
        currentPage = min(max(0, page), solarDetails.solarDetailsArray.count - 1)
        let viewController = storyboard!.instantiateViewController(withIdentifier: "ViewController") as! ViewController // Like creating a DetialVC object I think
        
        viewController.solarDetails = solarDetails
        viewController.currentPage = currentPage
        return viewController
    }
    
    


}

extension PageVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? ViewController {// Can I create a new viewController from the one that is being passed in as the type DetialVC(make sure its DetailVC
            if currentViewController.currentPage < solarDetails.solarDetailsArray.count - 1 { // See if swipe isn't the last page, then we can go one more
                return createViewController(forPage: currentViewController.currentPage + 1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? ViewController {
            if currentViewController.currentPage > 0 {
                return createViewController(forPage: currentViewController.currentPage - 1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?[0] as? ViewController {
            pageControl.currentPage = currentViewController.currentPage
        }
    }
    
    @objc func pageControlPressed() {
        if let currentViewController = self.viewControllers?[0] as? ViewController {
            currentPage = currentViewController.currentPage
            if pageControl.currentPage < currentPage {
                setViewControllers([createViewController(forPage: pageControl.currentPage)], direction: .reverse, animated: true, completion: nil)
            } else if pageControl.currentPage > currentPage {
                setViewControllers([createViewController(forPage: pageControl.currentPage)], direction: .forward, animated: true, completion: nil)
            }
        }
    }
        
}
