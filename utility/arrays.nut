
// weapon data dict
if( !( ::rawin( "CSSO_WeaponData" ) ) )
{
	::CSSO_WeaponData <- {}
	::CSSO_WeaponData_Missing <- []
}

// custom chat commands dict
::CSSO_ChatCommands <- {}

// hardcoded grenade classes array
::CSSO_BaseNadeClasses <- [
	"decoy_projectile", 
    "flashbang_projectile", 
    "hegrenade_projectile", 
    "incendiarygrenade_projectile", 
    "molotov_projectile", 
    "smokegrenade_projectile"
]

// chat color hex codes
::CSSO_ChatColors <- {
	aliceblue = "F0F8FF",
	antiquewhite = "FAEBD7",
	aqua = "00FFFF",
	aquamarine = "7FFFD4",
	azure = "007FFF",
	beige = "F5F5DC",
	bisque = "FFE4C4",
	black = "000000",
	blanchedalmond = "FFEBCD",
	blue = "6F9CE6",
	blueviolet = "8A2BE2",
	brown = "A52A2A",
	burlywood = "DEB887",
	cadetblue = "5F9EA0",
	chartreuse = "7FFF00",
	chocolate = "D2691E",
	coral = "FF7F50",
	cornflowerblue = "6495ED",
	cornsilk = "FFF8DC",
	crimson = "DC143C",
	cyan = "00FFFF",
	darkblue = "00008B",
	darkcyan = "008B8B",
	darkgoldenrod = "B8860B",
	darkgreen = "006400",
	darkgrey = "A9A9A9",
	darkkhaki = "BDB76B",
	darkmagenta = "8B008B",
	darkolivegreen = "556B2F",
	darkorange = "FF8C00",
	darkorchid = "9932CC",
	darkred = "8B0000",
	darksalmon = "E9967A",
	darkseagreen = "8FBC8F",
	darkslateblue = "483D8B",
	darkslategrey = "2F4F4F",
	darkturquoise = "00CED1",
	darkviolet = "9400D3",
	deeppink = "FF1493",
	deepskyblue = "00BFFF",
	dimgrey = "696969",
	dodgerblue = "1E90FF",
	firebrick = "B22222",
	floralwhite = "FFFAF0",
	forestgreen = "228B22",
	fuchsia = "FF00FF",
	fullblue = "0000FF",
	fullred = "FF0000",
	fullyellow = "FFFF00",
	gainsboro = "DCDCDC",
	ghostwhite = "F8F8FF",
	gold = "FFD700",
	goldenrod = "DAA520",
	green = "3EFF3E",
	greenyellow = "ADFF2F",
	grey = "CCCCCC",
	honeydew = "F0FFF0",
	hotpink = "FF69B4",
	indianred = "CD5C5C",
	indigo = "4B0082",
	ivory = "FFFFF0",
	khaki = "F0E68C",
	lavender = "E6E6FA",
	lavenderblush = "FFF0F5",
	lawngreen = "7CFC00",
	lemonchiffon = "FFFACD",
	lightblue = "99CCFF",
	lightblue2 = "ADD8E6",
	lightcoral = "F08080",
	lightcyan = "E0FFFF",
	lightgoldenrodyellow = "FAFAD2",
	lightgreen = "99FF99",
	lightgrey = "D3D3D3",
	lightpink = "FFB6C1",
	lightsalmon = "FFA07A",
	lightseagreen = "20B2AA",
	lightskyblue = "87CEFA",
	lightslategrey = "778899",
	lightsteelblue = "B0C4DE",
	lightyellow = "FFFFE0",
	lime = "00FF00",
	limegreen = "32CD32",
	linen = "FAF0E6",
	magenta = "FF00FF",
	maroon = "800000",
	mediumaquamarine = "66CDAA",
	mediumblue = "0000CD",
	mediumorchid = "BA55D3",
	mediumpurple = "9370D8",
	mediumseagreen = "3CB371",
	mediumslateblue = "7B68EE",
	mediumspringgreen = "00FA9A",
	mediumturquoise = "48D1CC",
	mediumvioletred = "C71585",
	midnightblue = "191970",
	mintcream = "F5FFFA",
	mistyrose = "FFE4E1",
	moccasin = "FFE4B5",
	navajowhite = "FFDEAD",
	navy = "000080",
	oldlace = "FDF5E6",
	olive = "9EC34F",
	olivedrab = "6B8E23",
	orange = "FFA500",
	orangered = "FF4500",
	orchid = "DA70D6",
	palegoldenrod = "EEE8AA",
	palegreen = "98FB98",
	paleturquoise = "AFEEEE",
	palevioletred = "D87093",
	papayawhip = "FFEFD5",
	peachpuff = "FFDAB9",
	peru = "CD853F",
	pink = "FFC0CB",
	plum = "DDA0DD",
	powderblue = "B0E0E6",
	purple = "800080",
	red = "FF4040",
	rosybrown = "BC8F8F",
	royalblue = "4169E1",
	saddlebrown = "8B4513",
	salmon = "FA8072",
	sandybrown = "F4A460",
	seagreen = "2E8B57",
	seashell = "FFF5EE",
	sienna = "A0522D",
	silver = "C0C0C0",
	skyblue = "87CEEB",
	slateblue = "6A5ACD",
	slategrey = "708090",
	snow = "FFFAFA",
	springgreen = "00FF7F",
	steelblue = "4682B4",
	tan = "D2B48C",
	teal = "008080",
	thistle = "D8BFD8",
	tomato = "FF6347",
	turquoise = "40E0D0",
	violet = "EE82EE",
	wheat = "F5DEB3",
	white = "FFFFFF",
	whitesmoke = "F5F5F5",
	yellow = "EABE54",
	yellowgreen = "9ACD32"
}

// default CS:SO team colors used for chat section nicknames
// 0 - no team
// 1 - spectators
// 2 - terrorists
// 3 - counter-terrorists
::CSSO_ChatTeamColors <- [
	"FFFFFF", 
	"FFFFFF", 
	"ffdf93", 
	"a2c6ff"
]

/////////////////////
// ARRAY FUNCTIONS //
/////////////////////

// get index of an element of array
::cm_getIndex <- function( tgt, arr )
{
	for( local i = 0; i < arr.len(); i++ )
		if ( arr[i] == tgt )
			return i
	
	return -1
}

// remove element from array
::cm_removeFromArray <- function( tgt, arr )
{
	local pos = cm_getIndex( tgt, arr )
	if ( pos > -1 )
		arr.remove( pos )
}

// add element to an array
::cm_addToArray <- function( tgt, arr ){ arr.append( tgt ) }

// add elements from one array to another array
::cm_addArray <- function( arr1, arr2, norepeat = true )
{
	if( arr2.len() < 1 )
		return arr1
	
	foreach( tgt in arr1 )
	{
		if( norepeat == true && cm_inArray( tgt, arr2 ) )
			continue
		
		arr2.append( tgt )
	}
	
	return arr2
}

// check if element is in array (returns true or false)
::cm_inArray <- function( tgt, arr ){ return cm_getIndex( tgt, arr ) > -1 }
