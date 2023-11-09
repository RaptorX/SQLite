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
	test2_database_is_opened_correctly()
	{
		db := this.db
		Yunit.Assert(db.status == SQLITE_OK, 'status is not OK: ' db.error)
		Yunit.Assert(db.ptr != 0, 'ptr is 0')
		Yunit.Assert(db.error == '', db.error)
		Yunit.Assert(db.path == 'test.db', 'path is not test.db')

		db := SQLite.Open('test.db', this.flags)
		Yunit.Assert(db.status == SQLITE_OK, 'status is not OK: ' db.error)
		Yunit.Assert(db.ptr != 0, 'ptr is 0')
		Yunit.Assert(db.error == '', db.error)
		Yunit.Assert(db.path == 'test.db', 'path is not test.db')
	}
	test3_database_is_closed_correctly()
	{
		db := this.db
		db.Close()
		Yunit.Assert(db.status = SQLITE_OK, 'status is not OK: ' db.error)
		Yunit.Assert(db.ptr = 0, 'ptr is not 0')
		Yunit.Assert(db.error == '', db.error)
		Yunit.Assert(db.path == '', 'path is not empty')
	}
	test4_database_is_closed_when_object_is_destroyed()
	{
		db := this.db
		Yunit.Assert(db.status = SQLITE_OK, 'status is not OK: ' db.error)
		Yunit.Assert(db.ptr != 0, 'ptr is 0')
		Yunit.Assert(db.error == '', db.error)
		Yunit.Assert(db.path == 'test.db', 'path is not test.db')
		db := ''
		try
		{
			var := db.ptr
			Yunit.Assert(false, 'an error should be thrown')
		}
		catch
			Yunit.Assert(true)
	}

	class ExecutingStatements
	{
		begin()
		{
			this.flags := SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_MEMORY
			this.db := SQLite('test.db', this.flags)
		}
		end() => SQLite3.close_v2(this.db.ptr)

		test1_create_a_new_database()
		{
			db := this.db
			db.Exec('CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT, value REAL)')
			Yunit.Assert(db.status = SQLITE_OK, 'status is not OK: ' db.error)
			Yunit.Assert(db.error == '', db.error)

			db.Close()
		}
	}
}