#Requires AutoHotkey v2.0+ ; prefer 64-Bit

#Include .\..\headers\sqlite3.h.ahk

class SQLite3
{
	static bin     := 'sqlite3' A_PtrSize * 8 '.dll'
	static dllPath := A_IsCompiled ? A_ScriptDir '\lib\bin' : A_LineFile '\..\..\bin'
	static ptrs    := Map()
	static hModule := 0

	static valueErrorTemplate := 'Expected a {1} but received a {2}'

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

	static sourceid() => StrGet(DllCall(SQLite3.bin '\sqlite3_sourceid', 'ptr'), 'utf-8')
	static libversion() => StrGet(DllCall(SQLite3.bin '\sqlite3_libversion', 'ptr'), 'utf-8')
	static libversion_number() => DllCall(SQLite3.bin '\sqlite3_libversion_number', 'int')

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

	static check_params(params)
	{
		if (t:=Type(params)) != 'Array'
			throw ValueError(Format(SQLite3.valueErrorTemplate, 'Array', t), A_ThisFunc, 'params')

		for param in params
		{
			if (t:=Type(param.value)) != param.type
			{
				errmsg := Format(SQLite3.valueErrorTemplate, param.type, t)
				throw ValueError(errmsg, A_ThisFunc, param.name)
			}
		}
	}
}