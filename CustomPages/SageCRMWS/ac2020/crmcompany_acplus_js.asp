<!-- #include file ="reportobjects.js" -->
<%
////////////////////////////////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////
var myreport= JSON.clone(_reportClass);
myreport.name="test101";
//title
myreport.name="Company Detail";
myreport.title="Company Interaction Summary";

////////////////////////////////////////////////////////////////////////////////////////////	
//data section sample
var _lastcomm=JSON.clone(_reportItem);
_lastcomm.name='_lastcomm';
_lastcomm.componenttype='html';
_lastcomm.element="div";

var CmLi_Comm_CompanyID=Request.QueryString("id");
if (!isNumeric(CmLi_Comm_CompanyID)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Company ID found, CmLi_Comm_CompanyID is "+Request.Form('id'));
  throw "No valid Company ID found";
}

var _commsqllast="select top 1 convert(varchar,Comm_DateTime, 113) as Comm_DateTime , Comm_Action, Comm_Description from vCommunication "+
	" where CmLi_Comm_CompanyID="+CmLi_Comm_CompanyID+
	" order by Comm_DateTime desc";

var qcommslist=CRM.CreateQueryObj(_commsqllast);
qcommslist.SelectSQL();

_lastcomm.data="<div style=\"max-height: 55px; background: rgb(243, 242, 241);\"><span>Last Communication</span></div>";
if (!qcommslist.eof){
	_lastcomm.data+=CRM.GetTrans('Comm_Action',qcommslist('Comm_Action'))+'('+qcommslist('Comm_DateTime')+')<br />';
	_lastcomm.data+=qcommslist('Comm_Description')+'<br />';
}
myreport.reportheader.push(_lastcomm);

////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////
//data section sample
var _header=JSON.clone(_reportItem);
_header.name='rawheaderhtml';
_header.componenttype='html';
_header.element="div";
_header.data="<div style=\"max-height: 55px; background: rgb(243, 242, 241);\"><span class=\"title EntityViewXCardClassTitle\">Top 5 most recent within Last 90 Days</span></div>";
myreport.reportdetails.push(_header);

////////////////////////////////////////////////////////////////////////////////////////////
var commslist=JSON.clone(_reportItem);
commslist.name='commslist';
commslist.componenttype='list';
var _commsql="select top 5 comm_communicationid, convert(varchar,Comm_DateTime, 113) as Comm_DateTime , Comm_Action, Comm_Description from vCommunication "+
	" where CmLi_Comm_CompanyID="+CmLi_Comm_CompanyID+
	" and Comm_DateTime>getdate()-90 order by Comm_DateTime desc";
	
var qcommslist=CRM.CreateQueryObj(_commsql);
qcommslist.SelectSQL();
if (!qcommslist.eof){
	commslist.data=getListSection(qcommslist, "communication", ["Comm_DateTime","Comm_Action","Comm_Description"]);
}
myreport.reportdetails.push(commslist);
////////////////////////////////////////////////////////////////////////////////////////////

var sampletitlex=JSON.clone(_reportItem);
sampletitlex.name='sampletitlex';
sampletitlex.componenttype='title';
sampletitlex.data="sampletitlex text";
//myreport.reportdetails.push(sampletitlex);

var _salesactheader=JSON.clone(_reportItem);
_salesactheader.name='_salesactheader';
_salesactheader.componenttype='html';
_salesactheader.element="div";
_salesactheader.data="<div style=\"max-height: 55px; background: rgb(243, 242, 241);\"><span class=\"title EntityViewXCardClassTitle\">Sales Activity</span></div>";
//myreport.reportdetails.push(_salesactheader);

Response.Write(JSON.stringify(myreport));

%>