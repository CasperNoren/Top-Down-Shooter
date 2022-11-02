# 🔫 Top-Down-Shooter
Game made in Godot inspired by [jmbiv's Godot top-down-shooter tutorial](https://www.youtube.com/playlist?list=PLpwc3ughKbZexDyPexHN2MXLliKAovkpl).

<img src="readme-full screen.png">

## 🥇 Features
Single player, top-down shooting with two opposing teams capturing bases </br>
### 🗃️ Original
Created in the tutorial
* Different weapons
* Friendly and Enemy team with AI
* Base capturing
* Title, pause and gameover screens
* Automatic respawning for all actors
* Particle effects
* Reloading </br>
### 🏋🏻 Add-Ons
Created by me
* Buying:
  * Added money from controlled bases
  * Buyable guns, turrets and extra team members
  * Shopping AI so the enemy team buys upgrades themselves
  * Made a menu for buying that is updated dynamically 
* Weapons:
  * Scrollable weapon selection
  * Weapon manager for actors
  * Shotgun
  * Different gun damage multiplier
  * Muzzle flash particles
* Turrets
* UI base state
* Fixed so you can spawn more team members than spawn points
</br>

## 🐌 TODO:
If I ever come back to this project
* A base with health for each team that needs to be destoryed to end the game (think age of war)
* Fix it so that enemies that get shot by someone out of their detection range will get alerted and move toward the shooter
</br>

## 😐 Misc:
I also was also the first one to find and fix a pretty big bug no one had ever noticed. When trying to capture a base the countdown to capturing would reset when new actors would enter the capture zone even if there was no change in who was winning the capture. It was a fairly easy fix but I still felt somewhat proud of being the first person to find it and fixing it myself.
</br>
