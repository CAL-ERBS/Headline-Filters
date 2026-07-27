<!-- #include file ="sagecrm.js" -->

<!-- #include file ="configreader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="selectentity.js" -->
<%
//
//used in MobileX and also in ICS appintment button in sage CRM that ct_sendWithOutlook.js inserts
//
var debug=false;

var sendAsEmail=(Request.Querystring('email')=='y');
var commid=Request.QueryString("commId");
if (!isNumeric(commid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Comm ID found, commid is "+Request.Form('commId'));
  throw "No valid Comm ID found";
}
var comm = CRM.FindRecord("Communication,vCalendarCommunication", "comm_communicationid=" + commid);
if (comm.eof) {
    Response.Clear();
    Response.Write("");
    Response.End();
}

var attendees="";//example ATTENDEE;CN=Bob Brown;RSVP=TRUE;ROLE=OPT-PARTICIPANT:mailto:bob.brown@example.com
//for loops get again
var cquery=CRM.CreateQueryObj("Select distinct RTRIM(pers_emailaddress) as pers_emailaddress, RTRIM(Pers_FirstName) as Pers_FirstName, RTRIM(Pers_LastName) as Pers_LastName from vCalendarCommunication where comm_communicationid=" + commid);
cquery.SelectSQL();
while(!cquery.eof)
{
	if (attendees!="")
		attendees+="\r\n"
    attendees+="ATTENDEE;CN="+cquery.FieldValue("Pers_FirstName")+" "+cquery.FieldValue("Pers_LastName")+";RSVP=TRUE;ROLE=OPT-PARTICIPANT:mailto:"+cquery.FieldValue("pers_emailaddress")+"\r\n";
	cquery.NextRecord();
}

var attendees2=""
var cquery2=CRM.CreateQueryObj("Select distinct CmLi_Comm_UserId from vCalendarCommunication where CmLi_Comm_UserId is not null and comm_communicationid=" + commid);
cquery2.SelectSQL();
while(!cquery2.eof)
{
	//get the user
	if (attendees2!="")
		attendees2+="\r\n";
	var uObj= getUserObject("and user_userid="+cquery2.FieldValue("CmLi_Comm_UserId")); 
	attendees2+="ATTENDEE;CN="+uObj.user_firstName+" "+uObj.user_lastName+";RSVP=TRUE;ROLE=OPT-PARTICIPANT:mailto:"+uObj.user_emailaddress;
	cquery2.NextRecord();
}

var subject = comm.item("comm_subject") || "";
var description = comm.item("comm_note") || "";

description=new String(description);
description=description.replace(/[\r\n]/g,"\\n");

function formatDate(dt) {
    var d = new Date(dt);
    if (d.getFullYear() == 1899) {
        d=new Date();
    }
	return  d.getFullYear()  + "" +     padLeft(d.getMonth()+1) +"" + padLeft(d.getDate()) + "T" + padLeft(d.getHours()) + "" + padLeft(d.getMinutes()) + ""+ padLeft(d.getSeconds());
}

function formatDate2(dt) {
    var d = new Date(dt);
    if (d.getFullYear() == 1899) {
        d=new Date();
    }
	return  padLeft(d.getMonth()+1) +"/" + padLeft(d.getDate()) + "/" + d.getFullYear()  + " " + padLeft(d.getHours()) + ":" + padLeft(d.getMinutes());
}

function padLeft(n) {

	if (n<10) return "0"+n;
	return n;
}


function getDTEnd(dt) {
    var d = new Date(dt);
    if (d.getFullYear() == 1899) {
       return "";
    } else {

       return "DTEND:" + formatDate(comm.item('comm_todatetime')) + '\r\n';
    }
}


function getStatus(_status) {
    if (!Defined(_status)) return "TENTATIVE";
	if (_status.toLowerCase() == "pending") return "CONFIRMED";	
    if (_status.toLowerCase() == "complete") return "CONFIRMED";
    if (_status.toLowerCase() == "cancelled") return "CANCELLED";       
    return "CONFIRMED";
}

var s = "BEGIN:VCALENDAR" + '\r\n' +
        "VERSION:2.0" + '\r\n'+
        "PRODID:-///CRM Together//Accelerator Calendar 1.4//EN" + '\r\n'+
//        "CALSCALE:GREGORIAN" + '\r\n'+
		"X-MS-OLK-FORCEINSPECTOROPEN:TRUE" + '\r\n'+
        "METHOD:PUBLISH" + '\r\n'+
        "BEGIN:VEVENT" + '\r\n'+
        "SUMMARY:" + subject + '\r\n'+
        "DESCRIPTION:" + (description || " ") + '\r\n'+
        "UID:"+ comm.RecordId + '\r\n'+
        "STATUS:" + getStatus(comm.comm_status)	 + '\r\n'+
        "DTSTART:"+ formatDate(comm.comm_datetime) + '\r\n'+
        getDTEnd(comm.comm_todatetime) + 
        "DTSTAMP:"+ formatDate(comm.comm_createddate)  + '\r\n'+
        //"CLASS:PRIVATE" + '\r\n'+
        //"CREATED:"+ formatDate(comm.comm_createddate)  + '\r\n'+
        "LOCATION:"+ (comm.comm_location || "") + '\r\n'+               
		//"LAST-MODIFIED:" + formatDate(comm.comm_createddate) + '\r\n' +
        //"SEQUENCE:0" + '\r\n' +        
       // "TRANSP:OPAQUE" + '\r\n' +
		attendees+attendees2+'\r\n' +
        "END:VEVENT" + '\r\n' +
        "END:VCALENDAR";

var _filePath=getLibraryRootPath()+"\\_icstmp\\";
fname = subject+".ics";
fs=Server.CreateObject("Scripting.FileSystemObject");

var _FolderExists = fs.FolderExists(_filePath);
if (!_FolderExists)
{
  fs.CreateFolder(_filePath);
}

f=fs.CreateTextFile(_filePath+fname,true);
f.write(s)
f.close();

if (!debug) {
    Response.Clear();
    Response.AddHeader("Content-Disposition", "attachment; filename="+fname);
    Response.ContentType = "text/calendar";
}
f=null;
fs=null;
Response.Write(s);
Response.End();
%>