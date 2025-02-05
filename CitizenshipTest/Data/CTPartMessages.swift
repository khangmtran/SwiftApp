//
//  CTPartMessages.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/31/25.
//

import Foundation
struct CTPartMessages: Identifiable{
    let id = UUID()
    static let p1msg = "1. Constitution - Hiến Pháp\n2. Constitutional - Thuộc Về Hiến Pháp\n3. Amendment - Tu Chính Án"
    static let p2msg = "1. President - Tổng Thống\n2. Vice President - Phó Tổng Thống"
    static let p3msg = "United States - Nước Mỹ"
    static let p4msg = "1. Law - Luật Pháp\n2. Government - Chính Phủ\n3. State - Tiểu Bang"
    static let p5msg = "1. Declaration of Independence - Bản Tuyên Ngôn Độc Lập\n2. Independence - Độc Lập\n3. America - Nước Mỹ\n4. American - Người Mỹ"
    static let p6msg = "1. U.S. - Thuộc Về Nước Mỹ\n2. U.S. War - Chiến Tranh Mỹ\n3. U.S. Citizens - Công Dân Mỹ\n4. U.S.Congress - Quốc Hội Mỹ\n5. U.S. Representatives - Hạ Nghị Viện\n6. House of Representatives - Vị Dân Biểu"
    static let p7msg = "1. Border - Đường Biên Giới/Giáp Với Một Nước\n2. Name - Tên Nhân Vật Quan Trọng\n(Abraham Lincoln - Nguoi Giai Phong No Le)"
    static let p8msg = "1. Holiday - Ngày Lễ\n2. Những Từ Tượng Trưng Cho Nước Mỹ\n(Statue of Liberty - Tượng Nữ Thần Tự Do)"
    static let p9msg = "Phần Câu Hỏi Còn Lại"
    let partMessages = [
        "Phần 1": p1msg,
        "Phần 2": p2msg,
        "Phần 3": p3msg,
        "Phần 4": p4msg,
        "Phần 5": p5msg,
        "Phần 6": p6msg,
        "Phần 7": p7msg,
        "Phần 8": p8msg,
        "Phần 9": p9msg
    ]
}
