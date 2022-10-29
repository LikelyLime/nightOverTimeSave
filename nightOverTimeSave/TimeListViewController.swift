//
//  TimeListViewController.swift
//  nightOverTimeSave
//
//  Created by 백시훈 on 2022/09/19.
//

import UIKit

class TimeListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var overTimeList = [OverTime](){
        didSet{
            self.saveDictionOverTimeList()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadOverTimeList()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editNotification(_:)),
            name: NSNotification.Name("editOverTime"),
            object: nil
        )
    }
    @objc func editNotification(_ notification: Notification ){
        guard let overTime = notification.object as? OverTime else { return }
        guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
        self.overTimeList[row] = overTime
        self.overTimeList = self.overTimeList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
    
    /**
     세그웨이로 전달된 값을 받는 메서드prepare
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let saveOffDateController = segue.destination as? SaveOffDateController{
            saveOffDateController.delegate = self
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
    
    private func configureCollectionView(){
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }
    
    
    private func saveDictionOverTimeList(){
        let data = self.overTimeList.map {
            [
                "date": $0.date,
                "time": $0.time
            ]
        }
        
        let userDefault = UserDefaults.standard
        userDefault.set(data, forKey: "overTimeList")
    }
    
    
    private func loadOverTimeList(){
        let userDefault = UserDefaults.standard
        guard let data = userDefault.object(forKey: "overTimeList") as? [[String: Any]] else { return }
        self.overTimeList = data.compactMap{
            guard let date = $0["date"] as? Date else { return nil }
            guard let time = $0["time"] as? Date else { return nil }
            return OverTime(date: date, time: time)
        }
        self.overTimeList = self.overTimeList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    
}

extension TimeListViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.overTimeList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeListCell", for: indexPath) as? TimeListCell else { return UICollectionViewCell() }
        let overTime = self.overTimeList[indexPath.row]
        cell.dateLabel.text = self.dateToString(date: overTime.date)
        cell.timeLabel.text = self.timeToString(date: overTime.time)
        return cell
    }
}

extension TimeListViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 20, height: 90)
    }
}
extension TimeListViewController: saveOffDateViewDelegate{
    func didSelectRegister(overTime: OverTime) {
        overTimeList.append(overTime)
        self.overTimeList = self.overTimeList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData() 
    }
}

/**
 상세화면으로 이동하는 메서드
 */
extension TimeListViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "UpdateOffDateViewController") as? UpdateOffDateViewController else { return }
        let overTime = self.overTimeList[indexPath.row] //선택한 셀이 무엇인지 전달
        viewController.overTime = overTime
        viewController.indexPath = indexPath
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}


/**
 삭제를 위한 메서드
 */
extension TimeListViewController: updateIffDateViewControllerDelegate{
    func didSelectDelegate(indexPath: IndexPath) {
        self.overTimeList.remove(at: indexPath.row)
        self.collectionView.deleteItems(at: [indexPath])
    }
}
