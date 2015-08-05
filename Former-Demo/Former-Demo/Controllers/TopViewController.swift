//
//  TopViewController.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 8/5/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

final class TopViewContoller: FormerViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configure()
    }
    
    private func configure() {
        
        self.title = "Former"
        
        // Create RowFormers
        
        let firstComponets: [(String, (NSIndexPath -> Void)?)] = [
            ("Edit Profile", { [weak self] _ in
                self?.former.deselectSelectedCell(true)
                self?.navigationController?.pushViewController(DemoViewController(), animated: true)})
        ]
        
        let secondComponents: [(String, (NSIndexPath -> Void)?)] = [
            ("Default UI", { [weak self] _ in
                self?.former.deselectSelectedCell(true)
                self?.navigationController?.pushViewController(DemoViewController(), animated: true)}),
            ("Examples", { [weak self] _ in
                self?.former.deselectSelectedCell(true)
                self?.navigationController?.pushViewController(DemoViewController(), animated: true)})
        ]
        
        let thirdComponents: [(String, (NSIndexPath -> Void)?)] = [
            ("Custom UI", { [weak self] _ in
                self?.former.deselectSelectedCell(true)
                self?.navigationController?.pushViewController(DemoViewController(), animated: true)})
        ]
        
        let createMenu: ((String, (NSIndexPath -> Void)?) -> TextRowFormer) = {
            let rowFormer = TextRowFormer(cellType: FormerTextCell.self, registerType: .Class, selectedHandler: $0.1)
            rowFormer.text = $0.0
            rowFormer.textColor = .formerColor()
            rowFormer.font = UIFont.boldSystemFontOfSize(16.0)
            rowFormer.accessoryType = .DisclosureIndicator
            return rowFormer
        }
        
        // Create Headers and Footers
        
        let createHeader: (String -> TextViewFormer) = {
            let header = TextViewFormer(viewType: FormerTextHeaderView.self, registerType: .Class, text: $0)
            header.textColor = .grayColor()
            header.font = UIFont.systemFontOfSize(14.0)
            header.viewHeight = 40.0
            return header
        }
        
        let createFooter: (String -> TextViewFormer) = {
            let footer = TextViewFormer(viewType: FormerTextFooterView.self, registerType: .Class, text: $0)
            footer.textColor = .grayColor()
            footer.font = UIFont.systemFontOfSize(14.0)
            footer.viewHeight = 100.0
            return footer
        }
        
        // Create SectionFormers
        
        let firstSection = SectionFormer()
            .addRowFormers(firstComponets.map(createMenu))
            .setHeaderViewFormer(createHeader("Real Example"))
        
        let secondSection = SectionFormer()
            .addRowFormers(secondComponents.map(createMenu))
            .setHeaderViewFormer(createHeader("Examples with Default UI"))
        
        let thirdSection = SectionFormer()
            .addRowFormers(thirdComponents.map(createMenu))
            .setHeaderViewFormer(createHeader("Examples with Custom UI"))
            .setFooterViewFormer(createFooter("Former is a fully customizable Swift\"2.0\" library for easy creating UITableView based form.\n\nMIT License (MIT)"))
        
        self.former.addSectionFormers([firstSection, secondSection, thirdSection])
    }
}