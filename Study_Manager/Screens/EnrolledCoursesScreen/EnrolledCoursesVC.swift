//
//  EnrolledCoursesVC.swift
//  Study_Manager
//
//  Created by Dat Truong on 26/04/2019.
//  Copyright © 2019 Dat Truong. All rights reserved.
//

import UIKit

protocol EnrolledCoursesVCProtocol: class {
    
    func showLoading()
    
    func hideLoading()
    
    func onShowError(error: AppError)
    
    func onGetEnrolledCoursesSuccess(enrolledCourses: [CourseDetail])
    
    func onLoadDataSuccess(userData: User)
    
}

class EnrolledCoursesVC: UIViewController, EnrolledCoursesVCProtocol {

    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var notFoundLbl: UILabel!
    @IBOutlet weak var detailTitleLbl: UILabel!

    
    //MARK: - Properties
    var userId: String?
    var courses = [CourseDetail]()
    var presenter: EnrolledCoursesPresenterProtocol?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(HomeVC.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.white
        refreshControl.backgroundColor = UIColor.appLightColor
        
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.appDarkColor
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(self.refreshControl)
        
        presenter = EnrolledCoursesPresenter(view: self)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCourses()
    }
    
    //MARK: - Functions
    
    func loadCourses() {
        if let userId = self.userId {
            presenter?.performGetEnrolledCourses(userId: userId)
        }
    }
    
    //MARK: Actions
    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func goToCourseDetailScreen(courseId: String){
        guard let courseDetailVC = storyboard?.instantiateViewController(withIdentifier: AppStoryBoard.courseDetailVC.identifier) as? CourseDetailVC else {return}
        courseDetailVC.courseId = courseId
        present(courseDetailVC, animated: true, completion: nil)
        courseDetailVC.addCardBtn?.isHidden = true
        courseDetailVC.enrollBtn?.isHidden = true
        courseDetailVC.addCardBtn?.isHidden = true
        courseDetailVC.instructLbl?.isHidden = true
    }
    
    //MARK: - Protocols
    func onLoadDataSuccess(userData: User) {
        userId = userData._id
    }
    
    func showLoading() {
        if !refreshControl.isRefreshing {
            showLoadingIndicator()
        }
    }
    
    func hideLoading() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        } else {
            hideLoadingIndicator()
        }
    }
    
    func onShowError(error: AppError) {
        showError(message: error.description)
    }
    
    func onGetEnrolledCoursesSuccess(enrolledCourses: [CourseDetail]) {
        if enrolledCourses.count > 0 {
            tableView.isHidden = false
            courses = enrolledCourses
            notFoundLbl.isHidden = true
            tableView.reloadData()
        } else {
            tableView.isHidden = true
            notFoundLbl.isHidden = false
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadCourses()
    }
    
    func setupUI() {
        titleLbl.text = "Courses"
        titleLbl.textColor = UIColor.white
        cancelBtn.setTitle("Back", for: .normal)
        cancelBtn.setTitleColor(UIColor.white, for: .normal)
        notFoundLbl.text = "You haven't enrolled any courses"
        notFoundLbl.textColor = UIColor.white
        detailTitleLbl.text = "Enrolled"
        detailTitleLbl.textColor = UIColor.appDefaultColor
    }
    

}

// MARK: - TableView Delegate
extension EnrolledCoursesVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppTableCell.enrolledCoursesCell.identifier, for: indexPath) as? EnrolledCoursesCell else {
            return UITableViewCell()
        }
        
        let enrolledCourses: CourseDetail
        
            enrolledCourses = courses[indexPath.row]
        
        cell.config(enrolledCourses: enrolledCourses)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let courseDetail = courses[indexPath.row]
        goToCourseDetailScreen(courseId: courseDetail._id)
    }
}
