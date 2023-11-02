#Requires Autohotkey v2.0+ ; prefer 64-Bit
#Include <v2\Yunit\Yunit>
#Include <v2\Yunit\Window>

#Include .\..\lib\interfaces\SQLite3.ahk

Yunit.Use(YunitWindow).Test(Interface_Tests)

class Interface_Tests
{
	check_module_is_loaded_automatically() => Yunit.Assert(SQLite3.hModule, 'module was not loaded')
	check_properties_are_setup()
	{
		props := ['hModule', 'bin', 'dllPath', 'ptrs']
		for prop in props
			Yunit.Assert(SQLite3.HasOwnProp(prop), prop ' was not initialized')
	}
	check_property_types()
	{
		props := Map(
			'hModule', 'Integer',
			'bin',     'String',
			'dllPath', 'String',
			'ptrs',    'Map'
		)

		for prop,prop_type in props
		{
			Yunit.Assert(SQLite3.HasOwnProp(prop), prop ' was not initialized')
			Yunit.Assert( Type(SQLite3.%prop%) == prop_type, prop ' has unexpected type ' prop_type)
		}
	}
}