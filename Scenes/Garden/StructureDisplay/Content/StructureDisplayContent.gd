extends Control
class_name StructureDisplayContent

# # # # #
# Base class for Structure Display Content elements
# Does nothing on its own, just an interface class for inheritance 
# # # # #

var structure : Structure

func init(_structure : Structure):
	structure = _structure
