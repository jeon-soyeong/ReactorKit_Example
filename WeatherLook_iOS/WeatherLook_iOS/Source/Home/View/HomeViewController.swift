//
//  HomeViewController.swift
//  WeatherLook_iOS
//
//  Created by 전소영 on 2022/01/27.
//

import UIKit

import SnapKit
import Then

class HomeViewController: UIViewController {
    weak var coordinator: HomeCoordinator?
    private let homeViewModel = HomeViewModel()
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .mainBlue
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let bottomView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let listButton = UIButton().then {
        $0.setImage(UIImage(named: "list"), for: .normal)
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
        $0.isScrollEnabled = false
    }
    
    private let weeklyWeatherCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = .zero
    }
    
    private lazy var weeklyWeatherCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: weeklyWeatherCollectionViewFlowLayout).then {
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionViewUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.centerX.width.bottom.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
        
        bottomView.addSubview(listButton)
        listButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(30)
            $0.width.height.equalTo(25)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(currentWeatherView)
        currentWeatherView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        contentView.addSubview(currentWeatherLineView)
        currentWeatherLineView.snp.makeConstraints {
            $0.centerX.width.equalToSuperview()
            $0.top.equalTo(currentWeatherView.snp.bottom)
            $0.height.equalTo(0.5)
        }
        
        contentView.addSubview(clothingGuideCollectionView)
        clothingGuideCollectionView.snp.makeConstraints {
            $0.top.equalTo(currentWeatherView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        contentView.addSubview(clothingGuideLineView)
        clothingGuideLineView.snp.makeConstraints {
            $0.centerX.width.equalToSuperview()
            $0.top.equalTo(clothingGuideCollectionView.snp.bottom)
            $0.height.equalTo(0.5)
        }
        
        contentView.addSubview(dailyWeatherCollectionView)
        dailyWeatherCollectionView.snp.makeConstraints {
            $0.top.equalTo(clothingGuideCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        contentView.addSubview(dailyWeatherLineView)
        dailyWeatherLineView.snp.makeConstraints {
            $0.centerX.width.equalToSuperview()
            $0.top.equalTo(dailyWeatherCollectionView.snp.bottom)
            $0.height.equalTo(0.5)
        }
        
        contentView.addSubview(weeklyWeatherCollectionView)
        weeklyWeatherCollectionView.snp.makeConstraints {
            $0.top.equalTo(dailyWeatherLineView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
            $0.bottom.equalToSuperview().inset(50)
        }
    }
    
    private func setupCollectionViewUI() {
        clothingGuideCollectionView.dataSource = self
        clothingGuideCollectionView.delegate = self
        clothingGuideCollectionView.registerCell(cellType: ClothingGuideCollectionViewCell.self)
        
        dailyWeatherCollectionView.dataSource = self
        dailyWeatherCollectionView.delegate = self
//        dailyWeatherCollectionView.registerCell(cellType: .self)
        
        weeklyWeatherCollectionView.dataSource = self
        weeklyWeatherCollectionView.delegate = self
//        weeklyWeatherCollectionView.registerCell(cellType: .self)
    }
    
    func bindViewModel() {
        //rx.tap
    }
    
    func observeViewModel() {
        // view update
    }
}

// MARK: UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case clothingGuideCollectionView:
            return 3
        default:
            return 7
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case clothingGuideCollectionView:
            guard let clothingCollectionViewCell = collectionView.dequeueReusableCell(cellType: ClothingGuideCollectionViewCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            //            TODO: 실 ViewModel로 변경
            //            clothingCollectionViewCell.updateUI(index: indexPath.item, data: homeViewModel.weatherList[indexPath.item])
            clothingCollectionViewCell.updateUI(index: indexPath.item)
            
            return clothingCollectionViewCell
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case clothingGuideCollectionView:
            return CGSize(width: Int(collectionView.frame.width) / 3, height: ClothingGuideCollectionViewCell.cellHeight)
        default:
            return CGSize()
        }
    }
}
