//
//  BaseColor.swift
//  DesignSystem
//
//  Created by 이현재 on 1/2/26.
//

import UIKit

public enum BaseColor {
    // MARK: - Gray

    case gray0, gray10, gray15, gray20, gray30, gray40, gray50
    case gray60, gray70, gray80, gray85, gray90, gray100

    // MARK: - Pink

    case pink5, pink10, pink20, pink30, pink40, pink50
    case pink60, pink70, pink80, pink90, pink95

    // MARK: - Blue

    case blue10, blue20, blue30, blue40, blue50
    case blue60, blue70, blue80, blue90

    // MARK: - Yellow

    case yellow10, yellow20, yellow30, yellow40, yellow50
    case yellow60, yellow70, yellow80, yellow90

    // MARK: - Orange

    case orange10, orange20, orange30, orange40, orange50
    case orange60, orange70, orange80, orange90

    // MARK: - Purple

    case purple10, purple20, purple30, purple40, purple50
    case purple60, purple70, purple80, purple90

    // MARK: - Dimmed

    case dimmed10, dimmed15, dimmed20, dimmed30, dimmed50, dimmed70

    // MARK: - UIColor Accessor

    public var uiColor: UIColor {
        let name = switch self {
        case .gray0: "gray/0"
        case .gray10: "gray/10"
        case .gray15: "gray/15"
        case .gray20: "gray/20"
        case .gray30: "gray/30"
        case .gray40: "gray/40"
        case .gray50: "gray/50"
        case .gray60: "gray/60"
        case .gray70: "gray/70"
        case .gray80: "gray/80"
        case .gray85: "gray/85"
        case .gray90: "gray/90"
        case .gray100: "gray/100"
        case .pink5: "pink/5"
        case .pink10: "pink/10"
        case .pink20: "pink/20"
        case .pink30: "pink/30"
        case .pink40: "pink/40"
        case .pink50: "pink/50"
        case .pink60: "pink/60"
        case .pink70: "pink/70"
        case .pink80: "pink/80"
        case .pink90: "pink/90"
        case .pink95: "pink/95"
        case .blue10: "blue/10"
        case .blue20: "blue/20"
        case .blue30: "blue/30"
        case .blue40: "blue/40"
        case .blue50: "blue/50"
        case .blue60: "blue/60"
        case .blue70: "blue/70"
        case .blue80: "blue/80"
        case .blue90: "blue/90"
        case .yellow10: "yellow/10"
        case .yellow20: "yellow/20"
        case .yellow30: "yellow/30"
        case .yellow40: "yellow/40"
        case .yellow50: "yellow/50"
        case .yellow60: "yellow/60"
        case .yellow70: "yellow/70"
        case .yellow80: "yellow/80"
        case .yellow90: "yellow/90"
        case .orange10: "orange/10"
        case .orange20: "orange/20"
        case .orange30: "orange/30"
        case .orange40: "orange/40"
        case .orange50: "orange/50"
        case .orange60: "orange/60"
        case .orange70: "orange/70"
        case .orange80: "orange/80"
        case .orange90: "orange/90"
        case .purple10: "purple/10"
        case .purple20: "purple/20"
        case .purple30: "purple/30"
        case .purple40: "purple/40"
        case .purple50: "purple/50"
        case .purple60: "purple/60"
        case .purple70: "purple/70"
        case .purple80: "purple/80"
        case .purple90: "purple/90"
        case .dimmed10: "dimmed/10"
        case .dimmed15: "dimmed/15"
        case .dimmed20: "dimmed/20"
        case .dimmed30: "dimmed/30"
        case .dimmed50: "dimmed/50"
        case .dimmed70: "dimmed/70"
        }
        return UIColor(named: "Base/\(name)", in: .module, compatibleWith: nil)!
    }
}
