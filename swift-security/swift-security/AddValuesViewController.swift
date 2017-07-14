//
//  AddValuesViewController.swift
//  swift-security
//
//  Created by Harika Annam on 7/14/17.
//  Copyright © 2017 Innominds Mobility. All rights reserved.
//

import UIKit
import InnoSecurity

class AddValuesViewController: UIViewController {
    var keyChainWrapperObj = InnoKeyChainWrapper()
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var fromEdit = Bool()
    var userName = String()
    var password = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        if fromEdit {
            self.nameTextField.text = self.userName
            self.passwordTextField.text = keyChainWrapperObj.loadPassword(accountname: self.userName as NSString)! as String
            self.password = self.passwordTextField.text!
        }

        // Do any additional setup after loading the view.
    }
    @IBAction func saveBtnAction(_ sender: Any) {
        guard let userName = nameTextField.text else { return }
        guard let userPwd = passwordTextField.text else { return }
        if fromEdit {
            if self.userName == self.nameTextField.text {
                self.keyChainWrapperObj.updatePassword(accountname: self.nameTextField.text! as NSString, password: self.passwordTextField.text! as NSString)
            }
            else {
                self.keyChainWrapperObj.renameAccount(self.nameTextField.text!, self.userName)
//                self.keyChainWrapperObj.savePassword(accountname: self.nameTextField.text! as NSString, password: self.passwordTextField.text! as NSString)
                 self.keyChainWrapperObj.updatePassword(accountname: self.nameTextField.text! as NSString, password: self.passwordTextField.text! as NSString)
            }
        }
        else {
            keyChainWrapperObj.savePassword(accountname: userName as NSString, password: userPwd as NSString)
        }
        self.navigationController?.popViewController(animated: false)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
