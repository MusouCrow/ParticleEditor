# Particle Editor

### This is a editor of particle for LÖVE
---

### About Editor

* This is a editor of particle for LÖVE. It be entrusted on the [Coding.net] (https://git.coding.net/musoucrow/ParticleEditor.git).
* It is licensed under the MIT License, see LICENSE for more information.
* The Particle Editor needs to run on LÖVE.

### What it should/could be?

* It should have all function of Particle System.
* It should be cross-platform. (Windows, Mac OS X, Ubuntu)
* It should use to Imgui as the UI kit.
* It could make/open/save a Particle File. (*.json)
* It could edit more than one Particle Object.

### Keyboard Shortcuts

* Space: Pause or restart the Particle Object's animation.
* Enter: Reset the Particle Object's animation.
* Up(Down) Arrow: Switch a Particle Object.
* Right Click: Move the Particle Objec.

### How to use the Particle File?

* The Particle File's format is JSON, so you need to use the library of CJSON. (Already be included in the **lib** folder)
* You can use the specially function in the **make.lua** to load Particle File and then to create Particle System object.
* The Particle File doesn't have Texture data, so you need to prepare yourself.