//
//  WeatherListViewController.swift
//  WeatherLook_iOS
//
//  Created by 전소영 on 2022/03/07.
//

import UIKit

import RxSwift

class WeatherListViewController: UIViewController {
    weak var coordinator: WeatherListCoordinator?
    
    private let weatherReactor = WeatherReactor()
    private let disposeBag = DisposeBag()
    private var weatherDatas: [WeatherData] = []
    private var locationList: [Location] = []
    var completion: ((Int) -> Void)?
    
    private let weatherListTableView = UITableView().then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .black
    }
    
    private let footerView = UIView().then {
        $0.backgroundColor = .black
        $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 95)
    }
    
    private let searchButton = UIButton().then {
        $0.setImage(UIImage(named: "search"), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        registerNotification()
        bind(reactor: weatherReactor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchWeatherData()
    }
    
    private func fetchWeatherData() {
        if let locations = UserDefaultsManager.locationList {
            locationList = locations
        }
        
        for i in 0..<locationList.count {
            weatherReactor.action.onNext(.viewWillAppear(locationList[i]))
        }
    }
    
    private func setupView() {
        view.addSubview(weatherListTableView)
        footerView.addSubview(searchButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        weatherListTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        searchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(30)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(28)
        }
    }
    
    private func setupTableView() {
        weatherListTableView.dataSource = self
        weatherListTableView.delegate = self
        weatherListTableView.registerCell(cellType: WeatherListTableViewCell.self)
        weatherListTableView.tableFooterView = footerView
        weatherListTableView.contentInsetAdjustmentBehavior = .never
    }
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(addLocation), name: .addLocation, object: nil)
    }
    
    private func bind(reactor: WeatherReactor) {
        reactor.state
            .subscribe(onNext: { [weak self] state in
                if let weatherData = state.weatherData {
                    self?.weatherDatas.append(weatherData)
                    self?.weatherListTableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushSearchViewController()
            })
            .disposed(by: disposeBag)
    }
    
    @objc func addLocation(notification: NSNotification) {
        guard let location = notification.object as? Location else {
            return
        }
        
        var addFlag = true
        for i in 0..<locationList.count {
            if locationList[i].name == location.name {
                addFlag = false
            }
        }
        
        if addFlag {
            locationList.append(location)
            UserDefaultsManager.locationList = locationList
            weatherReactor.action.onNext(.viewWillAppear(location))
        }
    }
}

// MARK: UITableViewDataSource
extension WeatherListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let weatherListTableViewCell = tableView.dequeueReusableCell(cellType: WeatherListTableViewCell.self, indexPath: indexPath) else {
            return UITableViewCell()
        }
        weatherListTableViewCell.setupUI(location:locationList[indexPath.row] ,data: weatherDatas[indexPath.row])
        return weatherListTableViewCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 125
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var editFlag = true
        if indexPath.row == 0 {
            editFlag = false
        }
        
        return editFlag
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            locationList.remove(at: indexPath.row)
            UserDefaultsManager.locationList = locationList
            
            weatherDatas.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: UITableViewDelegate
extension WeatherListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        completion?(indexPath.row)
        coordinator?.popWeatherListViewController()
    }
}
