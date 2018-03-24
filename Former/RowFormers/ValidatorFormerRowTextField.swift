//
//  ValidatorFormerRowTextField.swift
//  CashBaba
//
//  Created by Mamun Ar Rashid on 3/24/18.
//  Copyright © 2018 Recursion Technologies Ltd. All rights reserved.
//

import Foundation
import UIKit

open class ValidatorFormerRowTextField<T: UITableViewCell>
: BaseRowFormer<T>, Formable where T: TextFieldFormableRow {
    
    // MARK: Public
    
    override open var canBecomeEditing: Bool {
        return enabled
    }
    
    open var text: String?
    open var placeholder: String?
    open var attributedPlaceholder: NSAttributedString?
    open var textDisabledColor: UIColor? = .lightGray
    open var titleDisabledColor: UIColor? = .lightGray
    open var titleEditingColor: UIColor?
    open var returnToNextRow = true
    open var maxLength: Int32 = 20
    
    public required init(instantiateType: Former.InstantiateType = .Class, cellSetup: ((T) -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
    }
    
    @discardableResult
    public final func onTextChanged(_ handler: @escaping ((String) -> Void)) -> Self {
        onTextChanged = handler
        return self
    }
    
    open override func cellInitialized(_ cell: T) {
        super.cellInitialized(cell)
        let textField = cell.formTextField()
        textField.delegate = observer
        let events: [(Selector, UIControlEvents)] = [(#selector(ValidatorFormerRowTextField.textChanged(textField:)), .editingChanged),
                                                     (#selector(ValidatorFormerRowTextField.editingDidBegin(textField:)), .editingDidBegin),
                                                     (#selector(ValidatorFormerRowTextField.editingDidEnd(textField:)), .editingDidEnd)]
        events.forEach {
            textField.addTarget(self, action: $0.0, for: $0.1)
        }
    }
    
    open override func update() {
        super.update()
        
        cell.selectionStyle = .none
        let titleLabel = cell.formTitleLabel()
        let textField = cell.formTextField()
        textField.text = text
        _ = placeholder.map { textField.placeholder = $0 }
        _ = attributedPlaceholder.map { textField.attributedPlaceholder = $0 }
        textField.isUserInteractionEnabled = false
        
        if enabled {
            if isEditing {
                if titleColor == nil { titleColor = titleLabel?.textColor ?? .black }
                _ = titleEditingColor.map { titleLabel?.textColor = $0 }
            } else {
                _ = titleColor.map { titleLabel?.textColor = $0 }
                titleColor = nil
            }
            _ = textColor.map { textField.textColor = $0 }
            textColor = nil
        } else {
            if titleColor == nil { titleColor = titleLabel?.textColor ?? .black }
            if textColor == nil { textColor = textField.textColor ?? .black }
            titleLabel?.textColor = titleDisabledColor
            textField.textColor = textDisabledColor
        }
    }
    
    override open func cellSelected(indexPath: IndexPath) {
        let textField = cell.formTextField()
        if !textField.isEditing {
            textField.isUserInteractionEnabled = true
            textField.becomeFirstResponder()
        }
    }
    
    // MARK: Private
    
    private final var onTextChanged: ((String) -> Void)?
    private final var textColor: UIColor?
    private final var titleColor: UIColor?
    
    private lazy var observer: Observer<T> = Observer<T>(textFieldRowFormer: self)
    
    @objc private dynamic func textChanged(textField: UITextField) {
        if enabled {
            let text = textField.text ?? ""
            if text.count > maxLength {
                return
            }
            self.text = text
            onTextChanged?(text)
        }
    }
    
    @objc private dynamic func editingDidBegin(textField: UITextField) {
        let titleLabel = cell.formTitleLabel()
        if titleColor == nil { textColor = textField.textColor ?? .black }
        _ = titleEditingColor.map { titleLabel?.textColor = $0 }
    }
    
    @objc private dynamic func editingDidEnd(textField: UITextField) {
        let titleLabel = cell.formTitleLabel()
        if enabled {
            _ = titleColor.map { titleLabel?.textColor = $0 }
            titleColor = nil
        } else {
            if titleColor == nil { titleColor = titleLabel?.textColor ?? .black }
            _ = titleEditingColor.map { titleLabel?.textColor = $0 }
        }
        cell.formTextField().isUserInteractionEnabled = false
    }
}

private class Observer<T: UITableViewCell>: NSObject, UITextFieldDelegate where T: TextFieldFormableRow {
    
    fileprivate weak var textFieldRowFormer: ValidatorFormerRowTextField<T>?
    
    init(textFieldRowFormer: ValidatorFormerRowTextField<T>) {
        self.textFieldRowFormer = textFieldRowFormer
    }
    
    fileprivate dynamic func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let textFieldRowFormer = textFieldRowFormer else { return false }
        if textFieldRowFormer.returnToNextRow {
            let returnToNextRow = (textFieldRowFormer.former?.canBecomeEditingNext() ?? false) ?
                textFieldRowFormer.former?.becomeEditingNext :
                textFieldRowFormer.former?.endEditing
            _ = returnToNextRow?()
        }
        return !textFieldRowFormer.returnToNextRow
    }
}
