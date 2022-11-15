Class OPNex.Py2022.Evento Extends (%Persistent, %JSON.Adaptor, %Populate)
{

/// Directorio de imagenes por defecto
Parameter BASEIMGDIR = "/_DEMOS/ib-summit2022-python/imagenes";

/// URL a la página de información del evento
Property Site As %String(MAXLEN = "") [ Required ];

/// Nombre de la empresa
Property Empresa As %String(MAXLEN = "");

/// Frase breve (en inglés) con el lema del evento
Property Lema As %String(MAXLEN = "") [ Required ];

/// Path a un archivo con la imagen escogida para el Lema del evento
Property ImgLema As %String(MAXLEN = "");

/// Path a archivo con la imagen del logo de la compañia
Property ImgLogo As %String(MAXLEN = "");

/// Descripcion de la campaña
Property Descripcion As %String(MAXLEN = "");

/// Ciudad y pais del evento
Property Ubicacion As OPNex.Py2022.Direccion;

/// Obtiene una nueva imagen de Dall-e2 para el lema del evento
Method AsociaImgLema() As %String [ Language = python ]
{
    import iris
    import json, random as rnd
    from PIL import Image
    from urllib.request import urlopen

    # pyDallE2 devuelve un doc JSON: {'imagenes':['url1','url2',...]} - puede devolver varias. Para el caso cogeremos sólo la primera
    jsonStr = iris.cls('OPNex.Py2022.Tools').pyDallE2(self.Lema)
    # convervitmos a dict
    urls = json.loads(jsonStr)

    file = self._GetParameter("BASEIMGDIR")+"/LEMA-auto-"+self.Lema.replace(" ","-")[0:10]+str(rnd.randint(999,99999))+".png"
    
    # de las posibles urls con imágenes, nos quedamos con la primera
    im = Image.open(urlopen(urls['imagenes'][0]))

    im.save(file)

    self.ImgLema = file
    self._Save()

    return file
}

/// Regenera la imagen asociada al lema del evento
ClassMethod RegeneraImgLema(pID As %String) As %String
{
    set tEvento = ..%OpenId(pID)
    if $IsObject(tEvento)
    {
        return tEvento.AsociaImgLema()
    }

    return 0
}

Storage Default
{
<Data name="EventoDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Site</Value>
</Value>
<Value name="3">
<Value>Empresa</Value>
</Value>
<Value name="4">
<Value>Lema</Value>
</Value>
<Value name="5">
<Value>ImgLema</Value>
</Value>
<Value name="6">
<Value>ImgLogo</Value>
</Value>
<Value name="7">
<Value>Descripcion</Value>
</Value>
<Value name="8">
<Value>Ubicacion</Value>
</Value>
</Data>
<DataLocation>^OPNex.Py2022.EventoD</DataLocation>
<DefaultData>EventoDefaultData</DefaultData>
<IdLocation>^OPNex.Py2022.EventoD</IdLocation>
<IndexLocation>^OPNex.Py2022.EventoI</IndexLocation>
<StreamLocation>^OPNex.Py2022.EventoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
