# Arcane Propagation

```
[1] — IMAGE
[2] — CONVOLVE [1]
[3] — SHOW [2]
[4] — [1] = [3]; GOTO [2]

SHOW[image] :
	[COLOR]    — image.pixel
	[ANGLE]    — [COLOR] * 360.
	[POSITION] — image.position + (radius * [cos([ANGLE]), sin([ANGLE])]
	_showpoint(uv, [POSITION])
```
