//
//  WebServices.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 09/04/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation

enum WebService {
    case getConfiguration
    case postDevice(_: DeviceInfo?)
    case patchDevice(settings: PushNotificationSettings)
    case texts(language: String)
    case postPushStatistic(_: Stats.PushNotificationEvent)
    case postStats(_: Stats)
    case dialog
    case getRatingsConfiguration(campaignID: Int? = nil)
    case postRatings
    case getFeedbackConfiguration
    case postFeedback
    case version
}

extension WebService: Endpoint {

    var path: String {
        switch self {
        case .getConfiguration:
            return "sdk/configuration"
        case .postDevice, .patchDevice:
            return "sdk/devices"
        case .texts:
            return "sdk/texts"
        case .postPushStatistic,
             .postStats:
            return "sdk/statistics"
        case .dialog:
            return "sdk/dialog"
        case .getRatingsConfiguration, .postRatings:
            return "sdk/rating"
        case .getFeedbackConfiguration, .postFeedback:
            return "sdk/feedback"
        case .version:
            return "sdk/version"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getConfiguration,
             .texts:
            return .get
        case .postDevice:
            return .post
        case .patchDevice:
            return .patch
        case .postPushStatistic,
             .postStats:
            return .post
        case .dialog:
            return .get
        case .getRatingsConfiguration:
            return .get
        case .postRatings:
            return .post
        case .getFeedbackConfiguration:
            return .get
        case .postFeedback:
            return .post
        case .version:
            return .get
        }
    }

    var parameters: Parameters? {
        switch self {
        case .texts(let language):
            return ["locale": language]
        case .getRatingsConfiguration(let campaignID):
            if let campaignID {
                return ["campaign_id": campaignID]
            } else {
                return nil
            }
        default:
            return nil
        }
    }

    var body: Parameters? {
        switch self {
        case .postDevice(let deviceInfo):
            return deviceInfo?.dictionary
        case .patchDevice(let settings):
            if let dictionnary = settings.dictionary {
                return ["push": dictionnary]
            } else {
                return nil
            }
        case .postPushStatistic(let statistic):
            if let dictionnary = statistic.dictionary {
                return ["pushes": [dictionnary]]
            } else {
                return nil
            }
        case .postStats(let stats):
            return stats.dictionary
        default:
            return nil
        }
    }

}

extension RequestManager {

    @discardableResult
    func request(endpoint: Endpoint) -> DataRequest {
        let request = self.request(endpoint.path,
                                   method: endpoint.httpMethod,
                                   parameters: endpoint.parameters)
        if let body = endpoint.body {
            request.setBody(body)
        }
        if let headers = endpoint.headers {
            request.setHeaders(headers)
        }
        request.secure(withOptions: endpoint.securityOptions)
        if let secureData = endpoint.secureData {
            request.secureData(secureData)
        }
        return request
    }

}
