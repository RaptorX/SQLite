# SQLite Wrapper for AutoHotkey

## What Is SQLite?

SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured,
SQL database engine. SQLite is the most used database engine in the world. SQLite is built into all mobile phones
and most computers and comes bundled inside countless other applications that people use every day.
[More Information](https://www.sqlite.org/about.html).

The SQLite file format is stable, cross-platform, and backwards compatible and the developers pledge to keep it that way through the year 2050. SQLite database files are commonly used as containers to transfer rich content between systems and as a long-term archival format for data. There are over 1 trillion (1e12) SQLite databases in active use.

SQLite source code is in the public-domain and is free to everyone to use for any purpose.

## The Wrapper Interface

This is interface exposes the methods that can be used in your script.

The methods exposed are few but allow you to do the most common tasks that you can do with `SQLite`.

It is very similar to the original library that it wraps but will differ in certain key aspects mainly for ease of use in the AutoHotkey language.

## Opening/Creating a database file

The SQLite interface takes in 2 parameters:

- The file name of the database to open
- The permission flags that will be used to open the database.

By default a blank database will be created if the specified file name doesnt exist. \
You have full control of this behavior by specifying the flags like this though:

```autoit
db := SQLite('test.db', SQLITE_OPEN_READONLY)
```

You must include at least 1 of the following flag combinations:

- `SQLITE_OPEN_READONLY`
- `SQLITE_OPEN_READWRITE`
- `SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE`

If you dont specify any it defaults to `SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE`.

It returns a database connection instance which means you can have multiple connections at a time:

```autoit
db1 := SQLite('test1.db', SQLITE_OPEN_READONLY)
db2 := SQLite('test2.db')

```

### Advanced Examples

You can use the `db := SQLite.Open(filename, flags)` syntax if you so prefer.

```autoit
flags := SQLITE_OPEN_READWRITE | SQLITE_OPEN_DELETEONCLOSE | SQLITE_OPEN_FULLMUTEX
db3 := SQLite.Open('test3.db', flags)
```

## Executing statements

For this you will use the `Exec` method and use any valid SQLite statements like so:

```autoit
db := SQLite() ; this creates a temporary file that will be deleted on close
db.Exec('BEGIN TRANSACTION;')
db.Exec('CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT, value REAL)')
loop 20
	db.Exec('INSERT INTO test VALUES(' A_Index ', "name' A_Index '", "value' A_Index '");')
db.Exec('COMMIT TRANSACTION;')
table := db.Exec('SELECT * FROM test')
msgbox table.count
```

The `Exec` function is special in the sense that if you use a `SELECT` statement it returns a special Table object.
But if you dont, the function will return the last status code.

You can also check the status code by looking at `this.status` and you can get an english version of the code by
checking `this.error`.

## Data Tables

When you use the `SELECT` statement you get a special object that allows you to do some interesting things.

### Getting data

You can get data out of a table in many ways. The most important properties are:

- count - how many rows of data you got
- headers - an array of the current headers
- rows - an array of rows

After a `SELECT` query you might want to check the count before doing anything else.
Continuing the example above you can do the following:

```autoit
if table.count
	msgbox table.count ' rows found'
```

You can inspect the data by looping through it too.

```autoit
for row in table.rows
	names .= row.name '`n' ; "name" is the column which we setup on the example above

msgbox names

; or

for row in table.rows
{
	for header, value in row
		data .= header ' = ' value ', ' ; rows can be looped over as well

	data .= '`n'
}

msgbox data
```

Sometimes you know exactly what you want and you dont need to loop. In that case you can use this syntax:

```autoit
msgbox table[2, 'value'] ; where the first parameter is the row number and the second is the column name
```

If at any point you need to know the current header/column names, you can just loop over the `Table.headers` array
to get the sorted header/column names.

```autoit
for header in table.headers
	msgbox header
```

You can get a whole row by doing this as well:

```autoit
row := table[5] ; gets the 5th row as an object
```

### Working with rows

Rows are special because they contain not only the values/fields of a row but also the header/column information
which makes them very useful on their own.

```autoit
row := table[5] ; gets the 5th row as an object

msgbox row.name ; access the value stored on the name column of this particular row
```

If you want to know the row number (in the order that SQLite returned it) you can use the special property `_number_`

```autoit
msgbox row._number_ ; returns 5 in this example
```

### Manipulating data

You can modify your copy of the data in memory by updating the values in your rows like this:

```autoit
row.name := 'new name' ; modifies the value on the 'name' column on row 5
```

### Warning

Be careful with this manipulation though. When you get a row using the `Table[n]` command you get a reference to that
row.

That means that your variable is `linked` to the table object. This is a very interesting concept because you can do
something like this:

```autoit
row := table[5]

msgbox table[5, 'name'] ; returns 'name5'

row.name := 'new name'  ; modifying a reference to row 5

msgbox table[5, 'name'] ; returns 'new name'!
```

This might be surprising at first but it is pretty handy when you later want to update your actual database information.
If you **DONT** want this behavior make sure you clone the row instead of just assigning it.

```autoit
row := table[5].Clone() ; creates a shallow copy of the object. In other words not linked.

msgbox table[5, 'name'] ; returns 'name5'

row.name := 'new name'  ; modifying a reference to row 5

msgbox table[5, 'name'] ; returns 'name5' still!
```

You can update information inside the table without creating a variable too.

```autoit
table[5, 'name'] := 'new name' ; this is valid too
```

You can modify and play with the table data all you want without affecting your real database. Later you might want
to loop over your table object and create SQL syntax to update your actual database.

## Closing the database

You can close the database using the `Close` method or by simply clearing the variable.

```autoit
db.Close()

; or

db := ''
```

## New functionality

For now this is just a basic object and I plan on adding more functionality down the line.

A few ideas are:

- Have a `Save` method to the Table object to seamlessly update data to the database file once modified in code.
- `Export` functionality to quicly save your table results into other desired formats like CSV/TSV.
