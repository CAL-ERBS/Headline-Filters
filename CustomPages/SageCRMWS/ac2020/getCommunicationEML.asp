<!-- #include file ="sagecrm.js" -->
<% Response.CodePage = 65001 %>
<% Response.CharSet = "UTF-8" %>
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<%
//////////////////////////////////////////////
//SageCRMWS\ac2020\getCommunicationEML.asp
//////////////////////////////////////////////
function createEMLWithAttachment(commid,subject,from,to,cc,body,htmlbody) {   
    // EML content with attachment
    var emlContent = "From: " + from + "\r\n" +
                     "To: " + to + "\r\n" +
					 "CC: " + cc + "\r\n" +
                     "Subject: " + subject + "\r\n" +
                     "MIME-Version: 1.0\r\n" +
                     "Content-Type: multipart/mixed; boundary=\"boundary123\"\r\n" +
					 "\r\n--boundary123\r\n"+
					 "Content-Type: multipart/alternative; boundary=\"boundary456\""+
                     "\r\n" +
					 "\r\n--boundary456\r\n" +
                     "Content-Type: text/plain; charset=UTF-8\r\n" +
                     "Content-Transfer-Encoding: base64\\r\n" +
                     "\r\n" + (body) + "\r\n" +
                     "\r\n" +
                     "--boundary456\r\n" +
                     "Content-Type: text/html; charset=UTF-8\r\n" +
                     "Content-Transfer-Encoding: base64\\r\n" +
                     "\r\n" + (htmlbody) + "\r\n\r\n--boundary456--\r\n";
                   
	//attachments?
    var libatt=CRM.CreateQueryObj("select Libr_FilePath, Libr_FileName from vlibrary where Libr_FileName<>'email.html' and libr_communicationid="+commid);
	libatt.SelectSQL();
	var email_html="";
	while(!libatt.eof)
	{
		var _fullpath=getLibraryRootPath()+libatt("Libr_FilePath")+"\\"+libatt("Libr_FileName");
		var base64Attachment=readFileAndEncodeBase64(_fullpath);
		emlContent+="\r\n--boundary123\r\n" +
                     "Content-Type: "+getContentType(libatt("Libr_FileName"))+"; name=\"" + libatt("Libr_FileName") + "\"\r\n" +
                     "Content-Transfer-Encoding: base64\r\n" +
                     "Content-Disposition: attachment; filename=\"" + libatt("Libr_FileName") + "\"\r\n" +
                     "\r\n" +
                     base64Attachment + "\r\n";
		libatt.NextRecord();
	}
	//close it
	emlContent+="\r\n--boundary123--\r\n";
    // Write the content to the response
	Response.clear();
    Response.ContentType = "message/rfc822";
    Response.AddHeader("Content-Disposition", "inline; filename=email_"+commid+".eml");

    Response.Write(emlContent);
    Response.End();
}
function readFileAndEncodeBase64(filePath) {
    var base64Encoded = "";
    try {
        // Create the ADODB.Stream object for reading binary files
        var stream = new ActiveXObject("ADODB.Stream");
        stream.Type = 1; // 1 = adTypeBinary
        stream.Open();
        stream.LoadFromFile(filePath);

        // Read the binary data and convert it to Base64
        var xml = new ActiveXObject("MSXML2.DOMDocument.3.0");
        var element = xml.createElement("base64");
        element.dataType = "bin.base64";
        element.nodeTypedValue = stream.Read();
        base64Encoded = element.text.replace(/\r\n/g, '');

        // Clean up
        stream.Close();
    } catch (e) {
        base64Encoded = "Error: " + e.message;
    }

    return base64Encoded;
}
function readFile(fname) {
    var stream = new ActiveXObject("ADODB.Stream");
    stream.Type = 2; // adTypeText
    stream.Charset = "utf-8";
    stream.Open();
    stream.LoadFromFile(fname);

    var content = stream.ReadText(-1); // Read entire file
    stream.Close();
    stream = null;

    // Strip UTF-8 BOM if present
    if (content.charCodeAt(0) === 0xFEFF || content.charCodeAt(0) === 65279) {
        content = content.substring(1);
    }

    return content;
}

function getContentType(filePath) {
    // Extract the file extension
    var fileExtension = filePath.substring(filePath.lastIndexOf('.') + 1).toLowerCase();

    // Map file extensions to MIME types
    var mimeTypes = {
        "txt": "text/plain",
        "html": "text/html",
        "htm": "text/html",
        "css": "text/css",
        "js": "application/javascript",
        "json": "application/json",
        "xml": "application/xml",
        "jpg": "image/jpeg",
        "jpeg": "image/jpeg",
        "png": "image/png",
        "gif": "image/gif",
        "bmp": "image/bmp",
        "pdf": "application/pdf",
        "zip": "application/zip",
        "rar": "application/x-rar-compressed",
        "mp3": "audio/mpeg",
        "wav": "audio/wav",
        "mp4": "video/mp4",
        "avi": "video/x-msvideo",
        "doc": "application/msword",
        "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "xls": "application/vnd.ms-excel",
        "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "ppt": "application/vnd.ms-powerpoint",
        "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    };

    // Return the MIME type based on the file extension, default to 'application/octet-stream'
    return mimeTypes[fileExtension] || "application/octet-stream";
}

// Example usage
var filePath = "C:\\path\\to\\your\\file.pdf";  // Example file path
var contentType = getContentType(filePath);

// Output the MIME type in the response
Response.ContentType = "text/plain";
Response.Write("MIME Type: " + contentType);

var commid=new String(Request.QueryString('id'));

if (!isNumeric(commid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, commid is "+Request.Form('id'));
  throw "No valid commid found";
}

var entity=new String(Request.QueryString('entity'));
if (!Defined(entity))
  entity="";
if (Defined(entity) &&(entity!=""))
{  
	var testtable=getTableInfo(entity);  
	if ((entity!="")&&(!Defined(testtable.name))){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
	  throw "No valid Entity found";
	}  
}
var entityid=new String(Request.QueryString('entityid'));
if (Defined(entityid) &&(entityid!=""))
{
	if (!isNumeric(entityid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.Form('entityid'));
	  throw "No valid Entity ID found";
	}
}

//get the document record
var commsql="select top 1 * from vcommunication where comm_communicationid="+commid;
var qcomm=CRM.CreateQueryObj(commsql);
qcomm.SelectSQL();

//must check context so the user has permission?
if (Defined(entity)&&(entity!=""))
{
  var table=getTableInfo(entity);
  var qEnt=getEntityRecord(entity,entityid);
  if (qEnt.eof)
    throw "Security Violation on Entity";
}

var subject=undefinedToBlank(qcomm.FieldValue("comm_subject"));
var body=undefinedToBlank(qcomm.FieldValue("Comm_Note"));
var htmlbody=undefinedToBlank(qcomm.FieldValue("Comm_Email"));
var from=undefinedToBlank(qcomm.FieldValue("Comm_From"));
var to=undefinedToBlank(qcomm.FieldValue("Comm_TO"));
var cc=undefinedToBlank(qcomm.FieldValue("Comm_CC"));

//check for email.html...this is used when we file html data to the library and not the database
var email_body=CRM.CreateQueryObj("select Libr_FilePath, Libr_FileName from vlibrary where Libr_FileName='email.html' and libr_communicationid="+commid);
email_body.SelectSQL();
if (!email_body.eof)
{
  var _fullpathx=getLibraryRootPath()+email_body.FieldValue("Libr_FilePath")+"\\"+email_body.FieldValue("Libr_FileName");
  htmlbody=readFile(_fullpathx);
	// Remove BOM if present..utf 8 code
	if (htmlbody.charCodeAt(0) === 239) {
		htmlbody = htmlbody.substring(3);
	}	  
}
// Call the function to generate the EML file with an attachment
createEMLWithAttachment(commid,subject,from,to,cc,body,htmlbody);

%>