#Requires Autohotkey v2.0+ ; prefer 64-Bit

#Include .\lib\interfaces\SQLite3.ahk

class SQLite extends SQLite3
{
	ptr := 0
	path := ''
	error := ''
	status {
		get => this._status
		set {
			if (value != SQLITE_OK)
				this.error := SQLite3.errstr(value)

			return this._status := value
		}

	}

	/**
	 * @description Opens a connection to an SQLite database file.
	 * - [Documentation](https://www.sqlite.org/c3ref/open.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method Open
	 * @memberof SQLite
	 *
	 * ---
	 * #### Parameters
	 * @param {string} filename The name of the database file to open.
	 * @param {number} [flags=SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE] The flags to use when opening the database file.
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if the wrong type is passed for any of the parameters.
	 * @throws {OSError}    if unable to allocate memory for the `sqlite3` object.
	 *
	 * ----
	 * #### Returns
	 * @returns {SQLite} A new SQLite object representing the opened database connection.
	 *
	 * ---
	 * #### Notes
	 * A database connection handle is usually returned in `&pSqlite`, even if an error occurs.
	 * The only exception is that if `sqlite3` is unable to allocate memory to hold the `sqlite3` object,
	 * a `NULL` will be written into `&pSqlite` instead of a pointer to the `sqlite3` object.
	 *
	 * If the database is opened (and/or created) successfully, then `SQLITE_OK` is returned.
	 * Otherwise an error code is returned.
	 *
	 * ---
	 * #### Accepted Flags
	 * You can use one ore more flags by combining them using the bitwise OR operator
	 * e.g. `SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE`
	 *
	 * - `SQLITE_OPEN_READWRITE`
	 * - `SQLITE_OPEN_READONLY`
	 * - `SQLITE_OPEN_CREATE`
	 * - `SQLITE_OPEN_DELETEONCLOSE`
	 * - `SQLITE_OPEN_EXCLUSIVE`
	 * - `SQLITE_OPEN_AUTOPROXY`
	 * - `SQLITE_OPEN_URI`
	 * - `SQLITE_OPEN_MEMORY`
	 * - `SQLITE_OPEN_MAIN_DB`
	 * - `SQLITE_OPEN_TEMP_DB`
	 * - `SQLITE_OPEN_TRANSIENT_DB`
	 * - `SQLITE_OPEN_MAIN_JOURNAL`
	 * - `SQLITE_OPEN_TEMP_JOURNAL`
	 * - `SQLITE_OPEN_SUBJOURNAL`
	 * - `SQLITE_OPEN_SUPER_JOURNAL`
	 * - `SQLITE_OPEN_NOMUTEX`
	 * - `SQLITE_OPEN_FULLMUTEX`
	 * - `SQLITE_OPEN_SHAREDCACHE`
	 * - `SQLITE_OPEN_PRIVATECACHE`
	 * - `SQLITE_OPEN_WAL`
	 * - `SQLITE_OPEN_NOFOLLOW`
	 * - `SQLITE_OPEN_EXRESCODE`
	 * - `SQLITE_OPEN_MASTER_JOURNAL`
	 */
	static Open(filename, flags?) => SQLite(filename, flags?)

	/**
	 * @description Opens a connection to an SQLite database file.
	 * - [Documentation](https://www.sqlite.org/c3ref/open.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method Open
	 * @memberof SQLite
	 *
	 * ---
	 * #### Parameters
	 * @param {string} filename The name of the database file to open.
	 * @param {number} [flags=SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE] The flags to use when opening the database file.
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if the wrong type is passed for any of the parameters.
	 * @throws {OSError}    if unable to allocate memory for the `sqlite3` object.
	 *
	 * ----
	 * #### Returns
	 * @returns {SQLite} A new SQLite object representing the opened database connection.
	 *
	 * ---
	 * #### Notes
	 * A database connection handle is usually returned in `&pSqlite`, even if an error occurs.
	 * The only exception is that if `sqlite3` is unable to allocate memory to hold the `sqlite3` object,
	 * a `NULL` will be written into `&pSqlite` instead of a pointer to the `sqlite3` object.
	 *
	 * If the database is opened (and/or created) successfully, then `SQLITE_OK` is returned.
	 * Otherwise an error code is returned.
	 *
	 * ---
	 * #### Accepted Flags
	 * You can use one ore more flags by combining them using the bitwise OR operator
	 * e.g. `SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE`
	 *
	 * - `SQLITE_OPEN_READWRITE`
	 * - `SQLITE_OPEN_READONLY`
	 * - `SQLITE_OPEN_CREATE`
	 * - `SQLITE_OPEN_DELETEONCLOSE`
	 * - `SQLITE_OPEN_EXCLUSIVE`
	 * - `SQLITE_OPEN_AUTOPROXY`
	 * - `SQLITE_OPEN_URI`
	 * - `SQLITE_OPEN_MEMORY`
	 * - `SQLITE_OPEN_MAIN_DB`
	 * - `SQLITE_OPEN_TEMP_DB`
	 * - `SQLITE_OPEN_TRANSIENT_DB`
	 * - `SQLITE_OPEN_MAIN_JOURNAL`
	 * - `SQLITE_OPEN_TEMP_JOURNAL`
	 * - `SQLITE_OPEN_SUBJOURNAL`
	 * - `SQLITE_OPEN_SUPER_JOURNAL`
	 * - `SQLITE_OPEN_NOMUTEX`
	 * - `SQLITE_OPEN_FULLMUTEX`
	 * - `SQLITE_OPEN_SHAREDCACHE`
	 * - `SQLITE_OPEN_PRIVATECACHE`
	 * - `SQLITE_OPEN_WAL`
	 * - `SQLITE_OPEN_NOFOLLOW`
	 * - `SQLITE_OPEN_EXRESCODE`
	 * - `SQLITE_OPEN_MASTER_JOURNAL`
	 */
	__New(filename, flags?)
	{
		flags := flags ?? SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
		this.status := SQLite3.open_v2(filename, &pDB, flags)

		if (this.status != SQLITE_OK)
			SQLite3.close_v2(pDB)

		this.ptr := pDB
		this.path := filename
		return this
	}

}