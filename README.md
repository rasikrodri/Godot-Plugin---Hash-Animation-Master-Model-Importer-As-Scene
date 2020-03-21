# Godot-Plugin---Hash-Animation-Master-Model-Importer-As-Scene
Godot Plugin to import Hash Animation Master models and their actions into Godot game engine


**This is a plugin to import Hash Animation Master models with bones, one decal, and actions as one scene.**

***Just create a folder for the model inside the godot project, and copy the model, decals images/textures, and actions there.
The images/textures and actions can be placed in the same folder than the model or in a subfolder.***


***What it's imported:***

1. The model with bones and nulls.

2. The first decal with all it's stamps. This is becasue Godot only supports one set of uvs since game have to be efficient. Be sure to have all your model stamps in one decal.

3. Images for color assigned to the first decal.

4. Actions

***Things that are not implemented and may or may not be implemented acording to how much they are needed for a game:***

1. Only the color image of the decal is loaded. The rest like transparency, normal map, etc, can be easily added in the future if needed or can be added by hand.

2. Models lights are not implemented

3. None of the bones constraints. Godot does support inverse kinematics but it is in it's early stages. Also, it is possible to implement all the constraints in nativescript for speed but right now I haven not needed them. 
You are left with two options:
   1. You can still rig your model with advanced rigs that have constraints and create the actions with this rigs. But in order to see your model animated in godot you will have to create KeyFrames for all the bones that have cps assigned to them. In other words animate with your advanced rig and then apply keys to bones with weigths at the right times so that they will not need the advanced constraints in godot.

   2. Just keep a simple skeleton and animate it in actions with no constraints.



