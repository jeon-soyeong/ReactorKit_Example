//
//  WeatherViewController.swift
//  WeatherLook_iOS
//
//  Created by 전소영 on 2022/01/27.
//

import UIKit

import RxSwift
import SnapKit
import Then

class WeatherViewController: UIViewController {
    weak var coordinator: WeatherCoordinator?
    
    private let weatherReactor = WeatherReactor()
    private let disposeBag = DisposeBag()
    private var weatherData: WeatherData?
    var location: Location?
    var pageCase = ""
    
    let addButton = UIButton().then {
        $0.setTitle("추가", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.setFont(type: .semiBold, size: 20)
    }
    
    let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.setFont(type: .semiBold, size: 20)
    }
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .mainBlue
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let currentWeatherLineView = UIView().then {
        $0.backgroundColor = .mainLineGray
    }
    
    private let clothingGuideLineView = UIView().then {
        $0.backgroundColor = .mainLineGray
    }
    
    private let dailyWeatherLineView = UIView().then {
        $0.backgroundColor = .mainLineGray
    }
    
    private let currentWeatherView = CurrentWeatherView()
    
    private let clothingGuideCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = .zero
    }
    
    private lazy var clothingGuideCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: clothingGuideCollectionViewFlowLayout).then {
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
    }
    
    private let dailyWeatherCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = .zero
    }
    
    private lazy var dailyWeatherCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: dailyWeatherCollectionViewFlowLayout).then {
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
    }
    
    private let weeklyWeatherCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = .zero
    }
    
    private lazy var weeklyWeatherCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: weeklyWeatherCollectionViewFlowLayout).then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionView()
        bind(reactor: weatherReactor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if pageCase != "search" {
            cancelButton.isHidden = true
            addButton.isHidden = true
        }
        
        guard let location = location else {
            return
        }
        weatherReactor.action.onNext(.viewWillAppear(location))
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        setupSubViews()
        setupConstraints()
    }
    
    private func setupSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(addButton)
        contentView.addSubview(cancelButton)
        contentView.addSubview(currentWeatherView)
        contentView.addSubview(currentWeatherLineView)
        contentView.addSubview(clothingGuideCollectionView)
        contentView.addSubview(clothingGuideLineView)
        contentView.addSubview(dailyWeatherCollectionView)
        contentView.addSubview(dailyWeatherLineView)
        contentView.addSubview(weeklyWeatherCollectionView)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.centerX.top.bottom.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(12)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(12)
            $0.leading.equalToSuperview().inset(24)
        }
        
        currentWeatherView.snp.makeConstraints {
            $0.top.equalTo(addButton.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        currentWeatherLineView.snp.makeConstraints {
            $0.centerX.width.equalToSuperview()
            $0.top.equalTo(currentWeatherView.snp.bottom)
            $0.height.equalTo(0.5)
        }
        
        clothingGuideCollectionView.snp.makeConstraints {
            $0.top.equalTo(currentWeatherView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        clothingGuideLineView.snp.makeConstraints {
            $0.centerX.width.equalToSuperview()
            $0.top.equalTo(clothingGuideCollectionView.snp.bottom)
            $0.height.equalTo(0.5)
        }
        
        dailyWeatherCollectionView.snp.makeConstraints {
            $0.top.equalTo(clothingGuideCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        dailyWeatherLineView.snp.makeConstraints {
            $0.centerX.width.equalToSuperview()
            $0.top.equalTo(dailyWeatherCollectionView.snp.bottom)
            $0.height.equalTo(0.5)
        }
        
        weeklyWeatherCollectionView.snp.makeConstraints {
            $0.top.equalTo(dailyWeatherLineView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
            $0.bottom.equalToSuperview().inset(60)
        }
    }
    
    private func setupCollectionView() {
        clothingGuideCollectionView.dataSource = self
        clothingGuideCollectionView.delegate = self
        clothingGuideCollectionView.registerCell(cellType: ClothingGuideCollectionViewCell.self)
        
        dailyWeatherCollectionView.dataSource = self
        dailyWeatherCollectionView.delegate = self
        dailyWeatherCollectionView.registerCell(cellType: DailyWeatherCollectionViewCell.self)
        
        weeklyWeatherCollectionView.dataSource = self
        weeklyWeatherCollectionView.delegate = self
        weeklyWeatherCollectionView.registerCell(cellType: WeeklyWeatherCollectionViewCell.self)
    }
    
    private func bind(reactor: WeatherReactor) {
        guard let location = location else {
            return
        }
        
        reactor.state
        .subscribe(onNext: { [weak self] state in
            self?.weatherData = state.weatherData
            if let weatherData = self?.weatherData {
                self?.currentWeatherView.setupView(location: location, data: weatherData)
                self?.clothingGuideCollectionView.reloadData()
                self?.dailyWeatherCollectionView.reloadData()
                self?.weeklyWeatherCollectionView.reloadData()
            }
        })
        .disposed(by: disposeBag)
        
        addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.popToWeatherListController()
                NotificationCenter.default.post(name: .addLocation, object: self?.location)
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.popWeatherViewController()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: UICollectionViewDataSource
extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var itemCount: Int = 0
        
        guard let weatherData = self.weatherData else {
            return 0
        }
        
        switch collectionView {
        case clothingGuideCollectionView:
            itemCount = 3
        case dailyWeatherCollectionView:
            itemCount = weatherData.hourly.count
        case weeklyWeatherCollectionView:
            itemCount = weatherData.daily.count
        default:
            itemCount = 7
        }
        
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let weatherData = self.weatherData else {
            return UICollectionViewCell()
        }
        
        switch collectionView {
        case clothingGuideCollectionView:
            guard let clothingGuideCollectionViewCell = collectionView.dequeueReusableCell(cellType: ClothingGuideCollectionViewCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            clothingGuideCollectionViewCell.setupUI(index: indexPath.item, data: weatherData)
            return clothingGuideCollectionViewCell
        case dailyWeatherCollectionView:
            guard let dailyWeatherCollectionViewCell = collectionView.dequeueReusableCell(cellType: DailyWeatherCollectionViewCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            dailyWeatherCollectionViewCell.setupUI(index: indexPath.item, data: weatherData)
            return dailyWeatherCollectionViewCell
        case weeklyWeatherCollectionView:
            guard let weeklyWeatherCollectionViewCell = collectionView.dequeueReusableCell(cellType: WeeklyWeatherCollectionViewCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            weeklyWeatherCollectionViewCell.setupUI(index: indexPath.item, data: weatherData)
            return weeklyWeatherCollectionViewCell
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension WeatherViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize = CGSize()
        guard let weatherData = self.weatherData else {
            return cellSize
        }
        
        switch collectionView {
        case clothingGuideCollectionView:
            cellSize = CGSize(width: Int(collectionView.frame.width) / 3, height: ClothingGuideCollectionViewCell.cellHeight)
        case dailyWeatherCollectionView:
            cellSize = CGSize(width: DailyWeatherCollectionViewCell.cellWidth, height: DailyWeatherCollectionViewCell.cellHeight)
        case weeklyWeatherCollectionView:
            cellSize = CGSize(width: Int(collectionView.frame.width), height: WeeklyWeatherCollectionViewCell.cellHeight / weatherData.daily.count)
        default:
            return cellSize
        }
        
        return cellSize
    }
}
