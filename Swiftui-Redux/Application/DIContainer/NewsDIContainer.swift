//
//  NewsDIContainer.swift
//  swiftui-mvvm
//
//  Created by MD AL MAMUN (LCL) on 2019-12-26.
//  Copyright © 2019 MD AL MAMUN. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - UseCase protocol
protocol NewsDIUseCaseFactory {
    func makeFetchTopHeadlineQueriesUseCase() -> FetchTopHeadlineQueriesUseCase
}

// MARK: - Repositories protocol
protocol NewsDIRepositoryFactory {
    func makeTopHeadlineRepositories() -> TopHeadlineRepository
}

typealias NewsDIContainerType = NewsDIUseCaseFactory & NewsDIRepositoryFactory


final class NewsDIContainer: NewsDIContainerType {
    
    let dataService: DataService
    let appConfig: ApplicationConfigurationType
    
    init(dataService: DataService, appConfig: ApplicationConfigurationType) {
        self.dataService = dataService
        self.appConfig   = appConfig
    }
    
    // MARK: - UseCases
    func makeFetchTopHeadlineQueriesUseCase() -> FetchTopHeadlineQueriesUseCase {
        return DefaultFetchTopHeadlineQueriesUseCase(headlineRepo: self.makeTopHeadlineRepositories())
    }
    
    // MARK: - Repositories
    func makeTopHeadlineRepositories() -> TopHeadlineRepository {
        return DefaultTopHeadlineRepository(url: appConfig.envConfigurator.baseUrl,
                                            dataService: dataService,
                                            urlSession: appConfig.urlSession)
    }
}

