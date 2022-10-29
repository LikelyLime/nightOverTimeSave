//
//  SaveOffDateController.swift
//  nightOverTimeSave
//
//  Created by 백시훈 on 2022/10/10.
//

import UIKit

enum OffDateEditorMode{
    case new
    case edit(IndexPath, OverTime)
}

enum saveMode{
    case now
    case select
}

protocol saveOffDateViewDelegate: AnyObject{
    func didSelectRegister(overTime: OverTime)
}

class SaveOffDateController: UIViewController{
    
    
    @IBOutlet weak var TimeTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private let datePicker = UIDatePicker()
    private var selectDate: Date?
    private let timePicker = UIDatePicker()
    private var selectTime: Date?
    weak var delegate: saveOffDateViewDelegate?
    
    @IBOutlet weak var saveNowTime: UIButton!
    var mode: OffDateEditorMode = .new
    var saveMode: saveMode = .select
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTextField()
        self.configureDatePicker()
        self.configureTimePicker()
        self.configureEditMode()
        self.saveButton.isEnabled = false
        self.configureInputTextField()
    }
    
    private func configureEditMode(){
        switch self.mode{
        case let .edit(_, overTime):
            self.dateTextField.text = dateToString(date: overTime.date)
            self.TimeTextField.text = timeToString(date: overTime.time)
            self.selectDate = overTime.date
            self.selectTime = overTime.time
            self.saveButton.title = "수정"
            self.saveNowTime.isHidden = true
        default :
        break
        }
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
    /**
     TextField 스타일 지정
     */
    private func configureTextField(){
        let border = UIColor.blue.cgColor
        self.TimeTextField.layer.borderColor = border
        self.TimeTextField.layer.borderWidth = 1.0
        self.TimeTextField.layer.cornerRadius = 5.0
        self.dateTextField.layer.borderColor = border
        self.dateTextField.layer.borderWidth = 1.0
        self.dateTextField.layer.cornerRadius = 5.0
    }
    /**
     Date의 DatePicker 설정
     */
    private func configureDatePicker(){
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        self.dateTextField.inputView = self.datePicker
    }
    
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        self.selectDate = datePicker.date
        self.dateTextField.text = formatter.string(from: datePicker.date)
        configureInputTextField()
    }
    
    /**
     Time의 DatePicker 설정
     */
    private func configureTimePicker(){
        self.timePicker.datePickerMode = .time
        self.timePicker.preferredDatePickerStyle = .wheels
        self.timePicker.addTarget(self, action: #selector(datePickerTimeValueDidChange(_:)), for: .valueChanged)
        self.TimeTextField.inputView = self.timePicker
    }
    
    @objc private func datePickerTimeValueDidChange(_ timePicker: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "HH시 mm분"
        formatter.locale = Locale(identifier: "ko_KR")
        self.selectTime = timePicker.date
        self.TimeTextField.text = formatter.string(from: timePicker.date)
        configureInputTextField()
    }
    
    private func configureInputTextField(){
        self.saveButton.isEnabled = !(dateTextField.text?.isEmpty ?? true) && !(TimeTextField.text?.isEmpty ?? true)
    }
    /**
     저장버튼을 눌렀을때 나타나는 이벤트 메서드
     */
    @IBAction func saveBarButton(_ sender: UIBarButtonItem) {
        self.saveTime()
    }
    /**
     현재시간을 저장하는 버튼을 눌렀을때 사용되는 이벤트 메서드
     */
    @IBAction func saveNowTimeButtonTapped(_ sender: Any) {
        self.selectDate = Date.now
        self.selectTime = Date.now
        self.saveMode = .now
        self.saveTime()
    }
    
    private func saveTime(){
        
        guard let date = self.selectDate else { return }
        
        guard let time = self.selectTime else { return }
        let overTime = OverTime(date: date, time: time)
        
        switch self.mode{
        case .new:
            self.delegate?.didSelectRegister(overTime: overTime)
        case let .edit(indexPath, _):
            NotificationCenter.default.post(
                name: NSNotification.Name("editOverTime"),//NSNotification의 아이디
                object: overTime,//전달 할 객체
                userInfo: ["indexPath.row": indexPath.row]
            )
        }
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
    /**
     빈공간 터치시 데이터피커 닫기
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        configureInputTextField()
    }
}
