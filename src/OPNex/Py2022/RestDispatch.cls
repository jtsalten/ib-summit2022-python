Class OPNex.Py2022.RestDispatch Extends %CSP.REST
{

// Parameter CHARSET = "iso-8859-1";

/// Directorio de imagenes por defecto
Parameter BASEIMGDIR = "/_DEMOS/ib-summit2022-python/imagenes";

Parameter CONTENTTYPE = "application/json";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/evento/info/:eventid" Method="GET" Call="GetInfo" Cors="true"/>
    <Route Url="/qr" Method="POST" Call="GeneratesQR" Cors="true"/>
    <Route Url="/simplepdf/:img/:text" Method="GET" Call="GetSimplePDF" Cors="true"/>
    <Route Url="/simplepdf" Method="GET" Call="GetSimplePDF" Cors="true"/>
    <Route Url="/dalle2/:text" Method="GET" Call="GetDalle2" Cors="true"/>
    <Route Url="/evento/ticket/:eventid" Method="GET" Call="GetTicketPDF" Cors="true"/>
    <Route Url="/evento/generaimg/:eventid" Method="GET" Call="GeneraNewImg" Cors="true"/>

    </Routes>
}

/// Devuelve información propiedades del evento con ID = pID
ClassMethod GetInfo(pID As %String) As %Status
{
    //write "TO DO - Info del evento con pID = "_pID

    
    #dim tEvento as OPNex.Py2022.Evento = ##class(OPNex.Py2022.Evento).%OpenId(pID)

    if $IsObject(tEvento)
    {
        write tEvento.Info()
    }
    else
    {
        write "El evento indicado no existe"
    }
    
    return $$$OK
}

/// Genera una imagen con un código QR que incluye link para previsualización
/// Recibe un JSON en el body con el link y si se quiere incluir o no el logo (por defecto: true)
///    {"link":"www....", "logo":true}
ClassMethod GeneratesQR() As %Status
{
    #dim %request as %CSP.Request
    #dim %response as %CSP.Response
    #dim stream as %Stream.TmpBinary = ##class(%Stream.TmpBinary).%New()
    #dim tFile as %Stream.FileBinary = ##class(%Stream.FileBinary).%New()
    #dim tLogo as %String = ..#BASEIMGDIR_"/I-IS.png" 
    #dim tTempDir as %String = ..#BASEIMGDIR

    try 
    {
        #dim tJSON as %DynamicObject = {}.%FromJSON(%request.Content.Read())
    
        set %response.ContentType = "image/jp2" 

        if '$IsObject(tJSON)
        {
            set tJSON={}
        }
        set:'tJSON.logo tLogo = ""
        
        do tFile.LinkToFile(..#BASEIMGDIR_"/QR-test.jpg")
        //do tFile.LinkToFile(##class(OPNex.Py2022.Tools).pyQR(tJSON.link, tLogo, tTempDir))
        //set tFile.RemoveOnClose = 1
        do tFile.OutputToDevice()
    }
    catch e
    {
        //debug         w e.AsStatus()
        write "Algo fue mal. Mira lo que envias en el BODY de la peticion"
    }

    return $$$OK
}

/// SimplePDF
ClassMethod GetSimplePDF(pImg As %String = "img-default.jpg", pText As %String = "Texto de Prueba") As %Status
{
    set %response.ContentType = "application/pdf"

    #dim tFile as %Stream.FileBinary = ##class(%Stream.FileBinary).%New()

    do tFile.LinkToFile(..#BASEIMGDIR_"/SimplePDF-test.pdf")
    //do tFile.LinkToFile(##class(OPNex.Py2022.Tools).pySimplePDF(pImg,pText))
    //set tFile.RemoveOnClose = 1
    do tFile.OutputToDevice()

    return $$$OK
}

/// Obtener datos del proveedor indicado
ClassMethod GetDalle2(pText As %String = "") As %Status
{
    #dim sc as %Status=$$$OK
    #dim jsonStr as %String 

    set jsonStr = ##class(OPNex.Py2022.Tools).pyDallE2(pText)

    write {}.%FromJSON(jsonStr).%ToJSON()

    Return sc
}

/// Obtiene una nueva imagen de Dalle2 para el lema del evento
ClassMethod GeneraNewImg(pID As %String) As %Status
{
    #dim tEvento as OPNex.Py2022.Evento = ##class(OPNex.Py2022.Evento).%OpenId(pID)

    if $IsObject(tEvento)
    {
        write tEvento.AsociaImgLema()
    }
    else
    {
        write "El evento indicado no existe"
    }

    return $$$OK
}

/// Genera una entrada en PDF para el evento con ID = pID
/// Obtiene información del evento y la pasa a pyPDF
ClassMethod GetTicketPDF(pID As %String = "") As %Status
{
    #dim sc as %Status = $$$OK
    #dim tEvento as OPNex.Py2022.Evento = ##class(OPNex.Py2022.Evento).%OpenId(pID)
    #dim tFile as %Stream.FileBinary = ##class(%Stream.FileBinary).%New()
 
    if $IsObject(tEvento)
    {
        set %response.ContentType = "application/pdf"
        
        set tLema = tEvento.Lema
        //Si no se indica logo, se toma el logo por defecto
        set tImgLogo = $case(tEvento.ImgLogo'="",1:tEvento.ImgLogo,:..#BASEIMGDIR_"/I-IS.png")
        //Si el evento no tiene imagen para su lema, le asocia una
        set tImgLema = $case(tEvento.ImgLema'="",1:tEvento.ImgLema,:tEvento.AsociaImgLema())
        //Genera el QR para el evento solicidado
        set tImgQR = ##class(OPNex.Py2022.Tools).pyQR(tEvento.Site,tImgLogo)

        do tFile.LinkToFile(..pyPDF(tLema, tImgLema,tImgQR,tImgLogo))
        set tFile.RemoveOnClose = 1
        do tFile.OutputToDevice()
    }
    else 
    {
        write "No existe el evento solicitado"
    }

    Return sc
}

/// Utiliza la librería reportlab para generar PDF
ClassMethod pyPDF(pLema As %String, pImgLema As %String, pImgQR As %String, pImgLogo As %String) As %Status [ Language = python ]
{
    import iris
    from reportlab.pdfgen import canvas
    from reportlab.lib.pagesizes import letter, A6, A4, A5
    #A6: w 297.6 / h 419.5  -- A5: w 419.5 / h 595.2  -- A4: w 595.2 / h 841.8

    filePath = iris.cls('OPNex.Py2022.RestDispatch')._GetParameter('BASEIMGDIR')+"/test.pdf"
    pagesize = A6
    Pwidth, Pheight = pagesize     #print('width: ',Pwidth,'  height: ',Pheight)

    c = canvas.Canvas(filePath, pagesize=pagesize, bottomup=1)

    im_lema = canvas.ImageReader(pImgLema)
    wlema, hlema = im_lema.getSize()

    im_logo = canvas.ImageReader(pImgLogo)
    wlogo, hlogo = im_logo.getSize()

    im_QR = canvas.ImageReader(pImgQR)
    wQR, hQR = im_QR.getSize()

    #Definicion Bloques - altura y ratios de imagenes

    #BLOQUE SUPERIOR (imagen - lema) - ratio anchura (queremos que la imagen ocupe todo lo ancho, de ahí se ajusta la altura)
    rAjusteLema = Pwidth/wlema 
    altBloqSup = hlema*rAjusteLema

    x0, y0 = 0, Pheight - altBloqSup
    wImgAjustada, hImgAjustada = Pwidth, altBloqSup

    w, h = c.drawImage(im_lema,x0,y0,wImgAjustada,altBloqSup)

    c.line(0,Pheight-altBloqSup,Pwidth,Pheight-altBloqSup)

    #BLOQUE MEDIO (texto - lema)
    altBloqMed = 30

    fntSize = int(altBloqMed * 2/3)  # 2/3 del ancho del bloque
    c.setFont("Helvetica",fntSize)
    x0, y0 = Pwidth/2, Pheight - altBloqSup - fntSize - int((altBloqMed-fntSize+0.5)/3)

    c.drawCentredString(x0,y0, text =pLema)

    c.line(0,Pheight-altBloqSup-altBloqMed - 1,Pwidth,Pheight-altBloqSup-altBloqMed - 1)

    #BLOQUE INFERIOR (Logo y QR) - ratio altura (queremos que las imégenes encajen en la altura de la banda intermedia, de ahí se ajusta la anchura)
    altBloqInf = Pheight - altBloqSup - altBloqMed - 2 #2 px como margen para bloque medio superior
    rAjusteQR = altBloqInf/hQR
    rAjusteLogo = altBloqInf/hlogo
    
    # -- Logo
    x0, y0 = 10, 0
    wImgAjustada, hImgAjustada = wlogo*rAjusteLogo, altBloqInf

    w3, h3 = c.drawImage(im_logo,x0,y0,wImgAjustada,hImgAjustada)
  
    # -- QR
    x0, y0 = Pwidth - wQR*rAjusteQR - 10, 0
    wImgAjustada, hImgAjustada = wQR*rAjusteQR, altBloqInf

    w2, h2 = c.drawImage(im_QR,x0,y0,wImgAjustada,hImgAjustada)
    
    c.save()

    return filePath
}

}
