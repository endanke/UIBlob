# UIBlob

A Swift implementation of the blob effect made by Liam Egan. Original source:
https://codepen.io/shubniggurath/pen/EmMzpp

![demo](/docs/demo.gif)

## Installation

### Cocoapods

`pod 'UIBlob`

### Manually

Just copy `UIBlob.swift` in your project

## How to Use

- Create an `UIBlob` instance programatically or through the interface builder.
- `shake()` - Animate the blob. (Can be stacked to increase entropy.)
- `stopShake()` - Stop and reset animation.

## Known issues

- Currently the blob doesn't fill the whole area of the view's bounds, because the graphics is generated in the `draw(_ rect: CGRect)` function and it needs some extra padding to offest the boundary of the circle during animation. This could be solved by using a sublayer to render the graphics outside the bounds, which will be implemented later. A temporary workaround is simply scaling up the layer with a transformation.

## Roadmap:
- [x] Blob effect
- [x] Global animator
- [ ] Touch point based shake animation
- [ ] CALayer based animation
- [ ] Procedural shake animation
- [ ] SwiftUI support