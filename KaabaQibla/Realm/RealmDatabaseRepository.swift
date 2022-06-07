//
//  RealmDatabaseRepository.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/6/22.
//

import Foundation
import RealmSwift
import Combine


protocol Repository {
    associatedtype S
    associatedtype U

    func getAll(objectsWith predicate: NSPredicate?) -> AnyPublisher<[S], Never>
    func getObject(by id: U) -> AnyPublisher<S?, Never>

    func add(_ element: S)
    func add<T: Sequence>(contentOf elements: T) where T.Element: Object

    func removeObject(with id: U)
    func clearRepository()

}

class RealmDatabaseRepository<S: Object, U: Hashable>: Repository {
    private let configuration: Realm.Configuration
    private let queue: DispatchQueue
    init(configuration: Realm.Configuration, dispatchQueueLabel: String) {
        self.configuration = configuration
        queue = .init(label: dispatchQueueLabel)
    }
    private func makeRealm() throws -> Realm {
        try Realm.init(configuration: configuration, queue: queue)
    }

    func getAll(objectsWith predicate: NSPredicate?) -> AnyPublisher<[S], Never> {
        guard let realm = try? makeRealm() else { return Empty().eraseToAnyPublisher() }
        let result = realm.objects(S.self)
        return Just(Array(result)).eraseToAnyPublisher()
    }
    
    func getObject(by id: U) -> AnyPublisher<S?, Never> {
        guard let realm = try? makeRealm() else { return Empty().eraseToAnyPublisher() }
        let element = realm.object(ofType: S.self, forPrimaryKey: id)
        return Just(element).eraseToAnyPublisher()
    }
    
    func add(_ element: S) {
        guard let realm = try? makeRealm() else { return }
        try? realm.write {
            realm.add(element)
        }
    }
    
    func add<T>(contentOf elements: T) where T : Sequence, T.Element : Object {
        guard let realm = try? makeRealm() else { return }
        try? realm.write {
            realm.add(elements)
        }
    }
    
    func removeObject(with id: U) {
        guard let realm = try? makeRealm() else { return }
        try? realm.write {
            if let element = realm.object(ofType: S.self, forPrimaryKey: id) {
                realm.delete(element)
            }
        }
    }
    
    func clearRepository() {
        guard let realm = try? makeRealm() else { return }
        try? realm.write {
            let elements = realm.objects(S.self)
            realm.delete(elements)
        }
    }

    func updateElement(withId id: U, edit: (S) -> Void) {
        guard let realm = try? makeRealm() else { return }
        try? realm.write {
            if let element = realm.object(ofType: S.self, forPrimaryKey: id) {
                edit(element)
            }
        }
    }
}
