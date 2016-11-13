## Outline

### What it should/could be?

* It should have all function of ParticleSystem, and about some parameter of love.graphics.draw.
* It should be cross-platform.
* It should use to Imgui as the UI kit.
* It could make/open/save a Particle File. (*.lpf, it means 'Love Particle File')
* It could edit more than one Particle Object.
* It could add a lua script file to change Particle Object.

### What does it have function?

* Particle Object List
	* Select one Particle Object.
	* Remove the selected Particle Object.
	* New a Particle Object.
	* Open a Particle File to make a Particle Object.
	* Save a Particle Object by a Particle File.
* Particle Object Operation
	* necessity
		* Texture (string filename)
		* Buffer Size (number size)
		* Emission Lifetime (number life)
		* Emission Rate (number rate)
	* outward
		* Area Spread (selection[uniform, normal, ellipse, none] distribution, number dx, number dy)
		* Insert Mode (selection[top, bottom, random] mode)
		* Quads (list[x, y, w, h] quads)
		* Offset (number x, number y)
		* Direction (number direction)
		* Spread (number spread)
	* motion
		* Colors (list[r, g, b, a][1<=x<=8] colors)
		* Sizes (list[size][1<=x<=8] sizes)
			* Variation (number variation (0-1))
		* Speed (number min, number max (min))
		* Spin (number min, number max (min))
			* Variation (number variation (0-1))
		* Rotation (number min, number max (min))
			* Relative (bool enable)
		* Radial Acceleration (number min, number max (min))
		* Tangential Acceleration (number min, number max (min))
		* Linear Damping (number min, number max (min))
		* Linear Acceleration (number xmin, number ymin, number xmax (xmin), number ymax (ymin))
* Editor Opinions
	* Set background image
	* Show FPS
	* Show buffer
	* Input FPS value
* Help
	* About editor
	* Control introduction

### Interface Layout

* It acquiescent size is 1280*720.
* It can free resizable.