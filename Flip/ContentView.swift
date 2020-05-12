//
//  ContentView.swift
//  Flip
//  http://acbl.mybigcommerce.com/52-playing-cards/

import SwiftUI

struct Cards:View{
    @State private var angles:(x:Double,y:Double,z:Double) = (x:0.0,y:0.0,z:0.0)//各軸の角度
    
    var body: some View{
        VStack{
            Spacer()
            ZStack{
                Card(imageName: "AH", isFront: true, angles: self.$angles)
                Card(imageName: "gray_back", isFront: false, angles: self.$angles)
            }.animation(.linear(duration: 1.0))
            Spacer()
            VStack{
                Slider(value: self.$angles.y, in: -Double.pi...Double.pi)
                Slider(value: self.$angles.x, in: -Double.pi...Double.pi)
                Slider(value: self.$angles.z, in: -Double.pi...Double.pi)
            }.padding()
            Spacer()
        }
    }
}

struct Card:View{
    let imageName:String
    let isFront:Bool
    
    @Binding var angles:(x:Double,y:Double,z:Double)
    @State private var zIndex:Double = 0.0
    
    var body: some View{
        Image(self.imageName)
            .resizable()
            .frame(width: 200.0, height: 300.0)
            .modifier(FlipEffect(isFront: self.isFront, angles: self.angles, zIndex: self.$zIndex))
            .zIndex(self.zIndex)
    }
}

struct FlipEffect:GeometryEffect{
    let isFront:Bool
    var angles:(x:Double,y:Double,z:Double)
    
    @Binding var zIndex:Double
    
    var animatableData: AnimatablePair<Double,AnimatablePair<Double,Double>>{
        get{return AnimatablePair(angles.x,AnimatablePair(angles.y,angles.z))}
        set{
            angles.x = newValue.first
            angles.y = newValue.second.first
            angles.z = newValue.second.second
        }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let centerPoint:(x:CGFloat,y:CGFloat) = (x:size.width/2.0,y:size.height/2.0)
        
        var transform3d = CATransform3DIdentity
        transform3d.m34 =  1.0/max(size.width,size.height)
        transform3d = CATransform3DRotate(transform3d, CGFloat(self.angles.z), 0.0, 0.0, 1.0)
        transform3d = CATransform3DRotate(transform3d, CGFloat(self.angles.x), 1.0, 0.0, 0.0)
        transform3d = CATransform3DRotate(transform3d, self.isFront ? 0:.pi, 0.0, 1.0, 0.0)
        transform3d = CATransform3DRotate(transform3d, CGFloat(self.angles.y), 0.0, 1.0, 0.0)
        transform3d = CATransform3DTranslate(transform3d, -1 * centerPoint.x, -1 * centerPoint.y, 0.0)
        DispatchQueue.main.async {
            self.zIndex = Double(transform3d.m34)
        }
        let affineTransform = ProjectionTransform(CGAffineTransform(translationX: centerPoint.x, y: centerPoint.y))
        
        return ProjectionTransform(transform3d).concatenating(affineTransform)
    }
}

struct ContentView: View {
    var body: some View {
        Cards()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
