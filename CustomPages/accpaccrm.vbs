<%@@LANGUAGE=VBSCRIPT %>
<%
	' This is the ACCPAC CRM standard include file for vb script based asp pages
	' using the ACCPAC CRM business object.

	' This file should be included on the first line of your asp file.
	' You should set the codepage of your asp pages to 65001, utf-8

	' Please consult the ACCPAC CRM documentation for more information.
	
	' Pages expire right away

	Response.Expires=-1

	' ACCPAC CRM mode constants

	Dim View,Edit, Save, PreDelete, PostDelete

	View=0
        Edit=1
        Save=2
        PreDelete=3
        PostDelete=4

	' ACCPAC CRM button position constants

	Dim Bottom, Left, Right, Top
	Bottom=0
        Left=1
        Right=2
        Top=3

	' ACCPAC CRM caption location constants

	Dim CapDefault, CapTop, CapLeft, CapLeftAligned, CapRight, CapRightAligned, CapLeftAlignedRight
	
	CapDefault=0
        CapTop=1
        CapLeft=2
        CapLeftAligned=3
        CapRight=4
        CapRightAligned=5
        CapLeftAlignedRight=6

	' determine is this is a wap page
	
	Dim Accept
        Set Accept = Request.ServerVariables("HTTP_ACCEPT")
        Accept=CStr(Accept)
        
        Dim IsWap
        IsWap = (InStr(Accept,"wml")<>0)

	Dim Button_Default, Button_Delete, Button_Continue

	Button_Default="1"
        Button_Delete="2"
        Button_Continue="4"

	Dim iKey_CustomEntity
        iKey_CustomEntity = 58

	' create and initialise the ACCPAC CRM object
        Dim eWare
	Dim CRM
        Dim sInstallName
        Dim ClassName
        sInstallName = getInstallName(Request.ServerVariables("URL"))
        ClassName = "eWare."+sInstallName


        Set CRM = Server.CreateObject(ClassName)

	Set eWare = CRM
	eMsg = CRM.Init(Request.Querystring,Request.Form,Request.ServerVariables("HTTPS"),Request.ServerVariables("SERVER_NAME"),false,Request.ServerVariables("HTTP_USER_AGENT"),Accept)
		
	' check for errors
		
	If (eMsg<>"") Then
	  Response.Write(eMsg)
	  Response.End
	End If
	
	' start the page

	Dim Body,EndBody,Head
	
	If (IsWap) Then
	
		Response.ContentType = "text/vnd.wap.wml"
		Head="<?xml version=""1.0""?><!DOCTYPE wml PUBLIC ""-'WAPFORUM'DTD WML 1.1'EN"" ""http:'www.wapforum.org/DTD/wml_1.1.xml""><wml>"
		Body="<card id=""s"">"

		EndBody="</card></wml>"
	
	Else	
		Head="<HTML><HEAD><LINK REL=""stylesheet"" HREF=""/ewarebase/eware.css""><META http-equiv=""Content-Type"" content=""text/html; charset=utf-8"">"
		Body="</HEAD><BODY>"
		EndBody="</BODY></HTML>"
	End If
	
	' this function is quite useful
	
	Function Defined(Arg)	
	  Defined = (Arg+""<>"undefined")
	End Function

	Function getInstallName(sPath)
		'Parse the install name out of the path
		Dim Path
		Dim InstallName
		Dim iEndChar
		InstallName = ""
		iEndChar=0
		iStartChar=0

		Path = LCase(sPath)
		iEndChar = InStr(Path,"/custompages")
		If iEndChar <> -1 Then
			'find the first '/' before this
			sPath=Mid(Path,1,iEndChar-1)
                                          If Mid(sPath,1,1)="/" Then sPath=Mid(sPath,2)
			InstallName=sPath

		End If
		getInstallName= Installname

	End Function

%>