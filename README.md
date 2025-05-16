# melody_house_demo

A flutter game built using flame engine used to build basic game functionality like building world using tilesets, creating movable characters, collision, animation, transitions, audio and sound effect integration to serve as a foundation for a bigger project. It was a cool project and had fun with the sound choices and game art although some debugging experiences were frustrating.

## Setup Instruction
Clone repo, install dependencies and run the app

## Features Implemented
- Two areas (outdoor and indoor scene)
- Movable Character with animations for idle and walking
- Collisions to restrict player movement
- Simple Transition system
- Background Music and sound effects for UI, transition and interactions
- Musical object (used sheep for this one cause of lack of appropriate art) interaction
- Visual cue for transition position 
- UI and tutorial

## Design Choices
- Put everything in outdoor and indoor scene into one component each for easy addition and removal
- For collision I marked all the objects that the player can't move past in a collision layer in tiled and retrieved those when loading the tile and created a collision block in that position which the player component can check for
- And other choices better I explained in the interview

## Identified Bug
- There may not be a menu music for the UI as browsers are banning auto play without user interaction. So triggering the audio after play interaction may solve it but I am not really sure 

## Controls
Use WASD or arrows for movement, M to mute, E to interact with the game for transition and musical object interaction
