import SwiftUI

@main
struct NeonDodgeApp: App {
    var body: some Scene {
        WindowGroup { GameView() }
    }
}

struct GameView: View {
    @AppStorage("nd_best") private var best = 0
    @AppStorage("nd_coins") private var bankCoins = 0
    @State private var playerX: CGFloat = 0
    @State private var obstacles: [Obstacle] = []
    @State private var score = 0
    @State private var runCoins = 0
    @State private var isPlaying = false
    @State private var gameOver = false
    @State private var showShop = false
    @State private var tick = 0
    @State private var shield = false
    @State private var magnet = false
    @State private var speedLevel = 0
    @State private var ownedShield = false
    @State private var ownedMagnet = false
    private let timer = Timer.publish(every: 0.035, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [Color(red: 0.02, green: 0.025, blue: 0.09), .black], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                Circle().fill(Color.purple.opacity(0.22)).frame(width: 300).blur(radius: 70).offset(x: -130, y: -geo.size.height * 0.28)
                VStack(spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("NEON").font(.system(size: 14, weight: .black, design: .rounded)).tracking(5).foregroundStyle(.cyan)
                            Text("DODGE").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
                        }
                        Spacer()
                        statPill(icon: "bolt.fill", value: "\(score)", label: "PUNTOS")
                        statPill(icon: "circle.hexagongrid.fill", value: "\(bankCoins + runCoins)", label: "MONEDAS")
                        Button { showShop = true } label: {
                            Image(systemName: "cart.fill").font(.headline).foregroundStyle(.white).frame(width: 44, height: 44).background(.purple.opacity(0.3), in: RoundedRectangle(cornerRadius: 14))
                        }
                    }.padding(.horizontal, 18).padding(.top, 8)

                    ZStack {
                        RoundedRectangle(cornerRadius: 26).fill(Color.white.opacity(0.025))
                        RoundedRectangle(cornerRadius: 26).stroke(Color.cyan.opacity(0.22), lineWidth: 1)
                        ForEach(0..<8, id: \.self) { i in
                            Path { p in let x = geo.size.width * CGFloat(i) / 8; p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: geo.size.height * 0.8)) }
                                .stroke(Color.cyan.opacity(0.07), lineWidth: 1)
                        }
                        ForEach(obstacles) { ob in
                            Group {
                                if ob.kind == .coin {
                                    Image(systemName: "circle.hexagongrid.fill").font(.system(size: ob.size)).foregroundStyle(.yellow).shadow(color: .yellow.opacity(0.8), radius: 8)
                                } else {
                                    RoundedRectangle(cornerRadius: 8).fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: ob.size, height: ob.size).shadow(color: .pink.opacity(0.6), radius: 9)
                                }
                            }.position(x: ob.x * geo.size.width, y: ob.y * geo.size.height)
                        }
                        RoundedRectangle(cornerRadius: 10).fill(LinearGradient(colors: shield ? [.mint, .cyan] : [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 34, height: 34).overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.8), lineWidth: 1))
                            .shadow(color: .cyan.opacity(0.9), radius: shield ? 20 : 12)
                            .position(x: (0.5 + playerX) * geo.size.width, y: geo.size.height * 0.83)
                            .gesture(DragGesture(minimumDistance: 0).onChanged { v in playerX = min(0.43, max(-0.43, v.location.x / geo.size.width - 0.5)) })
                        if !isPlaying {
                            VStack(spacing: 12) {
                                Image(systemName: gameOver ? "sparkles" : "bolt.fill").font(.system(size: 38)).foregroundStyle(.cyan)
                                Text(gameOver ? "¡BUENA PARTIDA!" : "ESQUIVA Y SOBREVIVE").font(.headline.bold()).foregroundStyle(.white)
                                Text(gameOver ? "Puntos: \(score) · Monedas: +\(runCoins)" : "Desliza para moverte y recoge monedas").font(.subheadline).multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.68))
                                Button(gameOver ? "VOLVER A JUGAR" : "JUGAR") { startGame() }
                                    .font(.headline.bold()).foregroundStyle(.black).padding(.horizontal, 30).padding(.vertical, 14)
                                    .background(LinearGradient(colors: [.cyan, .mint], startPoint: .leading, endPoint: .trailing), in: Capsule())
                                Text("RÉCORD PERSONAL  \(best)").font(.caption.bold()).tracking(1).foregroundStyle(.purple)
                            }.padding(26).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                        }
                    }.frame(height: geo.size.height * 0.67).padding(.horizontal, 12)

                    HStack(spacing: 16) {
                        moveButton("arrow.left") { playerX = max(-0.43, playerX - 0.12) }
                        VStack(spacing: 3) {
                            Text("DESLIZA PARA MOVERTE").font(.caption2.bold()).tracking(1.3).foregroundStyle(.white.opacity(0.55))
                            Text("RÉCORD: \(best)").font(.caption2.bold()).foregroundStyle(.purple)
                        }
                        moveButton("arrow.right") { playerX = min(0.43, playerX + 0.12) }
                    }
                    HStack(spacing: 8) {
                        Label("NIVEL \(1 + score / 150)", systemImage: "flame.fill").foregroundStyle(.orange)
                        Spacer()
                        Text("MEJORAS").foregroundStyle(.white.opacity(0.5))
                        Button { shield.toggle() } label: { Image(systemName: "shield.fill").foregroundStyle(shield ? .mint : .white).padding(9).background(.white.opacity(0.07), in: Circle()) }.disabled(!isPlaying || !ownedShield)
                        Button { magnet.toggle() } label: { Image(systemName: "magnet.fill").foregroundStyle(magnet ? .yellow : .white).padding(9).background(.white.opacity(0.07), in: Circle()) }.disabled(!isPlaying || !ownedMagnet)
                    }.font(.caption.bold()).padding(.horizontal, 22).padding(.bottom, 8)
                }
            }
            .onReceive(timer) { _ in advance() }
            .sheet(isPresented: $showShop) { shopView }
            .preferredColorScheme(.dark)
        }
    }

    func statPill(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Label(value, systemImage: icon).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundStyle(.white)
            Text(label).font(.system(size: 8, weight: .bold)).tracking(1).foregroundStyle(.white.opacity(0.45))
        }.padding(.horizontal, 9).padding(.vertical, 8).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
    func moveButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(systemName: symbol).font(.title3.bold()).foregroundStyle(.white).frame(width: 54, height: 44).background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14)).overlay(RoundedRectangle(cornerRadius: 14).stroke(.cyan.opacity(0.25), lineWidth: 1)) }
    }
    var shopView: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.025, green: 0.03, blue: 0.1).ignoresSafeArea()
                VStack(spacing: 14) {
                    Text("MONEDAS: \(bankCoins)").font(.title2.bold()).foregroundStyle(.yellow)
                    shopItem(icon: "shield.fill", title: "Escudo energético", detail: "Protege de un choque", cost: 60, owned: ownedShield) {
                        if bankCoins >= 60 && !ownedShield { bankCoins -= 60; ownedShield = true }
                    }
                    shopItem(icon: "magnet.fill", title: "Imán de monedas", detail: "Atrae monedas cercanas", cost: 80, owned: ownedMagnet) {
                        if bankCoins >= 80 && !ownedMagnet { bankCoins -= 80; ownedMagnet = true }
                    }
                    Text("Las recompensas de anuncios se añadirán al integrar un proveedor publicitario.").font(.footnote).foregroundStyle(.white.opacity(0.5)).multilineTextAlignment(.center).padding()
                    Spacer()
                }.padding()
            }.navigationTitle("Tienda").toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Cerrar") { showShop = false } } }
        }.presentationDetents([.medium, .large])
    }
    func shopItem(icon: String, title: String, detail: String, cost: Int, owned: Bool, action: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title2).foregroundStyle(.cyan).frame(width: 44, height: 44).background(.cyan.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 3) { Text(title).font(.headline); Text(detail).font(.caption).foregroundStyle(.white.opacity(0.55)) }
            Spacer()
            Button(owned ? "COMPRADO" : "🟡 \(cost)", action: action).font(.caption.bold()).disabled(owned || bankCoins < cost).padding(9).background(.purple.opacity(0.35), in: Capsule())
        }.padding(12).background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
    }
    func startGame() {
        score = 0; runCoins = 0; tick = 0; playerX = 0; obstacles = []; shield = false; magnet = false; gameOver = false; isPlaying = true
    }
    func advance() {
        guard isPlaying else { return }
        tick += 1
        if tick % max(9, 24 - score / 100) == 0 {
            let kind: Obstacle.Kind = Int.random(in: 0..<5) == 0 ? .coin : .block
            obstacles.append(Obstacle(x: CGFloat.random(in: 0.08...0.92), y: 0.02, size: kind == .coin ? 23 : CGFloat.random(in: 21...34), kind: kind))
        }
        obstacles = obstacles.compactMap { old in
            var ob = old
            ob.y += 0.0075 + CGFloat(score) * 0.000025
            let close = abs(ob.x - (0.5 + playerX)) < (magnet && ob.kind == .coin ? 0.18 : 0.06) && abs(ob.y - 0.83) < 0.06
            if close && ob.kind == .coin { runCoins += 1; return nil }
            if close && ob.kind == .block {
                if shield { shield = false; return nil }
                finishGame()
            }
            if ob.y > 0.91 { if ob.kind == .block { score += 1 }; return nil }
            return ob
        }
    }
    func finishGame() {
        isPlaying = false; gameOver = true
        bankCoins += runCoins
        if score > best { best = score }
    }
}
struct Obstacle: Identifiable {
    enum Kind { case block, coin }
    let id = UUID()
    let x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let kind: Kind
}
