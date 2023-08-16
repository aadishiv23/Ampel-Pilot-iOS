//
//  VisualFeedbackView.swift
//  Ampel Pilot
//
//  Created by Patrick Valenta on 24.10.17.
//  Copyright © 2017 Patrick Valenta. All rights reserved.
//

import UIKit
// import SwiftUI

@available(iOS 13.0, *)
class VisualFeedbackView: UIView {
    
    private let phaseLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        l.textColor = .black
        l.adjustsFontForContentSizeCategory = true
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "No traffic light detected" // original translation Keine Ampel erkannt
        l.accessibilityTraits = UIAccessibilityTraitUpdatesFrequently
        
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        setupViews()
    }
    
    public func setPhase(_ phase: LightPhaseManager.Phase) {
        switch phase {
        case .green:
            backgroundColor = .green
            phaseLabel.text = "Green"
        case .red:
            backgroundColor = .red
            phaseLabel.text = "Red"
        case .none:
            backgroundColor = .clear
            phaseLabel.text = "No traffic light detected"
        }
    }
    
    private func setupViews() {
        addSubview(phaseLabel)
        
        phaseLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        phaseLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
