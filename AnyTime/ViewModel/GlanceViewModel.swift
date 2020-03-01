//
//  GlanceViewModel.swift
//  AnyTime
//
//  Created by Tao Xu on 9/30/17.
//  Copyright © 2017 Tao Xu. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import EventKit

protocol GlanceViewModelOwner: class {
    var listView: UITableView { get }
    var visiable: Bool { get }
}

class GlanceViewModel: NSObject {
    var favs = [String]()
    var dateformat = ""
    var timezones = [TimeZoneItem]()
    var selectedDate: Date?
    let store = EKEventStore()

    weak var owner: GlanceViewModelOwner?

    override init() {
        super.init()
        finishInit()
    }

    convenience init(owner: GlanceViewModelOwner? = nil) {
        self.init()
        self.owner = owner
        finishInit()
    }

    func finishInit() {
        self.favs = Defaults.favorites
        self.dateformat = Defaults.format
        self.timezones = TimeZoneItem.get(ids: favs)

        for key in AnyTimeKey.all() {
            UserDefaults.standard.addObserver(self, forKeyPath: key, options: [.new], context: nil)
        }
    }

    deinit {
        for key in AnyTimeKey.all() {
            UserDefaults.standard.removeObserver(self, forKeyPath: key)
        }
    }

    func item(at indexPath: IndexPath) -> TimeZoneItem? {
        if indexPath.row < timezones.count {
            return timezones[indexPath.row]
        }
        return nil
    }

    //swiftlint:disable identifier_name
    func move(at indexPath: IndexPath, to: IndexPath) {
    //swiftlint:enable identifier_name
        timezones.move(at: indexPath.row, to: to.row)
        Defaults.favorites = timezones.map { $0.timezone.identifier }
    }

    func delete(at indexPath: IndexPath) {
        timezones.remove(at: indexPath.row)
        favs.remove(at: indexPath.row)
        Defaults.favorites = self.favs
    }

    //swiftlint:disable block_based_kvo
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {

        if let visiable = owner?.visiable, visiable == true {
            return
        }

        guard let keyPath = keyPath, let change = change else {
            return
        }

        if keyPath == AnyTimeKey.favorites.rawValue {
            guard let new = change[NSKeyValueChangeKey.newKey] as? [String] else {
                return
            }
            if self.favs != new {
                self.favs = new
                self.timezones = TimeZoneItem.get(ids: Defaults.favorites)
                owner?.listView.reloadData()
            }
        } else if keyPath == AnyTimeKey.format.rawValue {
            guard let new = change[NSKeyValueChangeKey.newKey] as? String else {
                return
            }
            if self.dateformat != new {
                self.dateformat = new
                owner?.listView.reloadData()
            }
        } else if keyPath == AnyTimeKey.preferCity.rawValue {
            owner?.listView.reloadData()
        }
    }
    //swiftlint:enable block_based_kvo
}
