#SingleInstance
#Requires AutoHotkey v2.0+ ; prefer 64-Bit

#Include <v2\Yunit\Yunit>
#Include <v2\Yunit\Window>

#Include .\..\SQLite.ahk

Yunit.Use(YunitWindow).Test(tSqliteInterface)

class tSqliteInterface
{
	begin()
	{
		this.flags := SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_MEMORY
		this.db := SQLite('test.db', this.flags)
	}
	end() => SQLite3.close_v2(this.db.ptr)

	test1_class_is_setup_correctly()
	{
		db := this.db
		props := Map(
			'ptr',   'Integer',
			'path',  'String',
			'error', 'String'
		)

		for prop,prop_type in props
		{
			Yunit.Assert(db.HasOwnProp(prop), prop ' was not initialized')
			Yunit.Assert(Type(db.%prop%) == prop_type, prop ' has unexpected type ' prop_type)
		}
	}
}