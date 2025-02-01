//
//  CTPartMessages.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/31/25.
//

import Foundation
struct CTPartMessages: Identifiable{
    let id = UUID()
    static let p1msg = "Constitution - Hiến Pháp\nConstitutional - Thuộc Về Hiến Pháp\nAmendment - Tu Chính Án"
    static let p2msg = "President - Tổng Thống\nVice President - Phó Tổng Thống"
    static let p3msg = "United States - Nước Mỹ"
    static let p4msg = "Law - Luật Pháp\nGovernment - Chính Phủ\nState - Tiểu Bang"
    static let p5msg = "Declaration of Independence - Bản Tuyên Ngôn Độc Lập\nIndependence - Độc Lập\nAmerica - Nước Mỹ\nAmerican - Người Mỹ"
    static let p6msg = "U.S. - Thuộc Về Nước Mỹ\nU.S. War - Chiến Tranh Mỹ\nU.S. Citizens - Công Dân Mỹ\nU.S.Congress - Quốc Hội Mỹ\nU.S. Representatives - Hạ Nghị Viện\nHouse of Representatives - Vị Dân Biểu"
    static let p7msg = "Border - Đường Biên Giới/Giáp Với Một Nước\nName - Tên Nhân Vật Quan Trọng\n(Abraham Lincoln)"
    static let p8msg = "Holiday - Ngày Lễ\nNhững Từ Tượng Trưng Cho Nước Mỹ\n(Statue of Liberty - Tượng Nữ Thần Tự Do)"
    static let p9msg = "Phần Câu Hỏi Còn Lại"
    let partMessages = [
        "Phần 1": p1msg,
        "Phần 2": p2msg,
        "Phần 3": p3msg,
        "Phần 4": p4msg,
        "Phần 5": p5msg,
        "Phần 6": p6msg,
        "Phần 7": p7msg,
        "Phần 8": p8msg
    ]
}
