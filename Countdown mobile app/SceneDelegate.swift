//
//  SceneDelegate.swift
//  Countdown mobile app
//
//  Created by alexei on 24.04.2022.
//

import UIKit
    //TODO: поправить отступы, удалить boilerplate code
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //TODO: увести логику в отдельный private метод и вызвать его тут
        // чтобы не городить if else можно сделать так
//      var initialViewController: UIViewController
// 		let condition = UserDefaults.standard.bool(forKey: "EventsViewControlerWasOpened")
//      initialViewController = condition: storyboard.instantiateViewController(withIdentifier: "Main") ? storyboard.instantiateViewController(withIdentifier: "Welcome")
//      ключи для userdefaults и идентификаторы сториборда лучше перевести в отдельный enum
        var initialViewController: UIViewController
        if UserDefaults.standard.bool(forKey: "EventsViewControlerWasOpened") {
            initialViewController = storyboard.instantiateViewController(withIdentifier: "Main")
        } else {
            initialViewController = storyboard.instantiateViewController(withIdentifier: "Welcome")
        }
        let navigationViewController = UINavigationController(rootViewController: initialViewController)
        navigationViewController.isNavigationBarHidden = true
        window?.rootViewController = navigationViewController
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

