# Particle Editor

### This is a editor of particle for LÖVE
---

### About Particle Editor

* This is a editor of particle for LÖVE. It be entrusted on the [Coding.net] (https://git.coding.net/musoucrow/ParticleEditor.git).
* It is licensed under the MIT License, see LICENSE for more information.
* The Particle Editor needs to run on LÖVE.

### Features

* It has all function of Particle System.
* It is cross-platform. (Windows, Mac OS X, Ubuntu)
* It uses to Imgui as the UI kit.
* It can make/open/save a Particle File. (*.json)
* It can edit more than one Particle Object.

### Keyboard Shortcuts

* Space: Pause/Restart the Particle Object's animation.
* Enter: Reset the Particle Object's animation.
* Up(Down) Arrow: Switch a Particle Object.
* Right Click: Move the Particle Object.

### How to use?
* In ParticleEditor, you can make some Particle File to give your project to use.
* The Particle File's format is JSON, so you need to use the library of CJSON. (Already be included in the **lib** folder)
* You can use the specially function in the **load.lua** to load Particle File and then to create Particle System object.
* The Particle File doesn't have Texture data and Drawing data, so you need to prepare yourself.