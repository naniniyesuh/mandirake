// Otomatik üretildi: emoji yerine kullanılan Mandırake ikonları (24x24 ızgara)
import SwiftUI

enum MIconName: String, CaseIterable {
    case bottle, note, ice, star, check, jar, alarm, calendar, bell, timer, bowl, sparkle, alert, globe, backup, trash, info, mail, ext, chev
}

struct MIconPart {
    let d: String
    let fill: UInt32?
    let stroke: UInt32?
    let width: CGFloat
}

extension MIconName {
    var parts: [MIconPart] {
        switch self {
        case .bottle: return [
            MIconPart(d: "M10 3.2 Q12 1.2 14 3.2 L14 5.5 H10 Z", fill: 0xFFD66B, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M9 5.5 H15 Q16 5.5 16 6.5 V7.5 Q16 8.5 15 8.5 H9 Q8 8.5 8 7.5 V6.5 Q8 5.5 9 5.5 Z", fill: 0xFF8FA3, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M10 8.5 H14 Q17 8.5 17 11.5 V18.0 Q17 21.0 14 21.0 H10 Q7 21.0 7 18.0 V11.5 Q7 8.5 10 8.5 Z", fill: 0xFFFDF7, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M7 14.5 H17 V18 Q17 21 14 21 H10 Q7 21 7 18 Z", fill: 0xD6EBFF, stroke: nil, width: 2),
            MIconPart(d: "M7 14.5 H17", fill: nil, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M7 14.5 V18 Q7 21 10 21 H14 Q17 21 17 18 V14.5", fill: nil, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M7 11.5 H9.5 M7 17.5 H9.5", fill: nil, stroke: 0x2B2A5E, width: 1.6),
        ]
        case .note: return [
            MIconPart(d: "M8 3 H16 Q19 3 19 6 V18 Q19 21 16 21 H8 Q5 21 5 18 V6 Q5 3 8 3 Z", fill: 0xFFFDF7, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M9 8.5 H15 M9 12.5 H15 M9 16.5 H12.5", fill: nil, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M15.5 15.5 L19.5 11.5", fill: nil, stroke: 0xFF8FA3, width: 2.6),
        ]
        case .ice: return [
            MIconPart(d: "M8.5 4 H15.5 Q20 4 20 8.5 V15.5 Q20 20 15.5 20 H8.5 Q4 20 4 15.5 V8.5 Q4 4 8.5 4 Z", fill: 0xD6EBFF, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M12 7.5 V16.5 M8.1 9.75 L15.9 14.25 M8.1 14.25 L15.9 9.75", fill: nil, stroke: 0x2B2A5E, width: 1.8),
        ]
        case .star: return [
            MIconPart(d: "M12 2.8 L14.7 8.8 L21.2 9.5 L16.3 13.8 L17.7 20.3 L12 17 L6.3 20.3 L7.7 13.8 L2.8 9.5 L9.3 8.8 Z", fill: 0xFFD66B, stroke: 0x2B2A5E, width: 2),
        ]
        case .check: return [
            MIconPart(d: "M21 12 C21 16.9707 16.9707 21 12 21 C7.0293 21 3 16.9707 3 12 C3 7.0293 7.0293 3 12 3 C16.9707 3 21 7.0293 21 12 Z", fill: 0x73CDB3, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M7.5 12.4 L10.6 15.4 L16.6 9", fill: nil, stroke: 0x2B2A5E, width: 2.4),
        ]
        case .jar: return [
            MIconPart(d: "M7.6 3 H16.4 Q18 3 18 4.6 V5.4 Q18 7 16.4 7 H7.6 Q6 7 6 5.4 V4.6 Q6 3 7.6 3 Z", fill: 0xFF8FA3, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M7 7 H17 V18 Q17 21 14 21 H10 Q7 21 7 18 Z", fill: 0xFFFDF7, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M9.6 10 V16", fill: nil, stroke: 0xA9D8FF, width: 2.2),
        ]
        case .alarm: return [
            MIconPart(d: "M4.2 8 Q4 5 7 3.8 M19.8 8 Q20 5 17 3.8", fill: nil, stroke: 0x2B2A5E, width: 2.2),
            MIconPart(d: "M19.3 13.2 C19.3 17.23179 16.03179 20.5 12 20.5 C7.96821 20.5 4.7 17.23179 4.7 13.2 C4.7 9.168209999999998 7.96821 5.8999999999999995 12 5.8999999999999995 C16.03179 5.8999999999999995 19.3 9.168209999999998 19.3 13.2 Z", fill: 0xFFFDF7, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M12 9 V13.4 L15 15.2", fill: nil, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M6 20 L7.6 18.4 M18 20 L16.4 18.4", fill: nil, stroke: 0x2B2A5E, width: 2),
        ]
        case .calendar: return [
            MIconPart(d: "M7.2 5 H16.8 Q20 5 20 8.2 V17.8 Q20 21 16.8 21 H7.2 Q4 21 4 17.8 V8.2 Q4 5 7.2 5 Z", fill: 0xFFFDF7, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M4 10.5 H20", fill: nil, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M8.2 3 V6.6 M15.8 3 V6.6", fill: nil, stroke: 0x2B2A5E, width: 2.2),
            MIconPart(d: "M9 13.5 H10.4 Q11.4 13.5 11.4 14.5 V15.899999999999999 Q11.4 16.9 10.4 16.9 H9 Q8 16.9 8 15.899999999999999 V14.5 Q8 13.5 9 13.5 Z", fill: 0xFF8FA3, stroke: nil, width: 0),
        ]
        case .bell: return [
            MIconPart(d: "M12 3 Q6.6 3 6.6 10 V14 L4.6 17 H19.4 L17.4 14 V10 Q17.4 3 12 3 Z", fill: 0xFFD66B, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M10 20 Q12 22 14 20", fill: nil, stroke: 0x2B2A5E, width: 2),
        ]
        case .timer: return [
            MIconPart(d: "M9.5 2.8 H14.5", fill: nil, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M12 2.8 V6", fill: nil, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M19.4 13.6 C19.4 17.68702 16.08702 21.0 12 21.0 C7.91298 21.0 4.6 17.68702 4.6 13.6 C4.6 9.512979999999999 7.91298 6.199999999999999 12 6.199999999999999 C16.08702 6.199999999999999 19.4 9.512979999999999 19.4 13.6 Z", fill: 0xFFFDF7, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M12 13.6 L15 10.6", fill: nil, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M18.6 7.4 L19.8 6.2", fill: nil, stroke: 0x2B2A5E, width: 2),
        ]
        case .bowl: return [
            MIconPart(d: "M3.4 11 H20.6 Q20.6 19 12 19 Q3.4 19 3.4 11 Z", fill: 0xCFC4FF, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M9 21 H15", fill: nil, stroke: 0x2B2A5E, width: 2),
        ]
        case .sparkle: return [
            MIconPart(d: "M11 3.5 Q12 10.5 19 12 Q12 13.5 11 20.5 Q10 13.5 3 12 Q10 10.5 11 3.5 Z", fill: 0xFFD66B, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M19 3 V7 M17 5 H21", fill: nil, stroke: 0x2B2A5E, width: 1.8),
        ]
        case .alert: return [
            MIconPart(d: "M12 3.6 L21 19 Q21.6 20.6 19.8 20.6 H4.2 Q2.4 20.6 3 19 Z", fill: 0xFF8FA3, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M12 9.5 V14", fill: nil, stroke: 0x2B2A5E, width: 2.2),
            MIconPart(d: "M13.1 17.2 C13.1 17.80753 12.60753 18.3 12 18.3 C11.39247 18.3 10.9 17.80753 10.9 17.2 C10.9 16.59247 11.39247 16.099999999999998 12 16.099999999999998 C12.60753 16.099999999999998 13.1 16.59247 13.1 17.2 Z", fill: 0x2B2A5E, stroke: nil, width: 0),
        ]
        case .globe: return [
            MIconPart(d: "M21 12 C21 16.9707 16.9707 21 12 21 C7.0293 21 3 16.9707 3 12 C3 7.0293 7.0293 3 12 3 C16.9707 3 21 7.0293 21 12 Z", fill: 0xA9D8FF, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M3 12 H21", fill: nil, stroke: 0x2B2A5E, width: 1.8),
            MIconPart(d: "M12 3 Q6.2 12 12 21 Q17.8 12 12 3 Z", fill: nil, stroke: 0x2B2A5E, width: 1.8),
        ]
        case .backup: return [
            MIconPart(d: "M8.5 3.5 H15.5 Q20.5 3.5 20.5 8.5 V15.5 Q20.5 20.5 15.5 20.5 H8.5 Q3.5 20.5 3.5 15.5 V8.5 Q3.5 3.5 8.5 3.5 Z", fill: 0xCFC4FF, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M12 7.5 V14.2 M8.8 11.2 L12 14.4 L15.2 11.2", fill: nil, stroke: 0x2B2A5E, width: 2.2),
            MIconPart(d: "M8 17.6 H16", fill: nil, stroke: 0x2B2A5E, width: 2.2),
        ]
        case .trash: return [
            MIconPart(d: "M4.5 7 H19.5", fill: nil, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M9.5 7 V4.8 H14.5 V7", fill: nil, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M6.3 7 L7.2 19 Q7.3 21 9.3 21 H14.7 Q16.7 21 16.8 19 L17.7 7 Z", fill: 0xFF8FA3, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M10.5 11 V17 M13.5 11 V17", fill: nil, stroke: 0x2B2A5E, width: 1.8),
        ]
        case .info: return [
            MIconPart(d: "M21 12 C21 16.9707 16.9707 21 12 21 C7.0293 21 3 16.9707 3 12 C3 7.0293 7.0293 3 12 3 C16.9707 3 21 7.0293 21 12 Z", fill: 0xA9D8FF, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M12 11 V16.6", fill: nil, stroke: 0x2B2A5E, width: 2.2),
            MIconPart(d: "M13.15 7.8 C13.15 8.435145 12.635145 8.95 12 8.95 C11.364855 8.95 10.85 8.435145 10.85 7.8 C10.85 7.164855 11.364855 6.65 12 6.65 C12.635145 6.65 13.15 7.164855 13.15 7.8 Z", fill: 0x2B2A5E, stroke: nil, width: 0),
        ]
        case .mail: return [
            MIconPart(d: "M6 5.5 H18 Q21 5.5 21 8.5 V15.5 Q21 18.5 18 18.5 H6 Q3 18.5 3 15.5 V8.5 Q3 5.5 6 5.5 Z", fill: 0xFFFDF7, stroke: 0x2B2A5E, width: 2),
            MIconPart(d: "M4 7.5 L12 13 L20 7.5", fill: nil, stroke: 0x2B2A5E, width: 2),
        ]
        case .ext: return [
            MIconPart(d: "M8 16 L16 8 M9 8 H16 V15", fill: nil, stroke: 0x2B2A5E, width: 2.2),
        ]
        case .chev: return [
            MIconPart(d: "M9 5 L16 12 L9 19", fill: nil, stroke: 0x2B2A5E, width: 2.6),
        ]
        }
    }
}
