//
//  GlobalStoreViewModel.swift
//  GaryDit
//
//  Created by Tom Knighton on 28/07/2023.
//

import Foundation
import Observation
import SwiftUI

class GlobalStoreViewModel: ObservableObject {
    
    @Published public var PostPageNavPath = NavigationPath()
    
    public static var shared: GlobalStoreViewModel = GlobalStoreViewModel()
}
