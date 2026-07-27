<!-- #include file ="sagecrm.js" -->

<!-- #include file ="configreader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="selectentity.js" -->
<%
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

var description = comm("comm_note") || "";

/*
--removed as full details added below
if (Defined(comm("CmLi_Comm_PersonId"))) {
    description += " \\n--"+CRM.GetTrans("Tabnames","Person")+"--: " + comm("Pers_FirstName") + " " + comm("Pers_LastName");
}

if (Defined(comm("CmLi_Comm_CompanyId"))) {
    description += " \\n--"+CRM.GetTrans("Tabnames","Company")+"--: " + comm("Comp_name");
}
*/

description=new String(description);
description=description.replace(/[\r\n]/g,"\\n");

var _captdetails=CRM.GetTrans("ColNames","Comm_Note");
description = '---' + _captdetails + '---\\n'+description;

function sendEmail(em_subject,em_body,em_to, attachf){

	var email=new Object();
	email.subject = em_subject;
	email.HTMLBody = em_body;
	
////****************************************************************************
////****SETTINGS BELOW NEED TO BE aded to the web.config
////
////****************************************************************************	
    email.smtpserver=GetWebConfigValue("EmailHost");        
    email.smtpserverport=GetWebConfigValue("EmailHostPort");
    email.from=GetWebConfigValue("EmailFrom");
    email.sendusername=GetWebConfigValue("EmailUserName");
    email.sendpassword=GetWebConfigValue("EmailPassword");
    email.EnableSsl=GetWebConfigValue("EnableSsl")=="Y";    
    email.to =em_to; 	

////****************************************************************************
////****************************************************************************
////****************************************************************************

   var config = new ActiveXObject("CDO.Configuration");
   var sch = "http://schemas.microsoft.com/cdo/configuration/";   
   config.Fields.item(sch + "sendusing") = 2;// ' cdoSendUsingPort
   config.Fields.item(sch + "smtpserver") = email.smtpserver;//
   config.Fields.item(sch + "smtpserverport") = email.smtpserverport;
   config.Fields.item(sch + "smtpauthenticate") = 1;//'basic auth
   config.Fields.item(sch + "smtpusessl") = email.EnableSsl;//ref: http://stackoverflow.com/questions/13531934/sending-a-cdo-email-message-using-an-ssl-connection
   config.Fields.item(sch + "sendusername") = email.sendusername;
   config.Fields.item(sch + "sendpassword") = email.sendpassword;
   config.Fields.item(sch + "smtpconnectiontimeout") = 60;
   config.Fields.item(sch + "smtpaccountname") = email.sendusername;
   
   config.Fields.update();
   var myMail= new ActiveXObject("CDO.Message");
   myMail.configuration = config;

	myMail.AddAttachment(attachf);

	myMail.to = email.to;
	myMail.from = email.from;
	myMail.subject = email.subject;
	myMail.HTMLBody = email.HTMLBody;
	myMail.HTMLBody = myMail.HTMLBody.replace(/[\r\n]/g, "");

	myMail.send();
	
}

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

       return "DTEND:" + formatDate(comm.comm_todatetime) + '\r\n';
    }
}


function getStatus(_status) {
    if (!Defined(_status)) return "TENTATIVE";
	 if (_status.toLowerCase() == "pending") return "CONFIRMED";
    if (_status.toLowerCase() == "complete") return "CONFIRMED";
    if (_status.toLowerCase() == "cancelled") return "CANCELLED";       
    return "CONFIRMED";
}

if (comm.comm_caseid) {

    var _capt=CRM.GetTrans("TabNames","ViewCases");
    description += '\\n\\n---' + _capt + '---';

    var qcases = CRM.FindRecord("Cases,vsummaryCase", "86531=86531 and case_caseid=" + comm.comm_caseid);
    var casesOfficeInt = getScreenSection("Cases", qcases, "casesOfficeInt", CRM.GetTrans("TabNames", "Cases"));
    for(var abc=0;abc<casesOfficeInt.data.length;abc++)
	{
		var dataObj=casesOfficeInt.data[abc];
		var _tempstr=new String(qcases(dataObj.name));
		if (Defined(_tempstr)&&(_tempstr!="")&&(dataObj.displayvalue!=""))
		{
			description+="  \\n"+dataObj.caption+": \\n";
			if (dataObj.type=="11")
			{
				_tempstr=_tempstr.replace(/[\r\n]/g,"\\n");
				description+= _tempstr;//multiline text
			}else{
				description+= dataObj.displayvalue;
			}
		}
	}
}else
if (comm.comm_opportunityid) {

    var _capt=CRM.GetTrans("TabNames","ViewOppo");
    description += '\\n\\n---' + _capt + '---';

    var qoppos = CRM.FindRecord("Opportunity,vsummaryOpportunity", "86531=86531 and oppo_opportunityid=" + comm.comm_opportunityid);
    var opportunityOfficeInt = getScreenSection("Opportunity", qoppos, "OpportunityOfficeInt", CRM.GetTrans("TabNames", "Opportunity"));
    for(var abc=0;abc<opportunityOfficeInt.data.length;abc++)
	{
		var dataObj=opportunityOfficeInt.data[abc];
		var _tempstr=new String(qoppos(dataObj.name));
		if (Defined(_tempstr)&&(_tempstr!="")&&(dataObj.displayvalue!=""))
		{
			description+="  \\n"+dataObj.caption+": \\n";
			if (dataObj.type=="11")
			{
				_tempstr=_tempstr.replace(/[\r\n]/g,"\\n");
				description+= _tempstr;//multiline text
			}else{
				description+= dataObj.displayvalue;
			}
		}
	}
}else
if (comm.comm_leadid) {

    var _capt=CRM.GetTrans("TabNames","ViewLead");
    description += '\\n\\n---' + _capt + '---';

    var qlead = CRM.FindRecord("Lead,vsummaryLead", "86531=86531 and lead_leadid=" + comm.comm_leadid);
	var leadOfficeInt = getScreenSection("Lead", qlead, "LeadOfficeInt", CRM.GetTrans("TabNames", "Lead"));
    for(var abc=0;abc<leadOfficeInt.data.length;abc++)
	{
		var dataObj=leadOfficeInt.data[abc];
		var _tempstr=new String(qlead(dataObj.name));
		if (Defined(_tempstr)&&(_tempstr!="")&&(dataObj.displayvalue!=""))
		{
			description+="  \\n"+dataObj.caption+": \\n";
			if (dataObj.type=="11")
			{
				_tempstr=_tempstr.replace(/[\r\n]/g,"\\n");
				description+= _tempstr;//multiline text
			}else{
				description+= dataObj.displayvalue;
			}
		}
	}
}
if (comm.cmli_comm_companyid) {
    var _capt=CRM.GetTrans("TabNames","Company");
    description += '\\n\\n---' + _capt + '---';

    var qCompany = CRM.FindRecord("Company,vsummaryCompany", "86534=86534 and comp_companyid=" + comm.cmli_comm_companyid);
	var companyfficeInt = getScreenSection("Company", qCompany, "CompanyOfficeInt", CRM.GetTrans("TabNames", "Company"));
    for(var abc=0;abc<companyfficeInt.data.length;abc++)
	{
		var dataObj=companyfficeInt.data[abc];
		var _tempstr=new String(qCompany(dataObj.name));
		if (Defined(_tempstr)&&(_tempstr!="")&&(dataObj.displayvalue!=""))
		{
			description+="  \\n"+dataObj.caption+": \\n";
			if (dataObj.type=="11")
			{
				_tempstr=_tempstr.replace(/[\r\n]/g,"\\n");
				description+= _tempstr;//multiline text
			}else{
				description+= dataObj.displayvalue;
			}
		}
	}
	var qaddress=CRM.FindRecord("address,vAddressCompany","Addr_AddressId="+qCompany("Comp_PrimaryAddressId"));
	var AddressOfficeInt = getScreenSection("address", qaddress, "AddressOfficeInt", CRM.GetTrans("TabNames", "Address"));
	_capt=CRM.GetTrans("TabNames","Address");
    description += '\\n\\n---' + _capt + '---';
	for(var abc=0;abc<AddressOfficeInt.data.length;abc++)
	{
		var dataObj=AddressOfficeInt.data[abc];
		var _tempstr=new String(qaddress(dataObj.name));
		if (Defined(_tempstr)&&(_tempstr!="")&&(dataObj.displayvalue!=""))
		{
			description+="  \\n"+dataObj.caption+": \\n";
			if (dataObj.type=="11")
			{				
				_tempstr=_tempstr.replace(/[\r\n]/g,"\\n");
				description+= _tempstr;//multiline text
			}else{
				description+= dataObj.displayvalue;
			}
		}
	}	
	var _mapAddress = getMapAddress(qaddress);
	_mapAddress=_mapAddress.replace(/" "/g,"%20");
    AddressOfficeInt.externallink.url = "https://www.google.com/maps?q=" + _mapAddress;
	description += "\\n"+AddressOfficeInt.externallink.url;
				 
	var emails = getEmailScreenSection("company", comm.cmli_comm_companyid, CRM.GetTrans("TabNames", "Email"));
	if ((emails)&&(emails.data)){
		_capt=CRM.GetTrans("TabNames","Email");	
		description += '\\n\\n---' + _capt + '---';
		for(var abc=0;abc<emails.data.length;abc++)
		{
			var dataObj=emails.data[abc];
			if (Defined(dataObj.displayvalue)&&(dataObj.displayvalue!=""))
			{
				description+="  \\n"+dataObj.caption+": \\n";
				description+= dataObj.displayvalue;
			}
		}		
	}
	var phone = getPhoneScreenSection("company", comm.cmli_comm_companyid, CRM.GetTrans("TabNames", "Phone"));	
	if ((phone)&&(phone.data)){	
		_capt=CRM.GetTrans("TabNames","Phone");
		description += '\\n\\n---' + _capt + '---';
		for(var abc=0;abc<phone.data.length;abc++)
		{
			var dataObj=phone.data[abc];
			if (Defined(dataObj.displayvalue)&&(dataObj.displayvalue!=""))
			{
				description+="  \\n"+dataObj.caption+": \\n";
				description+= dataObj.displayvalue;
			}
		}	
	}
}

if (comm.cmli_comm_personid) {
    var _capt=CRM.GetTrans("TabNames","Person");
    description += '\\n\\n---' + _capt + '---';

    var qPerson = CRM.FindRecord("Person,vsummaryPerson", "86534=86534 and pers_personid=" + comm.cmli_comm_personid);
	var personfficeInt = getScreenSection("Person", qPerson, "PersonOfficeInt", CRM.GetTrans("TabNames", "Person"));
    for(var abc=0;abc<personfficeInt.data.length;abc++)
	{
		var dataObj=personfficeInt.data[abc];
		var _tempstr=new String(qPerson(dataObj.name));
		if (Defined(_tempstr)&&(_tempstr!="")&&(dataObj.displayvalue!=""))
		{
			description+="  \\n"+dataObj.caption+": \\n";
			if (dataObj.type=="11")
			{
				_tempstr=_tempstr.replace(/[\r\n]/g,"\\n");
				description+= _tempstr;//multiline text
			}else{
				description+= dataObj.displayvalue;
			}
		}
	}
	//..this should be in a function as duplicated from above..to do
	var qaddress=CRM.FindRecord("address,vAddressPerson","Addr_AddressId="+qPerson("pers_PrimaryAddressId"));
	var AddressOfficeInt = getScreenSection("address", qaddress, "AddressOfficeInt", CRM.GetTrans("TabNames", "Address"));
	_capt=CRM.GetTrans("TabNames","Address");
    description += '\\n\\n---' + _capt + '---';
	for(var abc=0;abc<AddressOfficeInt.data.length;abc++)
	{
		var dataObj=AddressOfficeInt.data[abc];
		var _tempstr=new String(qaddress(dataObj.name));
		if (Defined(_tempstr)&&(_tempstr!="")&&(dataObj.displayvalue!=""))
		{
			description+="  \\n"+dataObj.caption+": \\n";
			if (dataObj.type=="11")
			{				
				_tempstr=_tempstr.replace(/[\r\n]/g,"\\n");
				description+= _tempstr;//multiline text
			}else{
				description+= dataObj.displayvalue;
			}
		}
	}	
		var _mapAddress = getMapAddress(qaddress);
	_mapAddress=_mapAddress.replace(/" "/g,"%20");
    AddressOfficeInt.externallink.url = "https://www.google.com/maps?q=" + _mapAddress;
	description += "\\n"+AddressOfficeInt.externallink.url;
	
	var emails = getEmailScreenSection("person", comm.cmli_comm_personid, CRM.GetTrans("TabNames", "Email"));
	if ((emails)&&(emails.data)){	
		_capt=CRM.GetTrans("TabNames","Email");
		description += '\\n\\n---' + _capt + '---';
		for(var abc=0;abc<emails.data.length;abc++)
		{
			var dataObj=emails.data[abc];
			if (Defined(dataObj.displayvalue)&&(dataObj.displayvalue!=""))
			{
				description+="  \\n"+dataObj.caption+": \\n";
				description+= dataObj.displayvalue;
			}
		}		
	}
	var phone = getPhoneScreenSection("person", comm.cmli_comm_personid, CRM.GetTrans("TabNames", "Phone"));	
	if ((phone)&&(phone.data)){		
		_capt=CRM.GetTrans("TabNames","Phone");
		description += '\\n\\n---' + _capt + '---';
		for(var abc=0;abc<phone.data.length;abc++)
		{
			var dataObj=phone.data[abc];
			if (Defined(dataObj.displayvalue)&&(dataObj.displayvalue!=""))
			{
				description+="  \\n"+dataObj.caption+": \\n";
				description+= dataObj.displayvalue;
			}
		}	
	}
}

var attendees="";//example ATTENDEE;CN=Bob Brown;RSVP=TRUE;ROLE=OPT-PARTICIPANT:mailto:bob.brown@example.com
//for loops get again
var cquery=CRM.CreateQueryObj("Select distinct RTRIM(pers_emailaddress) as pers_emailaddress, RTRIM(Pers_FirstName) as Pers_FirstName, RTRIM(Pers_LastName) as Pers_LastName from vCalendarCommunication where comm_communicationid=" + commid);
cquery.SelectSQL();
while(!cquery.eof)
{
	if (attendees!="")
		attendees+="\r\n";
	if (Defined(cquery.FieldValue("Pers_FirstName")))
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

var s = "BEGIN:VCALENDAR" + '\r\n' +
        "VERSION:2.0" + '\r\n'+
        "PRODID:-///CRM Together//MobileX Calendar 1.3//EN" + '\r\n'+
//        "CALSCALE:GREGORIAN" + '\r\n'+
        "METHOD:PUBLISH" + '\r\n'+
        "BEGIN:VEVENT" + '\r\n'+
        "SUMMARY:" + (comm.comm_subject || comm.comm_type) + '\r\n'+
        "DESCRIPTION:" + (description || " ") + '\r\n'+
        "UID:"+ comm.RecordId + '\r\n'+
        "STATUS:" + getStatus(comm.comm_status) + '\r\n'+
        "DTSTART:"+ formatDate(comm.comm_datetime) + '\r\n'+
        getDTEnd(comm.comm_todatetime) + 
        "DTSTAMP:"+ formatDate(comm.comm_createddate)  + '\r\n'+
        //"CLASS:PRIVATE" + '\r\n'+
        //"CREATED:"+ formatDate(comm.comm_createddate)  + '\r\n'+
        "LOCATION:"+ (comm.comm_location || " ") + '\r\n'+               
		attendees+attendees2+'\r\n' +		
		//"LAST-MODIFIED:" + formatDate(comm.comm_createddate) + '\r\n' +
        //"SEQUENCE:0" + '\r\n' +        
       // "TRANSP:OPAQUE" + '\r\n' +
        "END:VEVENT" + '\r\n' +
        "END:VCALENDAR";

var _filePath=getLibraryRootPath()+"\\_icstmp\\";
fname = comm.RecordId + "_comm_calendar.ics";
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
if (sendAsEmail)
{
    var _userEmailAddress=CRM.GetContextInfo('user','user_emailaddress');
	sendEmail("Add to Calendar: "+comm.comm_subject,"Click the attached File",_userEmailAddress, _filePath+fname);	
	//Response.Write(s);
	fs.DeleteFile(_filePath+fname);
	f=null;
	fs=null;
	Response.End();
}else{
	f=null;
	fs=null;
	Response.Write(s);
	Response.End();
}
%>