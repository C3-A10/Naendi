//
//  FolderTabShape.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 17/07/26.
//

import SwiftUI

struct FolderTabShape: Shape {
    
    var tabWidth: CGFloat = 240   // Lebar tonjolan kiri
    var slopeWidth: CGFloat = 35  // Lebar lereng miring
    
    var leftTabHeight: CGFloat = 160  // Tinggi dari bawah sampai puncak tonjolan (kiri)
    var rightTabHeight: CGFloat = 112 // Tinggi dari bawah sampai atap datar (kanan)
    
    var leftCornerRadius: CGFloat = 16  // Sudut kiri atas
    var rightCornerRadius: CGFloat = 16 // Sudut kanan atas (atas chevron down)
    var slopeRadius: CGFloat = 16       // Kehalusan tikungan lereng miring
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Menentukan titik koordinat Y berdasarkan tinggi yang kamu input
        let bottomY = rect.maxY
        let leftTopY = bottomY - leftTabHeight
        let rightTopY = bottomY - rightTabHeight
        
        // 1. Mulai dari pojok kiri bawah
        path.move(to: CGPoint(x: 0, y: bottomY))
        
        // 2. Naik ke pojok kiri atas (sesuai leftTabHeight) & lengkungkan
        path.addLine(to: CGPoint(x: 0, y: leftTopY + leftCornerRadius))
        path.addArc(
            tangent1End: CGPoint(x: 0, y: leftTopY),
            tangent2End: CGPoint(x: leftCornerRadius, y: leftTopY),
            radius: leftCornerRadius
        )
        
        // 3. Garis datar atas kiri (tempat badge), lalu masuk ke lereng miring
        path.addArc(
            tangent1End: CGPoint(x: tabWidth, y: leftTopY),
            tangent2End: CGPoint(x: tabWidth + slopeWidth, y: rightTopY),
            radius: slopeRadius
        )
        
        // 4. Lereng miring turun, lalu masuk ke garis datar kanan
        path.addArc(
            tangent1End: CGPoint(x: tabWidth + slopeWidth, y: rightTopY),
            tangent2End: CGPoint(x: rect.maxX, y: rightTopY),
            radius: slopeRadius
        )
        
        // 5. Garis datar kanan (sesuai rightTabHeight), lalu lengkungkan sudut atas chevron!
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: rightTopY),
            tangent2End: CGPoint(x: rect.maxX, y: bottomY),
            radius: rightCornerRadius
        )
        
        // 6. Turun ke kanan bawah dan tutup rute
        path.addLine(to: CGPoint(x: rect.maxX, y: bottomY))
        path.closeSubpath()
        
        return path
    }
}
