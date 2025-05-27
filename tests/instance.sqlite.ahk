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
		test2_get_results_from_a_table()
		{
			static statement :=
			(Join;
				'CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT, value REAL)
				INSERT INTO test (name, value) VALUES ("test1", 1.0),("test2", 2.0),("test3", 3.0)
				SELECT * FROM test'
			)

			db := this.db
			table := db.Exec(statement)
			Yunit.Assert(db.status = SQLITE_OK, 'status is not OK: ' db.error)
			Yunit.Assert(db.error == '', db.error)
			Yunit.Assert(table.count = 3, 'table.count is not 3')

			db.Close()
		}

		test3_inserting_many_rows_of_data_into_a_table()
		{
			db := SQLite() ; this creates a temporary file that will be deleted on close
			db.Exec('BEGIN TRANSACTION;')
			db.Exec('CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT, value REAL)')
			loop 20
				db.Exec('INSERT INTO test VALUES(' A_Index ', "name' A_Index '", "value' A_Index '");')
			db.Exec('COMMIT TRANSACTION;')
			table := db.Exec('SELECT * FROM test')
			Yunit.Assert(table.count, 'table.count is not 20')
		}
	}

	class TableTests
	{
		begin()
		{
			static statement :=
			(Join;
				'CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT, value REAL)
				INSERT INTO test (name, value) VALUES ("value1", 1.0),("value2", 2.0),("value3", 3.0)
				SELECT * FROM test'
			)
			this.flags := SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_MEMORY
			this.db := SQLite('test.db', this.flags)
			this.table := this.db.Exec(statement)
			Yunit.Assert(this.db.status = SQLITE_OK, 'status is not OK: ' this.db.error)
		}
		end() => SQLite3.close_v2(this.db.ptr)

		test1_table_is_properly_setup()
		{
			db := this.db
			table := this.table
			properties := [
				'parent',
				'count',
				'headers',
				'rows'
			]

			for property in properties
				Yunit.Assert(table.HasOwnProp(property), property ' was not initialized')

			tests := Map(
				'table is not a SQLite3.table' , table is SQLite3.table,
				'table.parent is not db'       , table.parent == db,
				'table.name is empty'          , table.name != '',
				'table.headers is not an Array', table.headers is Array,
				'table.headers.Length is not 3', table.headers.Length = 3,
				'table.count is not 3'         , table.count = 3,
				'table.rows SQLite3.Table.Row' , table.rows is SQLite3.Table.Rows,
				'table.rows.Count is not 3'    , table.rows.Length = 3,
			)

			for error, test in tests
				Yunit.Assert(test, error)
		}
		test2_table_information_can_be_accessed_without_looping()
		{
			table := this.table

			loop table.count
			{
				Yunit.Assert(
					table[A_Index, 'name'] = 'value' A_Index ,
					'table[' A_Index ', "name"] is not "value' A_Index '"'
				)
				Yunit.Assert(
					table[A_Index, 'value'] = Float(A_Index),
					'table[' A_Index ', "value"] is not ' Float(A_Index)
				)
			}
		}
		test3_table_information_can_be_set_without_looping()
		{
			table := this.table

			table[1, 'name']   := 'new name'
			table[1, 'value1'] := 99.99

			Yunit.Assert(table[1, 'name'] = 'new name', 'table[1, "name"] is not "new name"')
			Yunit.Assert(table[1, 'value1'] = 99.99, 'table[1, "value1"] is not 99.99')

			row := table[1]

			Yunit.Assert(row.name = 'new name', 'row.name is not "new name"')
			Yunit.Assert(row.value1 = 99.99, 'row.value1 is not 99.99')
		}
		test4_get_row_by_specifying_row_number()
		{
			table := this.table

			row := table[1]

			Yunit.Assert(row is SQLite3.Table.Row, 'row is not a SQLite3.Table.Row')
			Yunit.Assert(row.rowid = 1, 'row.rowid is not 1')
		}
		test5_table_information_can_be_looped_with_the_for_loop()
		{
			table := this.table

			for row in table.rows
			{
				Yunit.Assert(row is SQLite3.Table.Row, 'row is not a SQLite3.Table.Row')
				Yunit.Assert(row.rowid = A_Index, 'row.rowid is not ' A_Index)
			}
		}
	}

	class RowTests
	{
		begin()
		{
			static statement :=
			(Join;
				'CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT, value REAL)
				INSERT INTO test (name, value) VALUES ("value1", 1.0),("value2", 2.0),("value3", 3.0)
				SELECT * FROM test'
			)
			this.flags := SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_MEMORY
			this.db := SQLite('test.db', this.flags)
			this.table := this.db.Exec(statement)
			Yunit.Assert(this.db.status = SQLITE_OK, 'status is not OK: ' this.db.error)
		}
		end() => SQLite3.close_v2(this.db.ptr)

		test1_row_is_properly_setup()
		{
			table := this.table
			row := table[1]

			properties := ['rowid']

			for property in properties
				Yunit.Assert(row.HasOwnProp(property), property ' was not initialized')

			tests := Map(
				'row is not a SQLite3.Table.Row'    , row is SQLite3.Table.Row,
				'row.rowid is not 1'                , row.rowid = 1,
				'row doesnt have the header "id"'   , row.Has('id'),
				'row doesnt have the header "name"' , row.Has('name'),
				'row doesnt have the header "value"', row.Has('value'),
				'row "id" is not 1'                 , row['id'] == 1,
				'row "name" is not "value1"'        , row['name'] == 'value1',
				'row "value" is not 1.0'            , row['value'] == 1.0,
			)

			for error, test in tests
				Yunit.Assert(test, error)
		}
		test2_row_information_can_be_accessed_without_looping()
		{
			table := this.table
			row := table[1]

			Yunit.Assert(row.id = 1             , 'row.id is not 1')
			Yunit.Assert(row.name == 'value1'   , 'row.name is not "value1"')
			Yunit.Assert(row.value = 1.0        , 'row.value is not 1.0')
			Yunit.Assert(row['id'] = 1          , 'row.id is not 1')
			Yunit.Assert(row['name'] == 'value1', 'row.name is not "value1"')
			Yunit.Assert(row['value'] = 1.0     , 'row.value is not 1.0')
		}
		test3_row_information_can_be_set_and_affects_table_data()
		{
			table := this.table
			row := table[1]

			row.id    := 99
			row.name  := 'new name'
			row.value := 99.99

			row := table[1]
			Yunit.Assert(row.id = 99, 'row.id is not 99')
			Yunit.Assert(row.name == 'new name', 'row.name is not "new name"')
			Yunit.Assert(row.value = 99.99, 'row.value is not 99.99')
		}
		test4_row_can_be_cloned_and_modified_without_affecting_table_data()
		{
			table := this.table
			row := table[1].Clone()

			row.id    := 99
			row.name  := 'new name'
			row.value := 99.99

			row := table[1]
			Yunit.Assert(row.id != 99, 'row.id is 99 but it shouldn`'t be')
			Yunit.Assert(row.name !== 'new name', 'row.name is "new name" but it shouldn`'t be')
			Yunit.Assert(row.value != 99.99, 'row.value is 99.99 but it shouldn`'t be')
		}
		test5_row_can_be_looped_with_a_for_loop()
		{
			table := this.table
			row := table[1]

			for header, value in row
			{
				Yunit.Assert(header ==  table.headers[A_Index], 'header is not ' table.headers[A_Index])
				Yunit.Assert(row[header] == value, 'value is not ' value)
			}
		}
	}
}