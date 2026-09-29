<h4>What is it?</h4>
It's a simple, but efficient nametag system for some RedM server which wants to try some roleplay favor.

<h4>Features</h4>
* native GamerTag-based nametag (which means save lots of performance from draw 3dtext every frame)
* efficient way to control nametag
* role-play action label (yes that purple shit above player , using timer)

<h4>How to use it?</h4>
I script it with RSGCore implementations, if you not gonna use it? make something similar by yourself.

<h4>Client Event: 'rdc_nametag:Client:updateName' </h4>
* Update the players' name, trigger it for all clients (-1)

<h4>'rdc_nametag:Client:updateText'</h4>
* Update the words player is talking, trigger it for all clients (-1)

<h4>'rdc_nametag:Client:toggleTyping'</h4>
* Update the typing state for player ('[...]'), trigger it for all clients (-1)

<h4>'rdc_nametag:Client:displayAction'</h4>
* Display current action as a label above player, trigger it for all clients (-1)
