DESIGN DOCUMENT
===============

1. We decided to separate the relation in file PRODUCTION_CAST.csv into two separate relationship. The first one is a binary relationship between a Person and a Production,
it has an attribute role (writer, director) which cannot be actor neither actress. Actors and actresses have a dedicated ternary relationship linking a Production, a Person and Persona (Character is a keyword in SQL).
We decided to remove the actress role as this information is already present in Person.gender.
This type of diagram is not expressive enough to specify the participation and key constraints for ternary relationships, so we have to say it here.
	- Persona has a total participation with Production and Person
	- Person has a partial participation with Production because not every person is an actor, for the same reason the participation constraint with Persona is partial
	- Production has partial participation with the two others entity sets because some of them do not have actors or characters (eg. "Baraka")
	- Production -> Person is a one-to-many relationship
	- Production -> Persona is a one-to-many relationship
	- Person -> Persona is a many-to-many relationship


2. We decided to represent Episode and TV Series as subclasses of the Production entity. This allows us to have attributes specific to the subclasses while retaining the common attributes of a Production. An episode cannot be a TV Serie thus this is a Non-overlapping ISA relation but there is no covering constraint because a Production might neither be an Episode nor a TV Serie. 
