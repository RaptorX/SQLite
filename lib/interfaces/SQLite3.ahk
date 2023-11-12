#Requires AutoHotkey v2.0+ ; prefer 64-Bit

#Include .\..\headers\sqlite3.h.ahk

/**
 * @description This class provides an interface for working with `SQLite3` databases.
 * - [Documentation](https://www.sqlite.org/docs.html).
 *
 * ---
 * #### Properties
 * @static @prop {string}  {@link SQLite3.bin SQLite3.bin}         - name of the DLL by bitness
 * @static @prop {string}  {@link SQLite3.dllPath SQLite3.dllPath} - path to the `SQLite3` DLL
 * @static @prop {Map}     {@link SQLite3.ptrs SQLite3.ptrs}       - map of pointers to `SQLite3` functions
 * @static @prop {pointer} {@link SQLite3.hModule SQLite3.hModule} - handle to the loaded `SQLite3` module
 *
 * ---
 * #### Methods
 * @method {@link SQLite.sourceid          sourceid}          - returns the source ID
 * @method {@link SQLite.libversion        libversion}        - returns the version
 * @method {@link SQLite.libversion_number libversion_number} - returns the version number
 * @method {@link SQLite.open_v2           open_v2}           - opens a connection
 * @method {@link SQLite.close_v2          close_v2}          - closes a connection
 * @method {@link SQLite.exec              exec}              - executes a SQL statement
 * @method {@link SQLite.get_table         get_table}         - returns a table from a SQL query
 * @method {@link SQLite.errstr            errstr}            - converts a result code to a string
 * @method {@link SQLite.errmsg            errmsg}            - returns the last error message
 * @method {@link SQLite.errcode           errcode}           - returns the last error code
 * @method {@link SQLite.extended_errcode  extended_errcode}  - returns the last extended error code
 * @method {@link SQLite.free              free}              - frees memory allocated by `SQLite3`
 * @method {@link SQLite.free_table        free_table}        - frees memory allocated for a table
 * @method {@link SQLite.check_params      check_params}      - checks the parameters of a function
 *
 * ----
 * #### Child Classes
 * @class Table - {@link SQLite3.Table SQLite3.Table}
 *
 * ---
 * #### Notes
 * - This class is a work in progress
 * - This class copies the `SQLite3` DLL to the `lib\bin` folder if it does not exist and automatically loads the module
 */
class SQLite3
{
	/** @prop {string} bin Name of the DLL by bitness */
	static bin     := 'sqlite3' A_PtrSize * 8 '.dll'

	/** @prop {string} dllPath Path to the `SQLite3` DLL */
	static dllPath := A_IsCompiled ? A_ScriptDir '\lib\bin' : A_LineFile '\..\..\bin'

	/** @prop {Map} ptrs Map of pointers to `SQLite3` functions */
	static ptrs    := Map()

	/** @prop {pointer} hModule - Handle to the loaded `SQLite3` module */
	static hModule := 0

	static __New()
	{
		if SQLite3.hModule
			return

		if A_IsCompiled
		&& !FileExist(SQLite3.dllPath '\' SQLite3.bin)
		{
			DirCreate SQLite3.dllPath
			FileInstall A_LineFile '\..\..\bin\sqlite332.dll', SQLite3.dllPath, true
			FileInstall A_LineFile '\..\..\bin\sqlite364.dll', SQLite3.dllPath, true
		}
		SQLite3.dllPath .= '\' SQLite3.bin

		if !SQLite3.hModule := DllCall('LoadLibrary', 'str', SQLite3.dllPath, 'ptr')
			throw OSError(A_LastError, A_ThisFunc, 'LoadLibrary')
	}

	/**
	 * @description Returns the source ID of the `SQLite3` library
	 * - [Documentation](https://www.sqlite.org/c3ref/c_source_id.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method sourceid
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * `NONE`
	 *
	 * ----
	 * #### Returns
	 * @returns {string} returns the source ID of the `SQLite3` library
	 *
	 * ---
	 * #### Notes
	 * These method provides the same information as `SQLITE_SOURCE_ID` C preprocessor macro
	 * but is associated with the library instead of the header file. Cautious programmers might include
	 * `assert()` statements in their application to verify that values returned by these interfaces match the
	 * macros in the header, and thus ensure that the application is compiled with matching library and
	 * header files.
	 *
	 * #### Example
	 * ```
	 * assert( SQLite3.sourceid() == SQLITE_SOURCE_ID );
	 * ```
	 */
	static sourceid() => StrGet(DllCall(SQLite3.bin '\sqlite3_sourceid', 'ptr'), 'utf-8')

	/**
	 * @description Returns the library version string of the `SQLite3` library
	 * - [Documentation](https://www.sqlite.org/c3ref/c_source_id.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method libversion
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * `NONE`
	 *
	 * ----
	 * #### Returns
	 * @returns {string} returns the library version string of the `SQLite3` library
	 *
	 * ---
	 * #### Notes
	 * These method provides the same information as `SQLITE_VERSION` C preprocessor macro
	 * but is associated with the library instead of the header file. Cautious programmers might include
	 * `assert()` statements in their application to verify that values returned by these interfaces match the
	 * macros in the header, and thus ensure that the application is compiled with matching library and
	 * header files.
	 *
	 * #### Example
	 * ```
	 * assert( SQLite3.libversion() == SQLITE_VERSION );
	 * ```
	 */
	static libversion() => StrGet(DllCall(SQLite3.bin '\sqlite3_libversion', 'ptr'), 'utf-8')

	/**
	 * @description Returns the version number of the `SQLite3` library
	 * - [Documentation](https://www.sqlite.org/c3ref/c_source_id.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method libversion_number
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * `NONE`
	 *
	 * ----
	 * #### Returns
	 * @returns {integer} returns the version number of the `SQLite3` library
	 *
	 * ---
	 * #### Notes
	 * These method provides the same information as `SQLITE_VERSION_NUMBER` C preprocessor macro
	 * but is associated with the library instead of the header file. Cautious programmers might include
	 * `assert()` statements in their application to verify that values returned by these interfaces match the
	 * macros in the header, and thus ensure that the application is compiled with matching library and
	 * header files.
	 *
	 * #### Example
	 * ```
	 * assert( SQLite3.libversion_number() == SQLITE_VERSION_NUMBER );
	 * ```
	 */
	static libversion_number() => DllCall(SQLite3.bin '\sqlite3_libversion_number', 'int')

	/**
	 * @description Opens a new database connection and saves the `sqlite3` object pointer in the
	 * given variable reference. By default, if the database file does not exist, it will be created.
	 * - [Documentation](https://www.sqlite.org/c3ref/open.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method open_v2
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * @param {string}  filename utf-8 string for the database file to be opened or created
	 * @param {VarRef}  pSqlite  receives the pointer to the `sqlite3` object
	 * @param {integer} [flags]  open flags (default: `SQLITE_OPEN_READWRITE` | `SQLITE_OPEN_CREATE`)
	 * @param {NONE}    [zVfs]   vfs module pointer to use - **(not implemented yet)**
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if zVfs is not `0` - **(not implemented yet).**
	 * @throws {ValueError} if the wrong type is passed for any of the parameters.
	 * @throws {OSError}    if unable to allocate memory for the `sqlite3` object.
	 *
	 * ----
	 * #### Returns
	 * @returns {integer} `sqlite3` result code
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
	static open_v2(filename, &pSqlite, flags?, zVfs?)
	{
		if IsSet(zVfs)
			throw ValueError('VFS modules are not implemented yet', A_ThisFunc, 'zVfs')

		flags := flags ?? SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE

		params := [
			{name: 'filename', type: 'String', value: filename},
			{name: 'pSqlite', type: 'Integer', value: pSqlite:=0},
			{name: 'flags', type: 'Integer', value: flags}
		]
		SQLite3.check_params(params)

		; using StrPtr doesnt work
		; we need to make sure the string is utf-8 before passing it to sqlite
		fName := Buffer(StrPut(filename, 'utf-8'))
		StrPut(filename, fName, 'utf-8')

		res := DllCall(SQLite3.bin '\sqlite3_open_v2',
			'ptr' , fName,        ; Database filename (UTF-8)
			'ptr*', &pSqlite:=0,  ; OUT: SQLite db handle
			'int' , flags,        ; Flags
			'ptr' , 0,            ; Name of VFS module to use NOT IMPLEMENTED
			'int')

		if !pSqlite
			throw OSError('Unable to allocate memory for the SQLite Object', A_ThisFunc)

		SQLite3.ptrs.Set(pSqlite, true)
		return res
	}

	/**
	 * @description Closes a database connection.
	 * - [Documentation](https://www.sqlite.org/c3ref/close.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method close_v2
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * @param {pointer} pSqlite the pointer to the `sqlite3` object
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if the wrong type is passed for the parameter.
	 *
	 * ----
	 * #### Returns
	 * @returns {integer} `sqlite3` result code
	 *
	 * ---
	 * #### Notes
	 * If this method is called with unfinalized prepared statements, unclosed `BLOB` handlers, and/or unfinished
	 * `sqlite3_backups`, it returns `SQLITE_OK` regardless, but instead of deallocating the database connection
	 * immediately, it marks the database connection as an unusable "zombie" and makes arrangements
	 * to automatically deallocate the database connection after all prepared statements are finalized,
	 * all `BLOB` handles are closed, and all backups have finished.
	 */
	static close_v2(pSqlite)
	{
		SQLite3.check_params([{name: 'pSqlite', type: 'Integer', value: pSqlite}])
		try SQLite3.ptrs.Delete(pSqlite)
		return DllCall(SQLite3.bin '\sqlite3_close_v2', 'ptr', pSqlite)
	}

	/**
	 * @description Executes SQL commands provided by an input string.
	 * - [Documentation](https://www.sqlite.org/c3ref/exec.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method exec
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * @param {pointer} pSqlite   the pointer to the `sqlite3` object
	 * @param {string}  statement the SQL statement to be executed
	 * @param {pointer} errmsg    pointer to an error message
	 * @param {NONE}    callback  callback function          - **(not implemented yet)**
	 * @param {NONE}    pArg      first argument to callback - **(not implemented yet)**
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if `callback` or `pArg` are provided - **(not implemented yet)**
	 * @throws {ValueError} if the wrong type is passed for any of the parameters.
	 *
	 * ----
	 * #### Returns
	 * @returns {integer} `sqlite3` result code
	 *
	 * ---
	 * #### Notes
	 * If an error occurs while evaluating the SQL statements passed in `statement`, then execution of the current
	 * statement stops and subsequent statements are skipped.
	 *
	 * If `errmsg` is not `NULL` then the error message is written into a memory pointer obtained from `sqlite3`
	 * and passed back through the `errmsg` parameter.
	 *
	 * You must ensure to use `StrGet(errmsg, 'utf-8')` to convert the error message to a string.
	 */
	static exec(pSqlite, statement, &errmsg, callback?, pArg?)
	{
		if IsSet(callback) || IsSet(pArg)
			throw ValueError('Callbacks are not implemented yet', A_ThisFunc, 'callback|pArg')

		params := [
			{name: 'pSqlite', type: 'Integer', value: pSqlite},
			{name: 'statement', type: 'String', value: statement}
		]
		SQLite3.check_params(params)

		sql := Buffer(StrPut(statement, 'utf-8'))
		StrPut(statement, sql, 'utf-8')

		res := DllCall(SQLite3.bin '\sqlite3_exec',
			'ptr', pSqlite,      ; An open database
			'ptr', sql,          ; SQL to be evaluated
			'ptr', 0,            ; Callback function        NOT IMPLEMENTED
			'ptr', 0,            ; 1st argument to callback NOT IMPLEMENTED
			'ptr*', &errmsg:=0, ; Error msg written here
			'int')
		return res
	}

	/**
	 * @description Executes an SQL statement that would contain rows of data and returns the result.
	 *
	 * *This is a legacy interface that is preserved for backwards compatibility.
	 * Use of this interface is not recommended.*
	 * - [Documentation](https://www.sqlite.org/c3ref/free_table.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method get_table
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * @param {pointer} pSqlite    the pointer to the `sqlite3` object
	 * @param {string}  statement  the SQL statement to be executed
	 * @param {VarRef}  result     receives a pointer to the result of the query
	 * @param {VarRef}  nrow       receives the number of result rows
	 * @param {VarRef}  ncol       receives the number of result columns
	 * @param {VarRef}  errmsg     receives a pointer to an error message
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if the wrong type is passed for any of the parameters.
	 *
	 * ----
	 * #### Returns
	 * @returns {integer} `sqlite3` result code
	 *
	 * ---
	 * #### Notes
	 * A result table is an array of pointers to zero-terminated utf-8 strings.
	 * The first group of pointers point to zero-terminated strings that contain the names of the columns.
	 * The remaining entries all point to query results. `NULL` values result in `NULL` pointers.
	 *
	 * A result table might consist of one or more memory allocations. It is **not safe** to pass a result table
	 * directly to `SQLite3.free`. A result table **should be** deallocated using `SQLite3.free_table`.
	 */
	static get_table(pSqlite, statement, &result, &nrow, &ncol, &errmsg)
	{
		params := [
			{name: 'pSqlite', type: 'Integer', value: pSqlite},
			{name: 'statement', type: 'String', value: statement}
		]
		SQLite3.check_params(params)

		sql := Buffer(StrPut(statement, 'utf-8'))
		StrPut(statement, sql, 'utf-8')

		res := DllCall(SQLite3.bin '\sqlite3_get_table',
			'ptr' , pSqlite,    ; An open database
			'ptr' , sql,        ; SQL to be evaluated
			'ptr*', &result:=0, ; Results of the query
			'int*', &nrow:=0,   ; Number of result rows written here
			'int*', &ncol:=0,   ; Number of result columns written here
			'ptr*', &errMsg:=0, ; Error msg written here
			'int')
		return res
	}

	/**
	 * @description Returns a string that describes an error code.
	 * - [Documentation](https://www.sqlite.org/c3ref/errcode.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method errstr
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * @param {integer} resCode the `sqlite3` result code
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if the wrong type is passed for the parameter.
	 *
	 * ----
	 * #### Returns
	 * @returns {string} the error message string.
	 *
	 * ---
	 * #### Notes
	 * This method is used to get a human-readable string that describes a specific `sqlite3` result code.
	 * Memory to hold the error message string is managed internally and must not be freed by the application.
	 */
	static errstr(resCode)
	{
		SQLite3.check_params([{name: 'resCode', type: 'Integer', value: resCode}])
		return StrGet(DllCall(SQLite3.bin '\sqlite3_errstr', 'int', resCode, 'ptr'), 'utf-8')
	}

	/**
	 * @description Returns the most recent error message associated with a database connection.
	 * - [Documentation](https://www.sqlite.org/c3ref/errcode.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method errmsg
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * @param {pointer} pSqlite the pointer to the `sqlite3` object
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if the wrong type is passed for the parameter.
	 *
	 * ----
	 * #### Returns
	 * @returns {string} the error message string.
	 *
	 * ---
	 * #### Notes
	 * Memory to hold the error message string is managed internally. The application does not need to worry about
	 * freeing the result. However, the error string might be overwritten or deallocated by subsequent calls to
	 * other SQLite interface functions.
	 */
	static errmsg(pSqlite)
	{
		SQLite3.check_params([{name: 'pSqlite', type: 'Integer', value: pSqlite}])
		return StrGet(DllCall(SQLite3.bin '\sqlite3_errmsg', 'ptr', pSqlite, 'ptr'), 'utf-8')
	}

	/**
	 * @description Returns the error code for the most recent SQLite API call associated with a database
	 * connection.
	 * - [Documentation](https://www.sqlite.org/c3ref/errcode.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method errcode
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * @param {integer} pSqlite the pointer to the `sqlite3` object
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if the wrong type is passed for the parameter.
	 *
	 * ----
	 * #### Returns
	 * @returns {integer} the `sqlite3` result code.
	 *
	 * ---
	 * #### Notes
	 * If the most recent API call associated with database connection failed, then the `SQLite3.errcode` interface
	 * returns the numeric result code or extended result code for that API call.
	 *
	 * The values returned by `SQLite3.errcode` might change with each API call. Except, there are some interfaces
	 * that are guaranteed to never change the value of the error code.
	 */
	static errcode(pSqlite)
	{
		SQLite3.check_params([{name: 'pSqlite', type: 'Integer', value: pSqlite}])
		return DllCall(SQLite3.bin '\sqlite3_errcode', 'ptr', pSqlite, 'int')
	}

	/**
	 * @description Returns the extended result code for the most recent SQLite API call associated with a database
	 * connection.
	 * - [Documentation](https://www.sqlite.org/c3ref/errcode.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method extended_errcode
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * @param {integer} pSqlite the pointer to the `sqlite3` object
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if the wrong type is passed for the parameter.
	 *
	 * ----
	 * #### Returns
	 * @returns {integer} the SQLite extended result code.
	 *
	 * ---
	 * #### Notes
	 * If the most recent API call associated with database connection failed,
	 * then the `SQLite3.extended_errcode` interface returns the numeric result code or extended result code
	 * for that API call.
	 *
	 * The values returned by `SQLite3.errcode` might change with each API call. Except, there are some interfaces
	 * that are guaranteed to never change the value of the error code.
	 */
	static extended_errcode(pSqlite)
	{
		SQLite3.check_params([{name: 'pSqlite', type: 'Integer', value: pSqlite}])
		return DllCall(SQLite3.bin '\sqlite3_extended_errcode', 'ptr', pSqlite, 'int')
	}

	; not tested
	/**
	 * @description Frees memory that was allocated by SQLite.
	 * - [Documentation](https://www.sqlite.org/c3ref/free.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method free
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * @param {pointer} strPtr  The pointer to the memory block
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} If the wrong type is passed for the parameter.
	 *
	 * ----
	 * #### Returns
	 * @returns {void} This method does not return a value.
	 *
	 * ---
	 * #### Notes
	 * Passing a `NULL` pointer to `SQLite3.free` is harmless. After being freed, memory should neither be read
	 * nor written. Even reading previously freed memory might result in a segmentation fault or other
	 * severe error.
	 *
	 * Memory corruption, a segmentation fault, or other severe error might result if `SQLite3.free` is called
	 * with a non-`NULL` pointer that was not obtained from a `sqlite3` memory allocation method.
	 */
	static free(strPtr)
	{
		SQLite3.check_params([{name: 'strPtr', type: 'Integer', value: strPtr}])
		DllCall(SQLite3.bin '\sqlite3_free', 'ptr', strPtr)
	}

	/**
	 * @description Frees the memory that was allocated by for a result table.
	 * - [Documentation](https://www.sqlite.org/c3ref/free_table.html)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method free_table
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * @param {pointer} tablePtr the pointer to the memory block
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if the wrong type is passed for the parameter.
	 *
	 * ----
	 * #### Returns
	 * @returns {void} this method does not return a value.
	 *
	 * ---
	 * #### Notes
	 * After the application has finished with the result from `SQLite3.get_table`, it must pass the result table
	 * pointer to this function in order to release the memory that was allocated.
	 *
	 * Because of the way the `SQLite3.malloc` happens within `SQLite3.get_table`, the calling function must
	 * not try to call `SQLite3.free` directly. Only `SQLite3.free_table` is able to release the memory
	 * properly and safely.
	 */
	static free_table(tablePtr)
	{
		SQLite3.check_params([{name: 'tablePtr', type: 'Integer', value: tablePtr}])
		DllCall(SQLite3.bin '\sqlite3_free_table', 'ptr', tablePtr)
	}

	/**
	 * @description Checks the types of the parameters passed to a function.
	 * - [Documentation](https://www.autohotkey.com/docs/v2/lib/Type.htm)
	 *
	 * ---
	 * #### Method Info
	 * @static
	 * @method check_params
	 * @memberof SQLite3
	 *
	 * ---
	 * #### Parameters
	 * @param {array} params an array of objects, each containing a `name`, `value` and `type` properties
	 *
	 * ---
	 * #### Error Handling
	 * @throws {ValueError} if the type of a parameter does not match the expected type.
	 *
	 * ----
	 * #### Returns
	 * @returns {void} this method does not return a value.
	 *
	 * ---
	 * #### Notes
	 * This method is used to check the types of the parameters passed to a function.
	 * If the type of a parameter does not match the expected type, a `ValueError` is thrown.
	 */
	static check_params(params)
	{
		static valueErrorTemplate := 'Expected a {1} for {2} but received a {3}'

		if (t:=Type(params)) != 'Array'
			throw ValueError(Format(valueErrorTemplate, 'Array', t), A_ThisFunc, 'params')

		for param in params
		{
			; we might set a blank string in the array to indicate
			; ignoring a particular parameter. e.g. the parameter was not set.
			if param is String
			|| (t:=Type(param.value)) == param.type
				continue

			errmsg := Format(valueErrorTemplate, param.type, param.name, t)
			throw ValueError(errmsg, A_ThisFunc, param.name)
		}
	}

	/**
	 * @description Represents a table in an `SQLite3` database.
	 *
	 * ---
	 * #### Properties
	 * @prop {string}  name    {@link SQLite.Table.name    SQLite.Table.name}    - The name of the SQLite table
	 * @prop {SQLite}  parent  {@link SQLite.Table.parent  SQLite.Table.parent}  - The instance that owns the table
	 * @prop {integer} count   {@link SQLite.Table.count   SQLite.Table.count}   - The number of rows in the table
	 * @prop {array}   headers {@link SQLite.Table.headers SQLite.Table.headers} - The column headers of the table
	 * @prop {array}   rows    {@link SQLite.Table.rows    SQLite.Table.rows}    - List of `SQLite3.Table.Row`
	 *
	 * ---
	 * #### Methods
	 * @method __New  - Creates a new instance of a `SQLite3.Table`.
	 * @method __Item - Allows Getting or setting a row or field/cell value using bracket syntax.
	 *
	 * ---
	 * #### Child Classes
	 * @class Row - Represents a row in an `SQLite3.Table`.
	 */
	class Table
	{

		/** @prop {string} name The name of the SQLite table */
		name    := ''

		/** @prop {SQLite} parent The instance that owns the table */
		parent  := 0

		/** @prop {integer} count The number of rows in the table */
		count   := 0

		/** @prop {array} headers The column headers of the table */
		headers := []

		/** @prop {array} rows List of SQLite3.Table.Row objects */
		rows    := []

		/**
		 * @description Creates a new instance of a `SQLite3.Table`.
		 * ---
		 * #### Method Info
		 * @static
		 * @method
		 * @memberof SQLite3
		 *
		 * ---
		 * #### Parameters
		 * @param {SQLite}  db        - The database object.
		 * @param {string}  statement - The SQL statement.
		 * @param {pointer} pTable    - A pointer to the table.
		 * @param {integer} nRows     - The number of rows in the table.
		 * @param {integer} nCols     - The number of columns in the table.
		 *
		 * ---
		 * #### Error Handling
		 * @throws {ValueError} If any of the parameters are invalid.
		 *
		 * ----
		 * #### Returns
		 * @returns {SQLite3.Table} A new instance of the `SQLite3.Table`.
		 *
		 * ---
		 * #### Notes
		 * - The `name` property of the instance is set to the name of the table in the SQL statement.
		 * - The `headers` property of the instance is an array of column names.
		 * - The `rows` property of the instance is an array of row objects.
		 */
		__New(db, statement, pTable, nRows, nCols)
		{
			params := [
				{name: 'db', type: 'SQLite', value: db},
				{name: 'statement', type: 'String', value: statement},
				{name: 'pTable', type: 'Integer', value: pTable},
				{name: 'nRows', type: 'Integer', value: nRows},
				{name: 'nCols', type: 'Integer', value: nCols}
			]
			SQLite3.check_params(params)

			RegExMatch(statement, 'im)from\s+(?<name>.*?)(\s|$)', &matched)
			this.parent := db
			this.count := nRows
			this.name := matched['name']

			row    := 0
			fields := []
			OffSet := 0 - A_PtrSize
			loop (nRows+1) * nCols
			{
				nxtPtr:=NumGet(pTable, OffSet += A_PtrSize, 'ptr')
				data := nxtPtr ? StrGet(nxtPtr, 'UTF-8') : '' ; We need to handle NULL data

				if A_Index <= nCols
					this.headers.Push(data)
				else
				{
					fields.Push(data)
					if Mod(A_Index, nCols)
						continue

					this.rows.Push(SQLite.Table.Row(++row, this.headers, fields))
					fields := []
				}
			}

			SQLite3.free_table(pTable)
			return this
		}

		__Item[row, header?]
		{
			get
			{
				params := [
					{name: 'row', type: 'Integer', value: row},
					!IsSet(header) ? '' : {name: 'header', type: 'String', value: header}
				]
				SQLite3.check_params(params)

				if IsSet(header)
					return this.rows[row].%header%
				else
					return this.rows[row]
			}
			set => this.rows[row].%header% := value
		}


		/**
		 * @description Represents a row in a `SQLite.Table`
		 *
		 * ---
		 * #### Properties
		 * @prop {array}    data     The fields/cells in the row
		 * @prop {integer}  _number_ The row number
		 * @prop {integer}  count    Returns the number of fields/cells in the row
		 *
		 * ---
		 * #### Methods
		 * @method __Enum Enumerates the fields in the row
		 * @method __New  Initializes a new instance of the Row class
		 * @method __Get  Gets the value of a field in the row
		 *
		 */
		class Row
		{

			/** @prop {array} data The fields/cells in the row */
			data     := []

			/** @prop {integer} _number_ The row number */
			_number_ := 0

			/** @prop {integer} count Returns the number of fields/cells in the row */
			count {
				get => this.data.Length
			}

			__Enum(nVars)
			{
				return fields

				fields(&hdr, &val)
				{
					static pos := 0
					if pos = this.data.Length
						return pos := false

					field := this.data[pos += 1]
					hdr := field.header

					; always get the current value
					val := this.%field.header%
				}
			}

			__New(rNum, headers, data)
			{
				this._number_ := rNum
				for header in headers
					this.data.Push({header:header, value:data[A_Index]})

				return this
			}

			__Get(Key, Params)
			{
				for item in this.data
					if item.header = Key
						return item.value

				return ''
			}
		}
	}
}