<h1>Procedurally Generating Maze</h1>

<h2>Description</h2>

My goal for this project was to create a procedurally generating maze in Roblox to use for the basis of a horror game. The project has now since evolved into a series of Mini Games, which is still in development.
<br />
<br />
The maze is created by choosing a location from an array of location points to draw a path from. The path will randomly choose a direction to move in, until it finds a location that is already part of the maze to connect to. Once all of the locations in the array have been used, the maze is complete.

<h2>Languages and Utilities Used</h2>

- <b>Lua</b>
- <b>Roblox Studio</b> 

<h2>Environments Used </h2>

- <b>Windows 11</b>



<h2>Program walk-through:</h2>

<p align="center">
While the Maze is Generating, the player is put on a load screen: <br/>
<img src="https://i.imgur.com/9e4MYrO.png" height="75%" width="75%" alt="Disk Sanitization Steps"/>
<br />
<br />
In the background, however, the map is slowly generating around them:  <br/>
<img src="https://i.imgur.com/xlUqvDa.png" height="75%" width="75%" alt="Disk Sanitization Steps"/>
<br />
<br />
The maze will keep generating more and more paths, until the area designated is full: <br/>
<img src="https://i.imgur.com/VTCfn8N.png" height="75%" width="75%" alt="Disk Sanitization Steps"/>
<br />
<br />
Each time the maze is generated, it will be randomized, with the starting point for the maze (and the player) being in the center: <br/>
<img src="https://i.imgur.com/uC3cQt5.png" height="75%" width="75%" alt="Disk Sanitization Steps"/>
<br />
<br />
Once the map is done, the loading screen will be taken off, and the player will be allowed to roam around: <br/>
<img src="https://i.imgur.com/t7kBGNd.png" height="75%" width="75%" alt="Disk Sanitization Steps"/>
<br />
<br />
The map size can be easily edited, by changing two number values in the ServerStorage: <br/>
<img src="https://i.imgur.com/wNGnMop.png" height="75%" width="75%" alt="Disk Sanitization Steps"/>
</p>
<h2>References</h2>

[Wikipedia](https://en.wikipedia.org/wiki/Maze_generation_algorithm)
<!--

 ```diff
- text in red
+ text in green
! text in orange
# text in gray
@@ text in purple (and bold)@@
```
--!>
