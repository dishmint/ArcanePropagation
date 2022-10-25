# Arcane Propagation

* Transmit pixel values across images
* Draw a point rotating around a pixel's origin by an `ANGLE` determined by the pixel's value.

The most complete version of the exploration would be this p4 implementation: // [p4_ArcanePropagator](./p4_ArcanePropagator/) //

```
[1] — IMAGE
[2] — FILTER [1]
[3] — SHOW [2]
[4] — [1] = [3]; GOTO [2]

SHOW[image] :
	[COLOR]    — image.pixel
	[ANGLE]    — MAP[COLOR, 0, TAU]
	[POSITION] — image.position + (radius * [cos([ANGLE]), sin([ANGLE])]
	_showpoint(uv, [POSITION])
```
