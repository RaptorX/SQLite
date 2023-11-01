#Requires AutoHotkey v2.0+ ; prefer 64-Bit

class SQLite3
{
	static bin     := 'sqlite3' A_PtrSize * 8 '.dll'
	static dllPath := A_IsCompiled ? A_ScriptDir '\lib\bin' : A_LineFile '\..\..\bin'
	static ptrs    := Map()
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
}