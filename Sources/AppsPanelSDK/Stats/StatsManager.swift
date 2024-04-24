//
//  StatsManager.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 22/02/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

public class StatsManager {

    public static let shared = StatsManager()

    private let defaults: UserDefaults
    private let queue = DispatchQueue(label: "com.appspanel.sdk.stats-queue")
    private let requestManager = AppsPanel.shared.sdkRequestManager

    private var configuration: RemoteConfiguration.StatConfiguration?

    private var canCollectStats: Bool {
        return configuration?.isEnabled ?? true
    }

    init() {
        var sharedDefaults: UserDefaults?
        if let appGroupIdentifier = AppsPanel.shared.configuration.appGroupIdentifier {
            sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
            if sharedDefaults == nil {
                print("[Stats] Unabled to instanciate the users defaults with the given app group identifier (\(appGroupIdentifier)).")
                print("[Stats] Using standard defaults.")
            }
        }
        self.defaults = sharedDefaults ?? .standard
        
        ApplicationSessionManager.shared.delegate = self
    }

    // MARK: - Configure Module

    func configure(with configuration: RemoteConfiguration.StatConfiguration) {
        self.configuration = configuration

        if !configuration.isEnabled {
            clearAllStatsExceptPushNotifications()
        }
        
        sendStats()
    }
    
    // MARK: - Duration KPI Events
    
    private var currentDurationKpis: [String: Stats.APDurationKpi] = [:]

    public func startDurationKpi(tag: String, context: Stats.Context? = nil) {
        let kpi = Stats.APDurationKpi(tag: tag, context: context, sessionID: ApplicationSessionManager.shared.session.id, start: Date(), end: nil)
        currentDurationKpis[tag] = kpi
    }

    public func endDurationKpi(tag: String) {
        guard let kpi = currentDurationKpis[tag] else { return }
        let updatedKpi = Stats.APDurationKpi(tag: kpi.tag, context: kpi.context, sessionID: kpi.sessionID, start: kpi.start, end: Date())
        saveDurationKpi(updatedKpi)
        currentDurationKpis.removeValue(forKey: tag)
    }

    public func endAllDurationKpis() {
        for kpi in currentDurationKpis.values {
            let updatedKpi = Stats.APDurationKpi(tag: kpi.tag, context: kpi.context, sessionID: kpi.sessionID, start: kpi.start, end: Date())
            saveDurationKpi(updatedKpi)
        }
        currentDurationKpis.removeAll()
    }

    private func saveDurationKpi(_ kpi: Stats.APDurationKpi) {
        var kpis = getSavedDurationKpis()
        kpis.append(kpi)
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            let data = try encoder.encode(kpis)
            UserDefaults.standard.set(data, forKey: Keys.durationKpis)
        } catch {
            print("Error encoding APDurationKpi: \(error)")
        }
    }

    private func getSavedDurationKpis() -> [Stats.APDurationKpi] {
        guard let data = UserDefaults.standard.data(forKey: Keys.durationKpis) else {
            return []
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try decoder.decode([Stats.APDurationKpi].self, from: data)
        } catch {
            print("Error decoding APDurationKpi: \(error)")
            return []
        }
    }
    
    // MARK: - Logs Events

    public func logEvent(_ tag: String, context: Stats.Context? = nil) {
        let session = ApplicationSessionManager.shared.session
        let kpi = Stats.KPI(kind: .event, tag: tag, context: context, sessionID: session.id)
        addKPI(kpi)
    }

    public func logView(_ tag: String, context: Stats.Context? = nil) {
        let session = ApplicationSessionManager.shared.session
        let kpi = Stats.KPI(kind: .view, tag: tag, context: context, sessionID: session.id)
        addKPI(kpi)
    }

    private func addKPI(_ kpi: Stats.KPI) {
        guard canCollectStats else {
            return
        }

        queue.sync {
            do {
                try append(element: kpi, toArrayForKey: Keys.kpis)
            } catch {
                print("[Stats] Unable to save a KPI")
            }
        }
    }

    private func addSession(_ session: Session) {
        guard canCollectStats else {
            return
        }

        queue.sync {
            do {
                try append(element: session, toArrayForKey: Keys.sessions)
            } catch {
                print("[Stats] Unable to save a session")
            }
        }
    }

    // MARK: - Generics method to handle stat storage

    private func storedObject<T: Decodable>(forKey key: String, type: T.Type = T.self) throws -> T? {
        if let storedData = defaults.data(forKey: key) {
            return try JSONDecoder.default.decode(T.self, from: storedData)
        }
        return nil
    }

    private func store<T: Encodable>(_ value: T, forKey key: String) throws {
        let encodedValue = try JSONEncoder.default.encode(value)
        defaults.set(encodedValue, forKey: key)
    }

    private func append<T: Codable>(element: T, toArrayForKey key: String) throws {
        var array: [T] = try storedObject(forKey: key) ?? []
        array.append(element)
        try store(array, forKey: key)
    }

    private func append<T: Codable>(elements: [T], toArrayForKey key: String) throws {
        var array: [T] = try storedObject(forKey: key) ?? []
        array.append(contentsOf: elements)
        try store(array, forKey: key)
    }

    private func sendStatsIfNeeded() {
        let sendPushNotificationsStatsOnly = !(configuration?.isEnabled ?? false)
        sendStats(forPushNotificationOnly: sendPushNotificationsStatsOnly)
    }

    // Returns true if there are stats to send
    // Do not call this method directly. Use `sendStatsIfNeeded()` instead.
    @discardableResult
    private func sendStats(forPushNotificationOnly pushNotificationOnly: Bool = false) -> Bool {
        var stats: Stats!
        queue.sync {
            let sessions: [Session]?
            let kpis: [Stats.KPI]?
            let requests: [Stats.RequestInfo]?
            let durationKpis: [Stats.APDurationKpi]?

            if pushNotificationOnly {
                sessions = nil
                kpis = nil
                requests = nil
                durationKpis = nil
            } else {
                sessions = try? self.storedObject(forKey: Keys.sessions, type: [Session].self)
                defaults.removeObject(forKey: Keys.sessions)

                kpis = try? self.storedObject(forKey: Keys.kpis, type: [Stats.KPI].self)
                defaults.removeObject(forKey: Keys.kpis)

                requests = try? self.storedObject(forKey: Keys.requests, type: [Stats.RequestInfo].self)
                defaults.removeObject(forKey: Keys.requests)
                
                durationKpis = try? self.storedObject(forKey: Keys.durationKpis, type: [Stats.APDurationKpi].self)
                defaults.removeObject(forKey: Keys.durationKpis)
            }

            let pushNotifications = try? self.storedObject(forKey: Keys.pushNotifications, type: [Stats.PushNotificationEvent].self)
            defaults.removeObject(forKey: Keys.pushNotifications)

            stats = Stats(sessions: sessions, kpis: kpis, lastRequests: requests, pushNotifications: pushNotifications, durations: durationKpis)
        }

        guard !stats.isEmpty else {
            return false
        }

        let request = requestManager.request(endpoint: WebService.postStats(stats))
        request.responseData { [weak self] result in
            switch result {
            case .success(_):
                print("[Stats] Stats successfully sent")
            case .failure(let error):
                print("[Stats] Unabled to sent stats.")
                print("Underlying error:", error)

                do {
                    try self?.saveStats(stats)
                } catch {
                    print("[Stats] Unabled save back the stats after the request failed")
                }
            }
        }

        return true
    }

    private func saveStats(_ stats: Stats) throws {
        try queue.sync {
            if let sessions = stats.sessions {
                try append(elements: sessions, toArrayForKey: Keys.sessions)
            }
            if let kpis = stats.kpis {
                try append(elements: kpis, toArrayForKey: Keys.kpis)
            }
            if let lastRequests = stats.lastRequests {
                try append(elements: lastRequests, toArrayForKey: Keys.requests)
            }
            if let pushNotifications = stats.pushNotifications {
                try append(elements: pushNotifications, toArrayForKey: Keys.pushNotifications)
            }
            if let durations = stats.durations {
                try append(element: durations, toArrayForKey: Keys.durationKpis)
            }
        }
    }

    private func clearAllStatsExceptPushNotifications() {
        [
            Keys.sessions,
            Keys.kpis,
            Keys.requests,
            Keys.durationKpis
        ].forEach { defaults.removeObject(forKey: $0) }
    }

    // MARK: - Save Requests

//    func logRequest(response: DataResponse, sessionID: Stats.Session.ID) {
//    }

    func savePushNotificationEvent(_ event: Stats.PushNotificationEvent) {
        addPushNotificationEvent(event)
    }

    private func addPushNotificationEvent(_ event: Stats.PushNotificationEvent) {
        let session = ApplicationSessionManager.shared.session
        
        queue.sync {
            do {
                try append(element: session, toArrayForKey: Keys.pushNotifications)
            } catch {
                print("[Stats] Unable to save a push notification event")
            }
        }
    }

}

extension StatsManager: ApplicationSessionManagerDelegate {
    
    func applicationSessionManager(_ applicationSessionManager: ApplicationSessionManager, didCloseSession session: Session) {
        endAllDurationKpis()
        addSession(session)
        sendStatsIfNeeded()
    }
    
}

extension StatsManager {

    enum Keys {
        static let sessions = "AP_STATS_SESSIONS"
        static let kpis = "AP_STATS_KPIS"
        static let durationKpis = "AP_DURATION_KPIS"
        static let requests = "AP_STATS_REQUESTS"
        static let pushNotifications = "AP_STATS_PUSHS"
    }

}
