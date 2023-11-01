#Requires Autohotkey v2.0+ ; prefer 64-Bit
#Include <v2\Yunit\Yunit>
#Include <v2\Yunit\Window>

Yunit.Use(YunitWindow).Test(Integration_Tests, Interface_Tests)

class Integration_Tests
{
}

class Interface_Tests
{
}