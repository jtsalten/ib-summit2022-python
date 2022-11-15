Class OPNex.Py2022.Tools Extends %Library.RegisteredObject
{

Parameter BASEIMGDIR = "/_DEMOS/ib-summit2022-python/imagenes";

/// Genera código QR con pData indicado - almacena el QR en un fichero y retorna el path 
ClassMethod pyQR(pData As %String = "", pLogo As %String = "", pTargetDir As %String = "") As %String [ Language = python ]
{
    imgFilePath = "/_DEMOS/ib-summit2022-python/imagenes/QR-test.jpg"

    # Generación QR
    '''
    import qrcode
    from qrcode.image.styledpil import StyledPilImage
    import random as rnd
    # Genera un archivo de nombre aleatorio con prefijo ibs2022-qr-    
    imgFilePath = pTargetDir+"/"+"ibs2022-qr-"+str(rnd.randint(999,99999))+'.jpg'

    qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_H, 
                        box_size = 10, version = 2, border = 4,
                        image_factory = StyledPilImage)
    
    qr.add_data(pData)

    img = qr.make_image(embeded_image_path=pLogo)

    img.save(imgFilePath)
    '''

    return imgFilePath
}

/// Simple PDF using Python reportlab module
ClassMethod pySimplePDF(pImgFile As %String = "img-default.jpg", pTexto As %String = "Texto de Prueba") As %String [ Language = python ]
{
    pdffile = "/_DEMOS/ib-summit2022-python/imagenes/SimplePDF-test.pdf"

    #Generación PDF
    '''
    import iris
    from reportlab.pdfgen import canvas
    from reportlab.lib.pagesizes import letter, A6, A4, A5
    pagesize = A4
    width, height = pagesize

    basedir = iris.cls(__name__)._GetParameter('BASEIMGDIR')
    imgFile = basedir + '/' + pImgFile
    pdfFile = basedir + '/SimplePDF.pdf'

    c = canvas.Canvas(pdfFile, pagesize=pagesize, bottomup=1)

    w, h = c.drawImage(imgFile,200,height-300,256,256)

    c.line(150,height-350,width-150,height-350)

    c.drawString(250,height - 400, text=pTexto)

    c.save()
    '''
    
    return pdfFile
}

/// Llama al api DallE2 para generación de imágenes
/// Requiere crear una cuenta previamente (50 llamadas free el primer mes)
/// Asume las variables de entorno: OPENAI_ORG y OPENAI_API_KEY con la organización y una key asociada a la cuenta (se genera en el portal de openai)
/// pNum - numero de imagenes a generar (¡¡OJO!! - se cobra por imagen)
/// pSize - tamaño de las imagenes - 1024x1024 / 512x512 / 256x256
/// Devuelve un string que representa un objeto JSON: 
///      {"imagenes":["url1","url2",...]}
ClassMethod pyDallE2(pText As %String = "", pNum As %SmallInt = 1, pSize As %String = "256x256") As %String [ Language = python ]
{
    import os
    import json
    import openai

    openai.organization = os.getenv("OPENAI_ORGANIZATION")
    openai.api_key = os.getenv("OPENAI_API_KEY")

    ''' 
    response contendrá una propiedad data con una lista de objetos con la propiedad url
        <OpenAIObject at 0x21c53d5fdb0> JSON: {
            "created": 1667571619,
            "data": [
                {
                    "url": "https://oaidalle......."
                }
            ]
        }
    '''
    response = openai.Image.create(prompt=pText, n=pNum, size=pSize)

    lista = [img['url'] for img in response.data]
    res_dic = dict(imagenes = lista)

    return json.dumps(res_dic)
}

ClassMethod Reset()
{
    do ##class(OPNex.Py2022.Evento).%KillExtent()
}

ClassMethod GeneraTest()
{
    #dim tEvento as OPNex.Py2022.Evento = ##class(OPNex.Py2022.Evento).%New()

    set tEvento.Site = "www.intersystems.com"
    set tEvento.Empresa = "InterSystems"
    set tEvento.Lema = "Python is the milk"
    set tEvento.ImgLema = "/_DEMOS/ib-summit2022-python/imagenes/img-default.jpg"
    set tEvento.ImgLogo = "/_DEMOS/ib-summit2022-python/imagenes/I-IS.png"
    set tEvento.Ubicacion.Ciudad = "Valencia"
    set tEvento.Ubicacion.Pais = "España"

    #dim tSC as %Status = tEvento.%Save()

    return tSC
}

}
