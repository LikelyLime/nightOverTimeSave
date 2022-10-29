//
//  UpdateOffDateViewController.swift
//  nightOverTimeSave
//
//  Created by 백시훈 on 2022/10/10.
//

import UIKit

protocol updateIffDateViewControllerDelegate: AnyObject{
    func didSelectDelegate(indexPath: IndexPath)
}

class UpdateOffDateViewController: UIViewController {

    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var TimeTextField: UITextField!
    
    var overTime: OverTime?
    var indexPath: IndexPath?
    
    weak var delegate: updateIffDateViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
      
    }
    
    private func configureView(){
        guard let overTime = overTime else { return }
        self.dateTextField.text = dateToString(date: overTime.date)
        self.TimeTextField.text = timeToString(date: overTime.time)

    }
    
    /**
     date타입을 String타입으로 변경해주는 Method
     */
    private func dateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko-KR")
        return formatter.string(from: date)
    }
    
    private func timeToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH시 mm분"
        formatter.locale = Locale(identifier: "ko-KR")
        return formatter.string(from: date)
    }

    @IBAction func updateButtonTapped(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "SaveOffDateController")
                as? SaveOffDateController else { return }
        guard let indexPath = self.indexPath else { return }
        guard let overTime = self.overTime else { return }
        viewController.mode = .edit(indexPath, overTime)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editOverTimeNotification(_:)),
            name: NSNotification.Name("editOverTime"),
            object: nil)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @objc func editOverTimeNotification(_ notification: Notification){
        guard let overTime = notification.object as? OverTime else { return }
        //guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
        self.overTime = overTime
        self.configureView()

    }
    
    /**
     삭제 버튼을 클릭했을때 나타나는 메서드
     */
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let indexPath = self.indexPath else { return }
        self.delegate?.didSelectDelegate(indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}
