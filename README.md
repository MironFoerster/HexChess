## HexChess (please suggest names)
Chess, but on hexagons, and with terrains, and crazy units, and cards..maybe...hopefully

### Run Debug Server and Client
in project folder run
```run_debug.bat (--n-clients 1)```
One terminal is the server, the others the clients. Each client will also spawn a game window.


## Quickstart Docs

### Overview
The code is structured around the online-multiplayer and the turn-based nature of the game.

The **GlobalNetworking** autoload (`global_networking.gd`) is the backbone of the game.
Each client- or server-instance of the game has its own GlobalNetworking instance.
It provides the methods for all scenarios where clients and server need to exchange updates of the **game state**


The **game state** is entirely represented by the Session class (session.gd). The GN of each client owns one instance of the session class, The GN of a server can hold multiple session instances when it is hosting multiple game sessions.

To ensure consistent updates the session instances on the server are **ground truth** and the session instances on the clients are only **mirrors** of the ground truth.

This means that a client can never update its own session directly. It has to use `GlobalNetworking.perform_action()` to send the **proposed update** to the server which will validate it and then remotely call `GlobalNetworking.session__perform_action()` on all clients to update all the mirror sessions.

 It exposes methods that GlobalNetworking can use to update the state when there is updates incoming.
For a 2 player game there would be three instances of the code running, one as the server and two as clients.
The Session object on the server is ground truth, the Session objects on the clients are mirrors.


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
## Game Objects, Object Types, Resources, Resource Types and Resource Type Specs

**Game Objects** are the logical representations of things that exist in the game world, such as items, terrain tiles, and units. The game session uses them to represent and update the current game state.

There are different **object types**, e.g. Item, Terrain, or Unit. For every object type, there is a corresponding class file (`<type>.gd`) that defines what **dynamic properties** (like "current health" or "is_damaged") and what **methods** all objects of that type have.

In addition to  **dynamic properties** game objects also need **static base values** that specify the inherent attributes of the kind of item, terrain or unit the object represents, such as its base health or movement cost.

The base values of specific items/terrains/units etc. are defined in separate Godot **Resources**. When a game object is created it is assigned with such a resource, providing it with all the base values it is supposed to represent.

For example, the base values of the "body armor" item are defined in the `body_armor.tres` Resource which can be used to create a "body armor" game object.

Different **Resource Types** (items, terrain, units, etc.) require different sets of properties.  
An item might define a `buff_effect`, while terrain might define a `tile_texture`.

To formalize this, each resource type has a small **Specification File** (`<type>_spec.gd`) that defines which properties resources of that type must or may have.
