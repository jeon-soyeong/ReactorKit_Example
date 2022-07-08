//
//  WeatherReactor.swift
//  WeatherLook_iOS
//
//  Created by 전소영 on 2022/02/16.
//

import Foundation

import RxSwift
import ReactorKit

class WeatherReactor: Reactor {
    enum Action {
        case viewWillAppear(Location)
    }
    
    enum Mutation {
        case requestWeatherData(WeatherData)
    }
    
    struct State {
        var weatherData: WeatherData?
    }
    
    let initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear(let location):
            let weatherData = APIService.shared.request(WeatherAPI.getWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                .asObservable()
                .map { weather -> Mutation in
                    return .requestWeatherData(weather)
                }
            return weatherData
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .requestWeatherData(let weatherData):
            state.weatherData = weatherData
            return state
        }
    }
}
