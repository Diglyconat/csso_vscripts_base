
// array of available languages
::CSSO_ServerLanguages <- [
	"brazilian", 
	"bulgarian", 
	"czech", 
	"danish", 
	"dutch", 
	"english", 
	"finnish", 
	"french", 
	"german", 
	"greek", 
	"hungarian", 
	"italian", 
	"japanese", 
	"korean", 
	"koreana", 
	"latam", 
	"norwegian", 
	"polish", 
	"portuguese", 
	"romanian", 
	"russian", 
	"schinese", 
	"spanish", 
	"swedish", 
	"tchinese", 
	"thai", 
	"turkish", 
	"ukranian"
]

// dict to store custom localization strings (those can be edited too!)
::CSSO_ServerLocalization <- {}

::CSSO_SetCustomLocalizationString <- function( szTokenName, szNewString, szLang = "english" )
{
	if( !cm_inArray( szLang, CSSO_ServerLanguages ) || typeof( szTokenName ).tolower() != "string" || typeof( szNewString ).tolower() != "string" )
		return
	
	if( !( szTokenName in CSSO_ServerLocalization ) )
		CSSO_ServerLocalization[ szTokenName ] <- {}
	
	CSSO_ServerLocalization[ szTokenName ][ szLang ] <- szNewString
}

::CSSO_SetCustomLocalizationTable <- function( szTokenName, szNewTable )
{
	if( typeof( szTokenName ) != "string" || typeof( szNewTable ) != "table" )
		return
	
	if( !( szTokenName in CSSO_ServerLocalization ) )
		CSSO_ServerLocalization[ szTokenName ] <- {}
	
	CSSO_ServerLocalization[ szTokenName ] <- szNewTable
}

::CSSO_GetLocalizationString <- function( szTokenName, szLang = "english" )
{
	if( szLang == null )
		szLang = "english"
	
	if( !cm_inArray( szLang, CSSO_ServerLanguages ) || !CSSO_ServerLocalization.rawin( szTokenName ) )
		return null
	
	if( !( szLang in CSSO_ServerLocalization[ szTokenName ] ) )
		szLang = "english"
	
	return CSSO_ServerLocalization[ szTokenName ][ szLang ]
}

::CSSO_GetLocalizationTable <- function( szTokenName )
{
	if( !CSSO_ServerLocalization.rawin( szTokenName ) )
		return null
	
	return CSSO_ServerLocalization[ szTokenName ]
}

// wrapper for "CSSO_SetCustomLocalizationString" (for easier access)
::scls <- CSSO_SetCustomLocalizationString

// wrapper for "CSSO_SetCustomLocalizationTable" (for easier access)
::sclt <- CSSO_SetCustomLocalizationTable

// wrapper for "CSSO_GetLocalizationString" (for easier access)
::gls <- CSSO_GetLocalizationString

// wrapper for "CSSO_GetLocalizationTable" (for easier access)
::glt <- CSSO_GetLocalizationTable