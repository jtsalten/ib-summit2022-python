Class OPNex.Py2022.Direccion Extends (%SerialObject, %JSON.Adaptor, %Populate)
{

Property Ciudad As %String(MAXLEN = "");

Property Pais As %String(MAXLEN = "");

Storage Default
{
<Data name="DireccionState">
<Value name="1">
<Value>Ciudad</Value>
</Value>
<Value name="2">
<Value>Pais</Value>
</Value>
</Data>
<State>DireccionState</State>
<StreamLocation>^OPNex.Py2022.DireccionS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
