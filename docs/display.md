# Display

## Grid display

* The tiles images all consist of three parts, the top part is transparent, the middle part is the cell's surface and the bottom part is the cell's wall. When a tile image is below another one, it's middle part covers the bottom part of the picture over it. Only the bottom row shows it's wall. The main part of the pictures is 100x81 pixels.d
* When a cell is empty, it displays a water tile "Water Block.png".
* The grid scales to adapt to the device's screen width

## Bugs

* Bugs are displayed on top of "Water Block.png", so when a cell holds a bug, both the "Water Block.png" and the "Enemy Bug.png" images should be displayed. The "Enemy Bug.png" image should be shifted up by 50px.
