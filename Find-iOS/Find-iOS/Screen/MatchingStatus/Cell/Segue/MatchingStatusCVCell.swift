//
//  MatchingStatusCVCell.swift
//  Find-iOS
//
//  Created by 이원석 on 2021/05/19.
//

import UIKit

// MARK: - 받은호감, 보낸호감 셀 분기처리 enum
enum feelingCell {
    case received, send
}

// MARK: - 매칭 현황 탭 Horizontal 컬렉션 뷰
class MatchingStatusCVCell: UICollectionViewCell {
    static let identifier = "MatchingStatusCVCell"
    var idxPaths = [IndexPath]()
    var isExpandable = false // 섹션 확장된 상태인지 확인하기 위한 Bool값
    var connectedData, receivedData, sendData: [Connected]? // 연결된 상대, 받은 호감, 보낸 호감 데이터
    var connectedDataExp: [ExpandableSection] = [] // 섹션 확장을 위한 구조체
    
    @IBOutlet weak var innerTV: UITableView! {
        didSet {
            innerTV.delegate = self
            innerTV.dataSource = self
            innerTV.backgroundColor = .subGray6
            innerTV.register(ConnectedTVCell.nib(), forCellReuseIdentifier: ConnectedTVCell.identifier)
            innerTV.register(FeelingTVCell.nib(), forCellReuseIdentifier: FeelingTVCell.identifier)
            innerTV.register(MatchingHeader.nib(), forHeaderFooterViewReuseIdentifier: "MatchingHeader")
            innerTV.register(MatchingFooter.nib(), forHeaderFooterViewReuseIdentifier: "MatchingFooter")
            innerTV.separatorStyle = .none
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setNoti()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    static func nib() -> UINib {
        return UINib(nibName: "MatchingStatusCVCell", bundle: nil)
    }
    
    // 더보기 안눌렀을 때에는 보여지는 cell 최대 3개
    func setExpandable() {
        if let cntdData = connectedData {
            for i in 0..<cntdData.count {
                connectedDataExp.append(ExpandableSection(isExpanded: false, data: cntdData[i]))
            }
            for i in 0..<(cntdData.count % 4) {
                connectedDataExp[i].isExpanded = true
            }
        }
    }
}

// MARK: - ShowMore Footer Btn
extension MatchingStatusCVCell: ShowMoreFooter {
    
    // Do it
    func showMoreTapped(iam: WhereShowMore) {
        if connectedDataExp.count > 3 {
            connectedDataExp = doExpand(str: connectedDataExp, section: 0)
            if isExpandable {
                doInsert(tableView: innerTV, indexPaths: idxPaths, section: nil, str: nil)
            } else {
                doDelete(tableView: innerTV, indexPaths: idxPaths, section: 0,str: nil)
            }
        }
    }
    
    // Expand? Collapse?
    func doExpand(str: [ExpandableSection], section: Int) -> [ExpandableSection] {
        // Ready to Expand
        var edit_str = str
        if str[3].isExpanded ?? false {
            isExpandable = false
            for row in 3..<str.count {
                let indexPath = IndexPath(row: row, section: section)
                idxPaths.append(indexPath)
                edit_str[row].isExpanded = false
            }
        } else {
            // Ready to Collapse
            isExpandable = true
            for row in 3..<str.count {
                let indexPath = IndexPath(row: row, section: section)
                idxPaths.append(indexPath)
                edit_str[row].isExpanded = true
            }
        }
        return edit_str
    }
    
    // Expandable
    func doInsert(tableView: UITableView, indexPaths: [IndexPath], section: Int?, str: [ExpandableSection]?) {
        tableView.insertRows(at: indexPaths, with: .fade)
        tableView.layoutIfNeeded()
    }
    
    // Collapsable
    func doDelete(tableView: UITableView, indexPaths: [IndexPath], section: Int?, str: [ExpandableSection]?) {
        tableView.deleteRows(at: indexPaths, with: .fade)
        tableView.layoutIfNeeded()
        tableView.scrollToRow(at: IndexPath(row: 0, section: section ?? 0), at: .middle, animated: true)
    }
    
    func setNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(changingData), name: NSNotification.Name("needToReloadFeeling"), object: nil)
    }
    
    // 데이터 변화에 대응하기 위한 Noti
    @objc func changingData(noti: Notification) {
        if let sec = noti.object as? [Int] {
            NotificationCenter.default.post(name: NSNotification.Name("updateMatchingData"), object: nil)
            innerTV.reloadSections(IndexSet(sec[0]...sec[1]), with: .fade)
        }
    }
}

// MARK: - Protocols
extension MatchingStatusCVCell: UITableViewDelegate, UITableViewDataSource {
    // 섹션 갯수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // 섹션 별 셀 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 데이터가 0개일 때 분기처리 필요
        if (section == 0) {
            if !connectedDataExp.isEmpty {
                print(connectedDataExp.filter{$0.isExpanded ?? false}.count)
                return connectedDataExp.filter{$0.isExpanded ?? false}.count
            } else {
                return 1
            }
        } else if (section == 1) || (section == 2) {
            return 1
        }
        return 0
    }
    
    // 섹션 별 셀 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            if !connectedDataExp.isEmpty {
                guard let cntdCell = tableView.dequeueReusableCell(withIdentifier: "ConnectedTVCell", for: indexPath) as? ConnectedTVCell else { return UITableViewCell() }
                cntdCell.selectionStyle = .none
                cntdCell.setCell(cntdDatas: connectedDataExp[indexPath.row])
                return cntdCell
            } else {
                // 데이터가 0개일 때 분기처리 필요
                return UITableViewCell()
            }
        } else {
            guard let feelCell = tableView.dequeueReusableCell(withIdentifier: "FeelingTVCell", for: indexPath) as? FeelingTVCell else { return UITableViewCell() }
            feelCell.selectionStyle = .none
            if (indexPath.section == 1) {
                feelCell.kindOfFeelingLabel.text = "받은호감"
                feelCell.cellCategory = .received
                feelCell.receivedData = receivedData
            } else {
                feelCell.kindOfFeelingLabel.text = "보낸호감"
                feelCell.cellCategory = .send
                feelCell.sendData = sendData
            }
            return feelCell
        }
    }
    
    // 섹션 별 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 144
        } else {
            return 333
        }
    }
    
    // Header 뷰 지정
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MatchingHeader") as? MatchingHeader else { return UIView() }
            header.headerLabel.text = "연결된 상대"
            return header
        } else {
            return nil
        }
    }
    
    // Header 높이 지정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 ) {
            return 43
        } else {
            return 0
        }
    }
    
    // Footer 뷰 지정
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (section == 0) {
            if !connectedDataExp.isEmpty {
                guard let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MatchingFooter") as? MatchingFooter else { return UIView() }
                footer.whereSM = .feelings
                footer.delegate = self
                return footer
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    // Footer 높이 지정
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 60
        } else {
            return 0
        }
    }
}
