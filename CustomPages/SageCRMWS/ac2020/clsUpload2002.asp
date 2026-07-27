<!-- #INCLUDE FILE="clsField.asp"-->
<script language="vbscript" runat="server">
<!--METADATA
  TYPE="TypeLib"
  NAME="Microsoft ActiveX Data Objects 2.5 Library"
  UUID="{00000205-0000-0010-8000-00AA006D2EA4}"
  VERSION="2.5"
-->

Server.ScriptTimeout=300
Dim sfilename
sfilename="dbg.txt"

Dim error
Set error = Server.GetLastError

Sub LogErrorToFile()
    Dim logFso
    Dim log

    On Error Resume Next

    Set logFso = Server.CreateObject("Scripting.FileSystemObject")
    If error.Number <> 0 Then
        Exit Sub
    End If
	
	Dim strerrPath
	strerrPath=server.mappath("logs")
	if not logFso.FolderExists(strerrPath) then
	  logFso.CreateFolder(strerrPath)
	End If	
	
    Set log = logFso.OpenTextFile(strerrPath+"\errors.txt", 8, True)
    If error.Number <> 0 Then
        Exit Sub
    End If

    log.WriteLine "URL: " & Request.ServerVariables("URL")
    log.WriteLine "File: " & error.File
    log.WriteLine "Line, col: " & error.Line & ", " & error.Column
    log.WriteLine "Description" & error.Description & vbCrLf

    log.Close
End Sub

Sub LogToFile(sfilename, msg)

	If False=False Then
       REM Exit Sub
    End If
	
    Dim logFso
    Dim log

    On Error Resume Next

    Set logFso = Server.CreateObject("Scripting.FileSystemObject")
    If error.Number <> 0 Then
        Exit Sub
    End If
	
	Dim strerrPath
	strerrPath=server.mappath("logs")
	  Response.Write (logs & strerrPath)
	if not logFso.FolderExists(strerrPath) then
	  Dim resCreateFolder
	  resCreateFolder=logFso.CreateFolder(strerrPath)
	End If	
	
    Set log = logFso.OpenTextFile(strerrPath & "\" & sfilename, 8, True)
    If error.Number <> 0 Then
        Exit Sub
    End If

    log.WriteLine  FormatDateTime(now, d) & "---" & msg
    log.Close
End Sub

' ------------------------------------------------------------------------------
'   Author:     Lewis Moten
'   Date:       March 19, 2002
' ------------------------------------------------------------------------------

' Upload class retrieves multi-part form data posted to web page
' and parses it into objects that are easy to interface with.
' Requires MDAC (ADODB) COM components found on most servers today
' Additional compenents are not necessary.
'

Class clsUpload
' ------------------------------------------------------------------------------

    Private mbinData            ' bytes visitor sent to server
    Private mlngChunkIndex      ' byte where next chunk starts
    Private mlngBytesReceived   ' length of data
    Private mstrDelimiter       ' Delimiter between multipart/form-data (43 chars)

    Private CR                  ' ANSI Carriage Return
    Private LF                  ' ANSI Line Feed
    Private CRLF                ' ANSI Carriage Return & Line Feed

    Private mobjFieldAry()      ' Array to hold field objects
    Private mlngCount           ' Number of fields parsed

' ------------------------------------------------------------------------------
    Private Sub RequestData

        Dim llngLength      ' Number of bytes received

        ' Determine number bytes visitor sent
        mlngBytesReceived = Request.TotalBytes

        ' Store bytes recieved from visitor
        mbinData = Request.BinaryRead(mlngBytesReceived)

    End Sub
' ------------------------------------------------------------------------------
    Private Sub ParseDelimiter()

        ' Delimiter seperates multiple pieces of form data
            ' "around" 43 characters in length
            ' next character afterwards is carriage return (except last line has two --)
            ' first part of delmiter is dashes followed by hex number
            ' hex number is possibly the browsers session id?

        ' Examples:

        ' -----------------------------7d230d1f940246
        ' -----------------------------7d22ee291ae0114

        mstrDelimiter = MidB(mbinData, 1, InStrB(1, mbinData, CRLF) - 1)

    End Sub
' ------------------------------------------------------------------------------
    Private Sub ParseData()

        ' This procedure loops through each section (chunk) found within the
        ' delimiters and sends them to the parse chunk routine

        Dim llngStart   ' start position of chunk data
        Dim llngLength  ' Length of chunk
        Dim llngEnd     ' Last position of chunk data
        Dim lbinChunk   ' Binary contents of chunk

        ' Initialize at first character
        llngStart = 1

        ' Find start position
        llngStart = InStrB(llngStart, mbinData, mstrDelimiter & CRLF)

        ' While the start posotion was found
        While Not llngStart = 0

            ' Find the end position (after the start position)
            llngEnd = InStrB(llngStart + 1, mbinData, mstrDelimiter) - 2

            ' Determine Length of chunk
            llngLength = llngEnd - llngStart

            ' Pull out the chunk
            lbinChunk = MidB(mbinData, llngStart, llngLength)

            ' Parse the chunk
            Call ParseChunk(lbinChunk)

            ' Look for next chunk after the start position
            llngStart = InStrB(llngStart + 1, mbinData, mstrDelimiter & CRLF)

        Wend

    End Sub
' ------------------------------------------------------------------------------
    Private Sub ParseChunk(ByRef pbinChunk)

        ' This procedure gets a chunk passed to it and parses its contents.
        ' There is a general format that the chunk follows.

        ' First, the deliminator appears

        ' Next, headers are listed on each line that define properties of the chunk.

        '   Content-Disposition: form-data: name="File1"; filename="C:\Photo.gif"
        '   Content-Type: image/gif

        ' After this, a blank line appears and is followed by the binary data.

        Dim lstrName            ' Name of field
        Dim lstrFileName        ' File name of binary data
        Dim lstrContentType     ' Content type of binary data
        Dim lbinData            ' Binary data
        Dim lstrDisposition     ' Content Disposition
        Dim lstrValue           ' Value of field

        ' Parse out the content dispostion
        lstrDisposition = ParseDisposition(pbinChunk)

            ' And Parse the Name
            lstrName = ParseName(lstrDisposition)

            ' And the file name
            lstrFileName = ParseFileName(lstrDisposition)



        ' Parse out the Content Type
        lstrContentType = ParseContentType(pbinChunk)

        ' If the content type is not defined, then assume the
        ' field is a normal form field
        If lstrContentType = "" Then

            ' Parse Binary Data as Unicode
            lstrValue = CStrU(ParseBinaryData(pbinChunk))

        ' Else assume the field is binary data
        Else

            ' Parse Binary Data
            lbinData = ParseBinaryData(pbinChunk)

        End If

        ' Add a new field
        Call AddField(lstrName, lstrFileName, lstrContentType, lstrValue, lbinData)

    End Sub
' ------------------------------------------------------------------------------
    Private Sub AddField(ByRef pstrName, ByRef pstrFileName, ByRef pstrContentType, ByRef pstrValue, ByRef pbinData)

        Dim lobjField       ' Field object class

        ' Add a new index to the field array
        ' Make certain not to destroy current fields
        ReDim Preserve mobjFieldAry(mlngCount)

        ' Create new field object
        Set lobjField = New clsField

        ' Set field properties
        lobjField.Name = pstrName
        lobjField.FilePath = pstrFileName               
		 lobjField.FileName = Mid(pstrFileName, InStrRev(pstrFileName, "\") + 1) ' <= line added to set the file name
        lobjField.ContentType = pstrContentType

        ' If field is not a binary file
        If LenB(pbinData) = 0 Then

            lobjField.BinaryData = ChrB(0)
            lobjField.Value = pstrValue
            lobjField.Length = Len(pstrValue)

        ' Else field is a binary file
        Else

            lobjField.BinaryData = pbinData
            lobjField.Length = LenB(pbinData)
            lobjField.Value = ""

        End If

        ' Set field array index to new field
        Set mobjFieldAry(mlngCount) = lobjField

        ' Incriment field count
        mlngCount = mlngCount + 1

    End Sub
' ------------------------------------------------------------------------------
    Private Function ParseBinaryData(ByRef pbinChunk)
LogToFile sfilename, "ParseBinaryData 1"
        ' Parses binary content of the chunk

        Dim llngStart   ' Start Position

        ' Find first occurence of a blank line
        llngStart = InStrB(1, pbinChunk, CRLF & CRLF)

        ' If it doesn't exist, then return nothing
        If llngStart = 0 Then Exit Function

        ' Incriment start to pass carriage returns and line feeds
        llngStart = llngStart + 4

        ' Return the last part of the chunk after the start position
        ParseBinaryData = MidB(pbinChunk, llngStart)
LogToFile sfilename, "ParseBinaryData 2"
    End Function
' ------------------------------------------------------------------------------
    Private Function ParseContentType(ByRef pbinChunk)
LogToFile sfilename, "ParseContentType 1"
        ' Parses the content type of a binary file.
        '   example: image/gif is the content type of a GIF image.

        Dim llngStart   ' Start Position
        Dim llngEnd     ' End Position
        Dim llngLength  ' Length

        ' Fid the first occurance of a line starting with Content-Type:
        llngStart = InStrB(1, pbinChunk, CRLF & CStrB("Content-Type:"), vbTextCompare)

        ' If not found, return nothing
        If llngStart = 0 Then Exit Function

        ' Find the end of the line
        llngEnd = InStrB(llngStart + 15, pbinChunk, CR)

        ' If not found, return nothing
        If llngEnd = 0 Then Exit Function

        ' Adjust start position to start after the text "Content-Type:"
        llngStart = llngStart + 15

        ' If the start position is the same or past the end, return nothing
        If llngStart >= llngEnd Then Exit Function

        ' Determine length
        llngLength = llngEnd - llngStart

        ' Pull out content type
        ' Convert to unicode
        ' Trim out whitespace
        ' Return results
        ParseContentType = Trim(CStrU(MidB(pbinChunk, llngStart, llngLength)))
LogToFile sfilename, "ParseContentType 2"
    End Function
' ------------------------------------------------------------------------------
    Private Function ParseDisposition(ByRef pbinChunk)
LogToFile sfilename, "ParseDisposition 1"
        ' Parses the content-disposition from a chunk of data
        '
        ' Example:
        '
        '   Content-Disposition: form-data: name="File1"; filename="C:\Photo.gif"
        '
        '   Would Return:
        '       form-data: name="File1"; filename="C:\Photo.gif"

        Dim llngStart   ' Start Position
        Dim llngEnd     ' End Position
        Dim llngLength  ' Length

        ' Find first occurance of a line starting with Content-Disposition:
        llngStart = InStrB(1, pbinChunk, CRLF & CStrB("Content-Disposition:"), vbTextCompare)

        ' If not found, return nothing
        If llngStart = 0 Then Exit Function

        ' Find the end of the line
        llngEnd = InStrB(llngStart + 22, pbinChunk, CRLF)

        ' If not found, return nothing
        If llngEnd = 0 Then Exit Function

        ' Adjust start position to start after the text "Content-Disposition:"
        llngStart = llngStart + 22

        ' If the start position is the same or past the end, return nothing
        If llngStart >= llngEnd Then Exit Function

        ' Determine Length
        llngLength = llngEnd - llngStart

        ' Pull out content disposition
        ' Convert to Unicode
        ' Return Results
        ParseDisposition = CStrU(MidB(pbinChunk, llngStart, llngLength))
LogToFile sfilename, "ParseDisposition 2"
    End Function
' ------------------------------------------------------------------------------
    Private Function ParseName(ByRef pstrDisposition)
	LogToFile sfilename, "ParseName 1"
        ' Parses the name of the field from the content disposition
        '
        ' Example
        '
        '   form-data: name="File1"; filename="C:\Photo.gif"
        '
        '   Would Return:
        '       File1

        Dim llngStart   ' Start Position
        Dim llngEnd     ' End Position
        Dim llngLength  ' Length

        ' Find first occurance of text name="
        llngStart = InStr(1, pstrDisposition, "name=""", vbTextCompare)

        ' If not found, return nothing
        If llngStart = 0 Then Exit Function

        ' Find the closing quote
        llngEnd = InStr(llngStart + 6, pstrDisposition, """")

        ' If not found, return nothing
        If llngEnd = 0 Then Exit Function

        ' Adjust start position to start after the text name="
        llngStart = llngStart + 6

        ' If the start position is the same or past the end, return nothing
        If llngStart >= llngEnd Then Exit Function

        ' Determine Length
        llngLength = llngEnd - llngStart

        ' Pull out field name
        ' Return results
        ParseName = Mid(pstrDisposition, llngStart, llngLength)
LogToFile sfilename, "ParseName 2"
    End Function
' ------------------------------------------------------------------------------
    Private Function ParseFileName(ByRef pstrDisposition)
	LogToFile sfilename, "ParseFileName 1"
        ' Parses the name of the field from the content disposition
        '
        ' Example
        '
        '   form-data: name="File1"; filename="C:\Photo.gif"
        '
        '   Would Return:
        '       C:\Photo.gif

        Dim llngStart   ' Start Position
        Dim llngEnd     ' End Position
        Dim llngLength  ' Length

        ' Find first occurance of text filename="
        llngStart = InStr(1, pstrDisposition, "filename=""", vbTextCompare)

        ' If not found, return nothing
        If llngStart = 0 Then Exit Function

        ' Find the closing quote
        llngEnd = InStr(llngStart + 10, pstrDisposition, """")

        ' If not found, return nothing
        If llngEnd = 0 Then Exit Function

        ' Adjust start position to start after the text filename="
        llngStart = llngStart + 10

        ' If the start position is the same of past the end, return nothing
        If llngStart >= llngEnd Then Exit Function

        ' Determine length
        llngLength = llngEnd - llngStart

        ' Pull out file name
        ' Return results
        ParseFileName = Mid(pstrDisposition, llngStart, llngLength)
	LogToFile sfilename, "ParseFileName 2"
    End Function
' ------------------------------------------------------------------------------
    Public Property Get Count()

        ' Return number of fields found
        Count = mlngCount

    End Property
' ------------------------------------------------------------------------------

    Public Default Property Get Fields(ByVal pstrName)

        Dim llngIndex   ' Index of current field

        ' If a number was passed
        If IsNumeric(pstrName) Then

            llngIndex = CLng(pstrName)

            ' If programmer requested an invalid number
            If llngIndex > mlngCount - 1 Or llngIndex < 0 Then
                ' Raise an error
                Call Err.Raise(vbObjectError + 1, "clsUpload2002.asp", "Object does not exist within the ordinal reference.")
                Exit Property
            End If

            ' Return the field class for the index specified
            Set Fields = mobjFieldAry(pstrName)

        ' Else a field name was passed
        Else

            ' convert name to lowercase
            pstrName = LCase(pstrname)

            ' Loop through each field
            For llngIndex = 0 To mlngCount - 1

                ' If name matches current fields name in lowercase
                If LCase(mobjFieldAry(llngIndex).Name) = pstrName Then

                    ' Return Field Class
                    Set Fields = mobjFieldAry(llngIndex)
                    Exit Property

                End If

            Next

        End If

        ' If matches were not found, return an empty field
        Set Fields = New clsField

'       ' ERROR ON NonExistant:
'       ' If matches were not found, raise an error of a non-existent field
'       Call Err.Raise(vbObjectError + 1, "clsUpload2002.asp", "Object does not exist within the ordinal reference.")
'       Exit Property

    End Property
' ------------------------------------------------------------------------------
    Private Sub Class_Terminate()
LogToFile sfilename, "Class_Terminate 1"
        ' This event is called when you destroy the class.
        '
        ' Example:
        '   Set objUpload = Nothing
        '
        ' Example:
        '   Response.End
        '
        ' Example:
        '   Page finnishes executing ...

        Dim llngIndex   ' Current Field Index

        ' Loop through fields
        For llngIndex = 0 To mlngCount - 1

            ' Release field object
            Set mobjFieldAry(llngIndex) = Nothing

        Next

        ' Redimension array and remove all data within
        ReDim mobjFieldAry(-1)
LogToFile sfilename, "Class_Terminate 2"
    End Sub
' ------------------------------------------------------------------------------
    Private Sub Class_Initialize()

        ' This event is called when you instantiate the class.
        '
        ' Example:
        '   Set objUpload = New clsUpload

        ' Redimension array with nothing
        ReDim mobjFieldAry(-1)

        ' Compile ANSI equivilants of carriage returns and line feeds

        CR = ChrB(Asc(vbCr))    ' vbCr      Carriage Return
        LF = ChrB(Asc(vbLf))    ' vbLf      Line Feed
        CRLF = CR & LF          ' vbCrLf    Carriage Return & Line Feed

        ' Set field count to zero
        mlngCount = 0

        ' Request data
        Call RequestData

        ' Parse out the delimiter
        Call ParseDelimiter()

        ' Parse the data
        Call ParseData

    End Sub
' ------------------------------------------------------------------------------
	Private Function CStrU(ByRef pstrANSI)

		Dim llngLength '' # Length of ANSI string
		Dim llngIndex '' # Current position
		Dim bytVal
		Dim intChar

		'' # determine length
		llngLength = LenB(pstrANSI)

		'' # Loop through each character
		llngIndex = 1
		Do While llngIndex <= llngLength

		bytVal = AscB(MidB(pstrANSI, llngIndex, 1))
		llngIndex = llngIndex + 1

		If bytVal < &h80 Then
		intChar = bytVal
		ElseIf bytVal < &hE0 Then

		intChar = (bytVal And &h1F) * &h40

		bytVal =  AscB(MidB(pstrANSI, llngIndex, 1))
		llngIndex = llngIndex + 1

		intChar = intChar + (bytVal And &h3f)

		ElseIf bytVal < &hF0 Then

		intChar = (bytVal And &hF) * &h1000

		bytVal =  AscB(MidB(pstrANSI, llngIndex, 1))
		llngIndex = llngIndex + 1

		intChar = intChar + (bytVal And &h3F) * &h40

		bytVal =  AscB(MidB(pstrANSI, llngIndex, 1))
		llngIndex = llngIndex + 1

		intChar = intChar + (bytVal And &h3F)

		Else
		intChar = &hBF
		End If

		CStrU = CStrU & ChrW(intChar)
		Loop

	End Function
	'CStrUOLD is the origional implementation
    Private Function CStrUOLD(ByRef pstrANSI)
LogToFile sfilename, "CStrUOLD 1"
        ' Converts an ANSI string to Unicode
        ' Best used for small strings

        Dim llngLength  ' Length of ANSI string
        Dim llngIndex   ' Current position

        ' determine length
        llngLength = LenB(pstrANSI)

        ' Loop through each character
        For llngIndex = 1 To llngLength

            ' Pull out ANSI character
            ' Get Ascii value of ANSI character
            ' Get Unicode Character from Ascii
            ' Append character to results
            CStrU = CStrU & Chr(AscB(MidB(pstrANSI, llngIndex, 1)))

        Next
LogToFile sfilename, "CStrUOLD 2"
    End Function
' ------------------------------------------------------------------------------
    Private Function CStrB(ByRef pstrUnicode)
		LogToFile sfilename, "CStrB 1"
        ' Converts a Unicode string to ANSI
        ' Best used for small strings

        Dim llngLength  ' Length of ANSI string
        Dim llngIndex   ' Current position

        ' determine length
        llngLength = Len(pstrUnicode)

        ' Loop through each character
        For llngIndex = 1 To llngLength

            ' Pull out Unicode character
            ' Get Ascii value of Unicode character
            ' Get ANSI Character from Ascii
            ' Append character to results
            CStrB = CStrB & ChrB(Asc(Mid(pstrUnicode, llngIndex, 1)))

        Next
		LogToFile sfilename, "CStrB 2"
    End Function
' ------------------------------------------------------------------------------
End Class
' ------------------------------------------------------------------------------

Function GetTimestampInMilliseconds()
    Dim epoch, now, milliseconds
    epoch = CDate("01/01/1970 00:00:00")
    now = Now
    milliseconds = DateDiff("s", now, epoch) * 1000 
    GetTimestampInMilliseconds = milliseconds
End Function


LogToFile sfilename, "Start of script"

Dim sInstallName
Dim objUpload 
Dim strFile, strPath, strNoFilePath
Dim commid,commAction
Dim fs
Dim strFolderName 
Dim objSrvHTTP
Dim thisUpdateUrl, thisServerName, thisPath, thisQS

commid = Request.QueryString("commid")
strFolderName = "Commid" & commid
LogToFile sfilename, "strFolderName:" & strFolderName

Dim contentType
contentType = Request.ServerVariables("CONTENT_TYPE")
sInstallName = Request.QueryString("sInstallName")

If (commid<>"") then
	Set fs = CreateObject("Scripting.FileSystemObject")
	' Instantiate Upload Class '

    
    If (contentType = "audio/wav") Then
        Dim timestamp
        timestamp = GetTimestampInMilliseconds()
        strFile = "voiceRecording_"&timestamp&".wav"
    Else 
        Set objUpload = New clsUpload
        strFile = objUpload.Fields("file").FileName
    End If

    LogToFile sfilename, "strFile:" & strFile
	strNoFilePath = server.mappath("data") & "\" & strFolderName & "\" 
	LogToFile sfilename, "strNoFilePath1:" & strNoFilePath
	strNoFilePath = Replace(LCase(strNoFilePath), "wwwroot\custompages\sagecrmws\ac2020\data", "Library\DataUpload")
	LogToFile sfilename, "strNoFilePath2:" & strNoFilePath
	strPath = strNoFilePath & strFile
    LogToFile sfilename, "strPath:" & strPath
	if not fs.FolderExists(strNoFilePath) then
      LogToFile sfilename, "CreateFolder:" & strNoFilePath	
	  fs.CreateFolder(strNoFilePath)
	  LogToFile sfilename, "CreateFolder COMPLETE"	
	End If	
	
	LogToFile sfilename, "Save the binary data to the file system:" & strPath
	' Save the binary data to the file system '

    If (contentType = "audio/wav") Then
        If Request.TotalBytes > 0 Then
            Dim inputStream
            inputStream = Request.BinaryRead(Request.TotalBytes)
            If IsObject(inputStream) Or IsArray(inputStream) Then
                
                Dim stream
                Set stream = Server.CreateObject("ADODB.Stream")
                
                If Not stream Is Nothing Then
                    stream.Type = 1 ' adTypeBinary
                    stream.Open
                    stream.Write inputStream
                    stream.SaveToFile strPath, 2 ' adSaveCreateOverWrite
                    stream.Close
                    Set stream = Nothing
                    
                    Response.Write "File uploaded successfully."

                    Response.Redirect ("/"&sInstallName&"/CustomPages/sagecrmws/ac2020/uploadupdate.asp?SID=" & Request.QueryString("SID") & "&entity="&Request.QueryString("entity")&"&Id="& Request.QueryString("Id")&"&commId="&Request.QueryString("commId")&"&fileName=" & strFile & "&filePath=" & "DataUpload\" & strFolderName) 
                Else
                    Response.Write "Error: Could not create ADODB.Stream object."
                End If
                Set stream = Nothing
            Else
                Response.Write "Error: No data was read from the request."
            End If
        Else
            Response.Write "No binary data received."
        End If
        
        Set inputStream = Nothing
    Else 
        objUpload("file").SaveAs strPath
    End If

    LogToFile sfilename, "Save COMPLETE"
	Set objUpload = Nothing
	Set fs = Nothing
	

	Response.Clear
    Response.Redirect ("/"&sInstallName&"/CustomPages/sagecrmws/ac2020/uploadupdate.asp?SID=" & Request.QueryString("SID") & "&entity="&Request.QueryString("entity")&"&id="& Request.QueryString("Id")&"&commId="&Request.QueryString("commId")&"&fileName=" & strFile & "&filePath=" & "DataUpload\" & strFolderName) 
    Response.End
   
    LogToFile sfilename, "End of script"
   
End If
</script>