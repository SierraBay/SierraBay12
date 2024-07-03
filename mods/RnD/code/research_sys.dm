/*
	Research subsystem. Manages the static part of R&D, aka designs, technology nodes and such.
	Does NOT handle tech trees since they're supposed to be instantiated per console, to track user's progress.
	It holds instantiated designs, instantiated technologies (nodes) and tech tree types.
	It sets research datums' designs and creates a new tree for each datum.
*/
