#Requires Autohotkey v2.0+ ; prefer 64-Bit
#Include <v2\Yunit\Yunit>
#Include <v2\Yunit\Window>

#Include .\..\lib\interfaces\SQLite3.ahk

Yunit.Use(YunitWindow).Test(tInterface)

class tInterface
{

	t1check_module_is_loaded_automatically() => Yunit.Assert(SQLite3.hModule, 'module was not loaded')
	t2check_properties_are_setup()
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
	t3version_strings()
	{
		Yunit.Assert(SQLite3.sourceid() == SQLITE_SOURCE_ID, 'source ids dont match')
		Yunit.Assert(SQLite3.libversion() == SQLITE_VERSION, 'version strings dont match')
		Yunit.Assert(SQLite3.libversion_number() = SQLITE_VERSION_NUMBER, 'version numbers dont match')
	}
}