
// recursive array conversion to string
::ArrayString <- function( arr, depth = -1 )
{
	local indent = function( count )
	{
		local i
		local indentStr = ""
		for( i = 0; i < count; i++ )
		{
			indentStr += "   "
		}
		
		return indentStr
	}
	
	local arrStr = ""
	if( type( arr ) == "table" )
		return TableString( table, depth + 1 )
	
	foreach( item in arr )
	{
		arrStr += indent( depth )
		switch( type( item ) )
		{
			case "table":
				arrStr += "{\n"
                arrStr += TableString( item, depth + 1 )
				arrStr += indent( depth ) + "}"
                break
			
            case "array":
				arrStr += "[\n"
				arrStr += ArrayString( item, depth + 1 )
				arrStr += indent( depth ) + "]"
                break
			
            case "string":
                arrStr += "\"" + item + "\""
                break
			
            default:
				arrStr += item
                break
		}
		
		if( depth > 0 )
			arrStr += ","
		
        arrStr += "\n"
	}
	
	return arrStr
}

// recursive table conversion to string
::TableString <- function( table, depth = -1 )
{
	local indent = function( count )
	{
		local i
		local indentStr = ""
		for( i = 0; i < count; i++ )
		{
			indentStr += "   "
		}
		
		return indentStr
	}
	
	local tableStr = ""
	if( type( table ) == "array" )
		return ArrayString( table, depth + 1 )
	
    foreach( key,value in table )
    {
		tableStr += indent( depth )
        switch( type( value ) )
        {
            case "table":
				tableStr += key
				if( depth <= 0 )
					tableStr += " <- \n"
				else
					tableStr += " = \n" + indent( depth )
				
				tableStr += "{\n"
                tableStr += TableString( value, depth + 1 )
				tableStr += indent( depth ) + "}"
                break
			
            case "array":
				tableStr += key
				if( depth <= 0 )
					tableStr += " <- \n"
				else
					tableStr += " = \n" + indent( depth )
				
				tableStr += "[\n"
				tableStr += ArrayString( value, depth + 1 )
				tableStr += indent( depth ) + "]"
                break
			
            case "string":
                tableStr += key
                if( depth <= 0 )
					tableStr += " <- \""
				else
					tableStr += " = \""
				
				
				tableStr += value + "\""
                break
			
            default:
				tableStr += key
				if( depth <= 0 )
					tableStr += " <- "
				else
					tableStr += " = "
				
				tableStr += value
                break
        }
		
		if( depth > 0 )
			tableStr += ","
		
        tableStr += "\n"
	}
	
	return tableStr
}

// prints specified table into console
::ArrayToString <- function( arr, depth = 0 )
{
	local resultArray = "[\n" + ArrayString( arr, depth + 1 ) + "]"
	return resultArray
}

// prints specified table into console
::TableToString <- function( table, headerName = null, depth = 0 )
{
	local resultTable = ""
	if( headerName != null && headerName.len() > 0 )
		resultTable += headerName + " <- "
	
	resultTable += "{\n" + TableString( table, depth + 1 ) + "}"
	return resultTable
}

// converts the table set via string to actual table
::StringToTable <- function( tableStr ){ return compilestring( "return " + tableStr )() }

// converts the table from file to actual table
::FileToTable <- function( fileName )
{
	local kvData = FileToString( fileName )
	if( !kvData )
		return null
	
	return compilestring( "return " + kvData )()
}

// recursive array print
::PrintArrayString <- function( arr, depth = -1 )
{
	local indent = function( count )
	{
		local i;
		for( i = 0; i < count; i++ )
		{
			print("   ")
		}
	}

	foreach( elem in arr )
	{
		indent( depth )
		local keyType = type( elem )
		if( !keyType )
			keyType = "instance"

		switch( keyType )
		{
			case "table":
				indent( depth )
				print( "{\n" )
				PrintTableString( elem, depth + 1 )
				indent( depth )
				print( "}" )
				break

			case "array":
				indent( depth )
				print( "[\n" )
				PrintArrayString( elem, depth + 1 )
				indent( depth )
				print( "]" )
				break

			default:
				print( elem )
				break
		}

		printl()
	}
}

// recursive table print
::PrintTableString <- function( table, depth = -1 )
{
	local indent = function( count )
	{
		local i;
		for( i = 0; i < count; i++ )
		{
			print("   ")
		}
	}

	foreach( key,value in table )
	{
		indent( depth )
		print( key )
		local keyType = type( value )
		if( !keyType )
			keyType = "instance"

		switch( keyType )
		{
			case "table":
				if( depth <= 0 )
					print( " <- " )
				else
					printl( " = " )

				indent( depth )
				print( "{\n" )
				PrintTableString( value, depth + 1 )
				indent( depth )
				print( "}" )
				break

			case "array":
				if( depth <= 0 )
					print( " <- " )
				else
					printl( " = " )

				indent( depth )
				print( "[\n" )
				PrintArrayString( value, depth + 1 )
				indent( depth )
				print( "]" )
				break

			default:
				if( depth <= 0 )
					print( " <- " )
				else
					print( " = " )

				print( value )
				break
		}

		printl()
	}
}

// function handle with more relatable name for tables and arrays
::PrintArray <- function( arr )
{
	printl( "[" )
	PrintArrayString( arr, 1 )
	printl( "]" )
}

::PrintTable <- function( table )
{
	printl( "{" )
	PrintTableString( table, 1 )
	printl( "}" )
}