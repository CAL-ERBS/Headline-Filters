<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
	<link REL="stylesheet" href="/<%=sInstallName%>/CustomPages/SageCRMWS/ac2020/ctmobile.css"/>
	<script src="/<%=sInstallName%>/CustomPages/SageCRMWS/ac2020/ctmobile.js"></script>
<%

function formatDate(dt) {
    var d = new Date(dt);
    if (d.getFullYear() == 1899) {
        d=new Date();
    }
	//to do...use user date format
	//return    padLeft(d.getDate())  +"/" + padLeft(d.getMonth()+1) +"/" + d.getFullYear()  + " " + padLeft(d.getHours()) + ":" + padLeft(d.getMinutes());
	return     padLeft(d.getMonth()+1) +"/" +  padLeft(d.getDate()) +"/" + d.getFullYear()  + " " + padLeft(d.getHours()) + ":" + padLeft(d.getMinutes());	
}

function padLeft(n) {

	if (n<10) return "0"+n;
	return n;
}

function getTitle(s) {
    if (!Defined(s)) return "-";
    return new String(s);
}

var comms = null;
var __namedEntity=(Request.Querystring('entity'))+"";

if (Defined(__namedEntity)&&(__namedEntity!=""))
{
	var testtable=getTableInfo(__namedEntity);
	if (!Defined(testtable.name)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
	  throw "No valid Entity found";
	}
}

var _csql="";
if (Defined(__namedEntity)){
	var entityid=(Request.Querystring('id'));
	var table=getTableInfo(__namedEntity);
	_csql="SELECT TOP(10) * FROM vListCommunication WHERE (comm_type='Task' OR comm_type='Appointment') AND " + table.communicationField+"="+entityid + " ORDER BY comm_createddate DESC";
    comms = CRM.CreateQueryObj(_csql);	
}else{
	comms = CRM.CreateQueryObj("SELECT TOP(10) * FROM vListCommunication WHERE (comm_type='Task' OR comm_type='Appointment') AND cmli_comm_userid=" +
	 CRM.GetContextInfo("User", "user_userid") + " ORDER BY comm_createddate DESC");
}
try{
  comms.SelectSql();
}catch(sqlerr){
  Response.Write(_csql);
  Response.Write("<br />");
  Response.Write(sqlerr.message);
}
var sHTML = "<div style='width:80%;margin:auto;padding:10px'><div style='float:left'><h5>"+
	CRM.GetTrans("ColNames","vPersonAppointment")
	+"</h5></div><div style='float:right'><button type='button' onClick=\"document.location.reload()\"><img src='arrow-clockwise.png'/></button></div><br/>";
sHTML += "<br/><div style='clear: both;'><table width='100%' border=0>"

while(!comms.eof) {

    var sUrl = http_protocol + get_SERVER_NAME()  + "/" + sInstallName + 
    "/CustomPages/SageCRMWS/ac2020/getIcs.asp?SID="+ Request.QueryString("SID") + "&commId=" + comms("comm_communicationid");

	var sUrlemail ="";
	if (Defined(GetWebConfigValue("EmailUserName"))&&(GetWebConfigValue("EmailUserName")!=""))
	{
		sUrlemail = http_protocol + get_SERVER_NAME()  + "/" + sInstallName + 
				"/CustomPages/SageCRMWS/ac2020/getIcs.asp?SID="+ Request.QueryString("SID") + "&email=y&commId=" + comms("comm_communicationid");
	}
    sHTML += "<tr>";    
    sHTML += "<td valign='top'><img src='calendar2-event.png'/>&nbsp;<span class='text-primary'>" + formatDate(comms("comm_datetime")) +  
        "</span><br/><br/><span class='text-secondary'>"+ getTitle(comms("comm_subject")) + "</span></td>"+
        "<td valign='top' style='height: 41px;width: 41px;' >"+
		"<a class='button-link' target='_SELF' href='"+ sUrl +"'><img src='box-arrow-down.png'/></a></div>" 
		+ "</td>"+
		"<td>&nbsp;&nbsp;&nbsp;</td>";
	if (Defined(GetWebConfigValue("EmailUserName"))&&(GetWebConfigValue("EmailUserName")!=""))
	{
		sHTML += "<td valign='top' style='height: 41px;width: 41px;'  ><a style='height: 41px;width: 41px;'  target='_SELF' href='"+ sUrlemail +"'><img src='envelope-plus.svg'/></a></div>" + "</td>";
	}
    sHTML += "</tr>";
    sHTML += "<tr colspan='2'><td><br/></td></tr>";

    comms.NextRecord();

    
}
sHTML += "</table></div></div>";

  
  
Response.Write(sHTML);
%>