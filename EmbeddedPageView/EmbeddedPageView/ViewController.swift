//
//  ViewController.swift
//  EmbeddedPageView
//
//  Created by Don Mag on 2/15/18.
//  Copyright © 2018 DonMag. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	var myPageVC: BasicPageViewController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	@IBAction func navigationButtonsTapped(_ sender: Any) {
		
		// NOTE: This is an EXAMPLE ONLY
		//		 in actual use, we would never hard-code the page index values
		//		 (for example, if we had 20 pages, this would be silly)
		
		if let btn = sender as? UIButton {
			
			if let btnTitle = btn.currentTitle {
				
				switch btnTitle {
				case "First Page":
					myPageVC?.showIndexedPage(0)
					break
					
				case "Second Page":
					myPageVC?.showIndexedPage(1)
					break
					
				case "Third Page":
					myPageVC?.showIndexedPage(2)
					break
					
				case "Previous":
					myPageVC?.showPrevPage()
					break
					
				case "Next":
					myPageVC?.showNextPage()
					break
					
				default:
					// don't do anything if the button title doesn't match
					break
				}
				
			}
			
		}
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		// get a reference to the embedded PageViewController on load
		if let vc = segue.destination as? BasicPageViewController,
			segue.identifier == "PageControllerEmbedSegue" {
			self.myPageVC = vc
		}
		
	}
	
	
}

class BasicPageViewController: UIPageViewController {
	
	private(set) lazy var orderedViewControllers: [UIViewController] = {
		return [self.loadPageVC(byName: "firstVC"),
				self.loadPageVC(byName: "secondVC"),
				self.loadPageVC(byName: "thirdVC")]
	}()
	
	func showPrevPage() -> Void {

		// get index of current page
		let i = presentationIndex(for: self)
		
		// we don't want to "wrap around" so only change if we have a VC "to the left"
		if i > 0 {
			setViewControllers([orderedViewControllers[i - 1]], direction: .reverse, animated: true) { _ in
				print("showPrevPage Done")
			}
		}
		
	}
	
	func showNextPage() -> Void {
		
		// get index of current page
		let i = presentationIndex(for: self)
		
		// we don't want to "wrap around" so only change if we have a VC "to the right"
		if i < orderedViewControllers.count - 1 {
			setViewControllers([orderedViewControllers[i + 1]], direction: .forward, animated: true) { _ in
				print("showNextPage Done")
			}
		}
		
	}
	
	func showIndexedPage(_ targetIndex: Int) -> Void {

		// get index of current page
		let currentIndex = presentationIndex(for: self)
		
		// if the "target" index equals "current" index, we're already on that page
		guard targetIndex != currentIndex else {
			return
		}
		
		// if "target" index is less-than current index (target page is "to the left")
		// set direction to .reverse, else to .forward
		setViewControllers([orderedViewControllers[targetIndex]], direction: targetIndex < currentIndex ? .reverse : .forward, animated: true) { _ in
			print("showIndexedPage Done")
		}
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dataSource = self
		
		if let firstViewController = orderedViewControllers.first {
			setViewControllers([firstViewController],
							   direction: .forward,
							   animated: true,
							   completion: nil)
		}
		
	}
	
	private func loadPageVC(byName: String) -> UIViewController {
		// make sure the named VC can be loaded
		guard let vc = self.storyboard?.instantiateViewController(withIdentifier: byName) else {
			// we want to handle a failed load, so for now just return an ampty VC
			// in real use, we want to do something better
			return UIViewController()
		}
		return vc
	}
	
}

extension BasicPageViewController: UIPageViewControllerDelegate {
	
	// if BOTH of these methods are implemented, UIPageViewController shows a
	//   UIPageControl (standard "dots" bar)
	
	// we *want* to use the presentationIndex() method (to get the index of the current page)
	// but we *don't* want the "dots" - un-comment the following if you *do* want the "dots"

	/*
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return orderedViewControllers.count
	}
	*/
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		
		guard let firstViewController = viewControllers?.first,
			let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
				return 0
		}
		
		return firstViewControllerIndex
		
	}
	
}

extension BasicPageViewController: UIPageViewControllerDataSource {
	
	func pageViewController(_ pageViewController: UIPageViewController,
							viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
			return nil
		}
		
		let nextIndex = viewControllerIndex + 1
		let orderedViewControllersCount = orderedViewControllers.count
		
		guard orderedViewControllersCount != nextIndex else {
			return nil
		}
		
		guard orderedViewControllersCount > nextIndex else {
			return nil
		}
		
		return orderedViewControllers[nextIndex]
		
	}
	
	func pageViewController(_ pageViewController: UIPageViewController,
							viewControllerBefore viewController: UIViewController) -> UIViewController? {
		
		guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
			return nil
		}
		
		let previousIndex = viewControllerIndex - 1
		
		guard previousIndex > -1 else {
			return nil
		}
		
		guard orderedViewControllers.count > previousIndex else {
			return nil
		}
		
		return orderedViewControllers[previousIndex]
		
	}
	
}
