#SingleInstance
#Requires AutoHotkey v2.0+ ; prefer 64-Bit

#Include <v2\Yunit\Yunit>
#Include <v2\Yunit\Window>

Yunit.Use(YunitWindow).Test(tSqlite)

class tSqlite
{
}