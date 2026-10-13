# Neon Dodge Pro — proyecto fuente iOS

Incluye juego arcade SwiftUI, movimiento táctil, obstáculos, monedas recogibles, niveles progresivos, récord local y tienda con mejoras comprables con monedas del juego.

## Ejecutar
1. Mac con Xcode reciente.
2. Xcode > File > New > Project > iOS App. Product Name: NeonDodge. Interface: SwiftUI. Language: Swift.
3. Sustituye el archivo principal generado por `GameView.swift` o añade este archivo al target y elimina el `@main` duplicado.
4. Añade `Assets.xcassets` al proyecto (o usa el icono como App Icon desde el asset catalog).
5. Establece un Bundle Identifier único en Signing & Capabilities y selecciona tu equipo Apple Developer.
6. Ejecuta primero en simulador y luego en dispositivo real.

## Monetización: lo que está y lo que falta
El juego está diseñado para ser gratuito. La tienda usa monedas virtuales ganadas durante las partidas. No se ha conectado todavía un SDK publicitario ni compras reales: para recompensas por anuncios hay que integrar un proveedor (por ejemplo Google AdMob), configurar el identificador de la app y los bloques publicitarios, añadir consentimiento/privacidad aplicable y probar anuncios de prueba. No se deben mostrar anuncios reales durante el desarrollo.
Para vender mejoras digitales dentro de iOS, integra StoreKit y configura productos en App Store Connect; Apple normalmente exige compras integradas para contenido digital vendido en la app.

## Antes de enviar a revisión
- Revisa y prueba colisiones, tienda, accesibilidad y distintos tamaños de pantalla.
- Crea icono final de 1024x1024, capturas y descripción.
- Añade URL de política de privacidad y completa la ficha de privacidad y clasificación por edad.
- Verifica requisitos vigentes de Apple, firma la app, crea Archive, valida y sube a App Store Connect.
- No incluye backend, cuentas, ranking online ni anuncios reales. La aprobación no está garantizada.
