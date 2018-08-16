//
//  CardViewController.swift
//  OCKSample
//
//  Created by Johan Sellström on 2018-08-15.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import CareKit
class CardViewController: UIViewController {

    let headerView:OCKCareCardView
    let tableView:OCKCareContentsView

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(headerView)
        view.addSubview(tableView)
        self.navigationController?.navigationBar.isHidden = true
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200.0),
            /*headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            headerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -400.0),*/
            ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 340.0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            // headerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -400.0),
            ])
        // Do any additional setup after loading the view.
    }

    init(headerView: OCKCareCardView, tableView: OCKCareContentsView) {
        //super.init()
        self.headerView = headerView
        self.tableView = tableView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


}
