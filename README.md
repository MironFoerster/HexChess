## HexChess (please suggest names)
Chess, but on hexagons, and with terrains, and crazy units, and cards..maybe...hopefully

### Run Debug Server and Client
in project folder run
```run_debug.bat (--n-clients 1)```
One terminal is the server, the others the clients. Each client will also spawn a game window.


## Quickstart Docs

### Overview
The code is structured around the online-multiplayer and the turn-based nature of the game.

The **logical game state** is entirely contained and managed by the Session class (session.gd).
For a 2 player game there would be three instances of the code running, one as the server and two as clients.
The Session object on the server is seen as ground truth, the Session objects on the clients are mirrors.

The **networking** logic for both server and clients is contained in global_networking.gd.
Each client- or server-instance of the game has one GlobalNetworking instance (autoload).
GlobalNetworking provides specific methods for any communication a game instance would have to make.
e.g. A client might use GlobalNetworking.perform_action() to 

On the client:
**Session object** (mirror) has pure query methods that depend on game rules and state.
**Game scene** calls them when it needs gameplay info (e.g. highlight legal tiles).
When a player actually makes a move:
Game scene sends command → Networking → Server.
Server checks → updates session → broadcasts authoritative update.
Client session mirror updates accordingly → Sends Signal to game scene.
Game scene re-renders.


GlobalNetworking.gd (one instance of this exists on each client, mostly dumb networking layer)
For each feature (like "login" or "perform action") there is are three functions:
1. the CLIENT REQUEST function that can be called by the game-scene/UI-pages of the client.
2. the SERVER HANDLER which is remotely (RPC) invoked on the server by the CLIENT REQUEST function.
3. the CLIENT CALLBACK which is remotely invoked on the client by the SERVER HANDLER when it finishes processing.

This interaction exclusively happens between a single client and a single server instance.
If other clients need to be informed of a state change that happened as a result of the interaction,
the SERVER HANDLER can call UPDATE METHOD WRAPPERS for any client. Those directly update/modify the session of the specified client.



session.gd
Represents 
### Resources, Resource Types and Resource Type Specs

The base values of specific items/terrains/units etc. are defined in Godot **resources**.

For example, the base values of the "body armor" item are defined in the body_armor.tres Resource.

Different **resource types** (items, terrain, units, etc.) require different sets of properties.  
An item might define a `buff_effect`, while terrain might define a `tile_texture`.

To formalize this, each resource type has a small **specification file** (`*_spec.gd`) that defines which properties resources of that type must or may have.
