//
//  ContentView.swift
//  Profiles
//
//  Created by Ben McMahen on 2019-06-17.
//  Copyright © 2019 Ben McMahen. All rights reserved.
//

import SwiftUI


struct CircleProfile : View {
    var image: Image
    
    var body: some View {
        image
            .resizable()
            .frame(width: 125, height: 125)
            .aspectRatio(CGSize(width: 50, height: 50), contentMode: .fill)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
        
    }
}


struct ContentView : View {
    
    @Binding var showMenu: Bool
    
    func onMenu() {
        self.showMenu.toggle()
    }
    
    var body: some View {
        VStack {
            Image("profile-background")
                .resizable()
                .aspectRatio(UIImage(named: "profile-background")!.size, contentMode: .fill)
            
            
            CircleProfile(image: Image("ben-again"))
                .offset(x: 0, y: -65)
                .padding(.bottom, -63)
            
            
            VStack(alignment: .center) {
                Text("Ben McMahen").font(.title)
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ")
                    .font(.body)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button(action: onMenu) {
                    Text("Show menu")
                }.padding()
            }.padding()
            
        Spacer()
            
        }
        
    }
}

func linearConversion(a: (Float, Float), b: (Float, Float)) -> ((Float) -> Float) {
    let o = a.1 - a.0
    let n = b.1 - b.0
    
    return { x in
        (((x - a.0) * n) / o) + b.0
    }
}

let getScaleVal = linearConversion(a: (0, -Float(UIScreen.main.bounds.size.width)), b: (0.9, 1.0))
let getOpacityVal = linearConversion(a: (0, -Float(UIScreen.main.bounds.size.width)), b: (0.4, 1.0))

enum Directions {
    case horizontal, vertical
}

struct MenuView : View {
    @State var showing = false
    @State var dragging = false
    @State var viewState: CGPoint = .zero
    
    @State var direction: Directions?
    
    func getOffset () -> CGFloat {
       
        if (dragging && direction == Directions.horizontal) {
                return viewState.x
        }
        
        if (showing) {
            return CGFloat(0)
        }
        
        return CGFloat(-UIScreen.main.bounds.width)
    }
    
    func getScale () -> Double {
        if (dragging  && direction == Directions.horizontal) {
            return Double(getScaleVal(Float(viewState.x)))
        }
        
        if (showing) {
            return 0.9
        }
        
        return 1.0
    }
    
    
    func getOpacity () -> Double {
        if (dragging  && direction == Directions.horizontal) {
            return Double(getOpacityVal(Float(viewState.x)))
        }
        
        if (showing) {
            return 0.4
        }
        
        return 1.0
    }
    
    var body : some View {
        
        let size = UIScreen.main.bounds.size
        
        let overlayTap = TapGesture().onEnded { _ in
            if (self.showing) {
                self.showing = false
            }
        }

        let drag = DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged{ state in
                
                if (self.direction == nil) {
                    let xdiff = abs(state.startLocation.x - state.location.x)
                    let ydiff = abs(state.startLocation.y - state.location.y)
                    print(xdiff, ydiff)
                    self.direction = xdiff > ydiff ? Directions.horizontal : Directions.vertical
                }
                
                
                if (!self.dragging) {
                    self.dragging = true
                }
                
                
                let delta = CGPoint(
                    x: (state.location.x - state.startLocation.x),
                    y: state.location.y - state.startLocation.y
                )
                
                self.viewState = delta
            }
            .onEnded { state in
                self.dragging = false
                
                let dx = state.location.x - state.startLocation.x
                
                if (dx < 0 && abs(dx) > ((size.width - 150) / 2)) {
                    self.showing = false
                }
                
                self.direction = nil
                
            }
        
        return ZStack {
        
            Group {
                VStack {
                    ContentView(showMenu: self.$showing)
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
            }
            .background(Color.white)
            .animation(dragging ? nil : .basic())
            .opacity(Double(getOpacity()))
            .scaleEffect(CGFloat(getScale()))
            .padding(.top, 44)
           
            
            VStack {
                VStack {
                    Button(action: { self.showing.toggle() }) {
                        Text("hide menu")
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 100, height: UIScreen.main.bounds.height)
            }
            .background(Color.white)
            .offset(x: getOffset())
            .animation(dragging ? nil : .basic())
            .padding(.top, 44)
            .padding(.trailing, 100)
            .shadow(radius: 10)
        }
            
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            .gesture(showing ? drag : nil)
            .gesture(showing ? overlayTap : nil)
        

    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
#endif
