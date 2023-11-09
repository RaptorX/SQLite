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
}