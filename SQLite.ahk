#Requires Autohotkey v2.0+ ; prefer 64-Bit

#Include .\lib\interfaces\SQLite3.ahk

/**
 * @description Main interface for the `SQLite` AutoHotkey wrapper class. Represents a `SQLite` database connection.
 *
 * ---
 * @version v0.2.0
 * @author  RaptorX
 * @email   graptorx@gmail.com
 *
 * ---
 * #### Properties
 * @prop {pointer}  ptr    Pointer to the `SQLite` database connection
 * @prop {string}   path   Path to the `SQLite` database file
 * @prop {string}   error  Last error message
 * @prop {integer}  status Last status code
 *
 * ---
 * #### Methods
 * @method {@link SQLite.Open  Open}  Opens a connection to a `SQLite` database file
 * @method {@link SQLite.Close Close} Closes the database connection
 * @method {@link SQLite.Exec  Exec}  Executes SQL commands provided by an input string
 */
class SQLite extends SQLite3 {

	/** @type {pointer} */
	ptr := 0

	/** @type {string} */
	path := ''

	/** @type {string} */
	error := ''

	/** @type {integer} */
	status {
		get => this._status
		set {
			if (value != SQLITE_OK)
				this.error := SQLite3.errstr(value)

			return this._status := value
		}

	}

	/**
	 * @description Opens a connection to an `SQLite` database file.
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
	 * @param {number} [flags]  The flags to use when opening the database file. (see below)
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if the wrong type is passed for any of the parameters.
	 * @throws {OSError}    if unable to allocate memory for the `SQLite` object.
	 *
	 * ----
	 * #### Returns
	 * @returns {SQLite} A new `SQLite` object representing the opened database connection.
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
	 * There are some special database that can be created:
	 * - `:memory:` - an in-memory database that only exists for the duration of the session
	 * - `""`        - an empty string creates a temporary, anonymous disk file
	 *
	 * Both are used by specifying them as the filename parameter.
	 * - [Documentation](https://www.sqlite.org/inmemorydb.html)
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
	static Open(filename?, flags?) => SQLite(filename?, flags?)

	/**
	 * @description Opens a connection to an `SQLite` database file.
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
	 * @param {number} [flags]  The flags to use when opening the database file. (see below)
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} If the wrong type is passed for any of the parameters.
	 * @throws {OSError}    If unable to allocate memory for the `SQLite` object.
	 *
	 * ----
	 * #### Returns
	 * @returns {SQLite} A new `SQLite` object representing the opened database connection.
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
	 * There are some special database that can be created:
	 * - `""`        - an empty string creates a temporary, anonymous disk file
	 * - `:memory:` - an in-memory database that only exists for the duration of the session
	 *
	 * Both are used by specifying them as the filename parameter.
	 * - [Documentation](https://www.sqlite.org/inmemorydb.html)
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
	__New(filename?, flags?) {
		; creates a temporary file database
		filename := filename ?? ''

		; opens or creates a database with read/write access
		flags := flags ?? SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE

		this.status := SQLite3.open_v2(filename, &pDB, flags)

		if (this.status != SQLITE_OK)
			SQLite3.close_v2(pDB)

		this.ptr := pDB
		this.path := filename
		return this
	}

	__Delete() => SQLite3.close_v2(this.ptr)

	/**
	 * @description Closes the database connection.
	 * - [Documentation](https://www.sqlite.org/c3ref/close.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method Close
	 * @memberof SQLite
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} If the wrong type is passed for the parameter.
	 *
	 * ----
	 * #### Returns
	 * @returns {integer} `SQLITE_OK`.
	 *
	 * ---
	 * #### Notes
	 * If this method is called with unfinalized prepared statements, unclosed `BLOB` handlers, and/or unfinished
	 * backups, it returns `SQLITE_OK` **regardless**, but instead of deallocating the database connection
	 * immediately, it marks the database connection as an unusable "zombie" and makes arrangements
	 * to automatically deallocate the database connection after all prepared statements are finalized,
	 * all `BLOB` handles are closed, and all backups have finished.
	 */
	Close() {
		SQLite3.close_v2(this.ptr)
		this.path := ''
		this.ptr := 0
		return this.status := SQLITE_OK
	}

	/**
	 * @description Executes SQL commands provided by an input string.
	 * - [Documentation](https://www.sqlite.org/c3ref/exec.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method Exec
	 * @memberof SQLite
	 *
	 * ---
	 * #### Parameters
	 * @param {string} statement The SQL statement to be executed
	 * @param {string} args*     Optional arguments to be replaced in the SQL statement if placholders exist.
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} If the wrong type is passed
	 *
	 * ----
	 * #### Returns
	 * @returns {integer|SQLite3.Table} `sqlite` result code or a `SQLite3.Table` object
	 *                                  if using a `SELECT` statement.
	 *
	 * ---
	 * #### Notes
	 * If an error occurs while evaluating the SQL statements passed in `statement`, then execution of the current
	 * statement stops and subsequent statements are skipped.
	 *
	 * `this.status` is set to the appropriate error code and `this.error` is set to contain the error message.
	 */
	Exec(statement, args*) {
		fixed_statement := Format(statement, args*)

		if isTable := CreatesTable(fixed_statement)
			res := SQLite3.get_table(this.ptr, fixed_statement, &pTable, &rows, &cols, &errMsg)
		else
			res := SQLite3.exec(this.ptr, fixed_statement, &errMsg)
		
		if errMsg || res != SQLITE_OK {
			this.status := res
			this.error .= ": " StrGet(errMsg, "utf-8")
			SQLite3.free(errMsg)
		}

		return !isTable ? res : SQLite3.Table(this, fixed_statement, pTable, rows, cols)

		CreatesTable(sql) {
			sql := Sanitise(sql)

			; Match EXPLAIN (optional), WITH-CTE (optional), then SELECT|PRAGMA
			if RegExMatch(
				sql,
				"i)(^|;)(?:EXPLAIN\s+(?:QUERY\s+PLAN\s+)?)?(?:WITH(?:\s+RECURSIVE)?\s+\w+\s+AS\s*\([^)]*\)\s*)*(SELECT|PRAGMA)\b"
			)
				return true

			; RETURNING turns DML into a result-set generator (SQLite ≥ 3.35) :contentReference[oaicite:2]{index=2}
			if RegExMatch(sql, "i)(^|;)(INSERT|UPDATE|DELETE)\b.*\bRETURNING\b")
				return true

			return false

			Sanitise(sql) {
				sql := Trim(sql)                           ; strip whitespace  :contentReference[oaicite:0]{index=0}
				; yanked-from-PostgreSQL style: removes block- and line-comments
				sql := RegExReplace(
					sql,
					"s)^(?:/\*.*?\*/\s*|--[^\n]*\R\s*)*"   ; leading comments, any amount
				)

				return RegExReplace(
					sql,
					"s)'(?:''|[^'])*'|`"(?:\`"\`"|[^`"])*`""
				)  ; ^ multi-line so .* spans newlines
			
			}
		}
	}
	static Escape(orig_str)
	{
		fixed_str := RegExReplace(orig_str, "'+", "''")
		fixed_str := RegExReplace(fixed_str, '"+', '""')
		return fixed_str
	}

	static UnEscape(orig_str)
	{
		fixed_str := StrReplace(orig_str, "'+", "'")
		fixed_str := StrReplace(fixed_str, '"+', '"')
		return fixed_str
	}
}
