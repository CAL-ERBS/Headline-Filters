<!-- #include file ="reportobjects.js" -->
<%
////////////////////////////////////////////////////////////////////////////////////////////
//File: sage200qnectfins.asp
//
//
////////////////////////////////////////////////////////////////////////////////////////////
var myreport= JSON.clone(_reportClass);
myreport.name="Financials";
//title
myreport.title="Sage 200 Financials";
////////////////////////////////////////////////////////////////////////////////////////////
///Company-Screen=QnectCompanyOfficeInt
////////////////////////////////////////////////////////////////////////////////////////////
//data section sample
var QnectCompanyOfficeInt=JSON.clone(_reportItem);
QnectCompanyOfficeInt.name='QnectCompanyOfficeInt';
QnectCompanyOfficeInt.componenttype='screen';
var compid=Request.QueryString("id");
if (!Defined(compid))
  compid=18;
if (!isNumeric(compid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Company ID found, compid is "+Request.Form('compid'));
  throw "No valid Company ID found";
}  
var qCompany=CRM.Findrecord("QnectCompany","qnco_companyid="+compid);
var companyboxlong=getScreenSection("QnectCompany",qCompany,"QnectCompanyOfficeInt","Company");
QnectCompanyOfficeInt.data=companyboxlong;
myreport.reportdetails.push(QnectCompanyOfficeInt);
////////////////////////////////////////////////////////////////////////////////////////////
///Financials-Screen=QnectFinancialsOfficeInt
////////////////////////////////////////////////////////////////////////////////////////////
var qfinSQL="select  qnco_QnectCompanyid,qnco_acref,qnco_accounttype, fin.* from [QnectCompany] comp WITH (NOLOCK) "+
			"left join [QnectFinancials] fin on fin.qnfi_primaryqnco=comp.qnco_QnectCompanyid "+
			"where qnco_deleted is null and qnco_companyid="+compid;

var qFin=CRM.CreateQueryObj(qfinSQL);
qFin.SelectSQL();
while(!qFin.eof)
{
	var QnectFinancialsOfficeInt=JSON.clone(_reportItem);
	QnectFinancialsOfficeInt.name='QnectFinancialsOfficeInt';
	QnectFinancialsOfficeInt.componenttype='screen';
	var qQnectFinancials=CRM.Findrecord("QnectFinancials","667=667 and qnfi_deleted is null and qnfi_QnectFinancials="+qFin("qnfi_QnectFinancials"));
	var QnectFinancialsboxlong=getScreenSection("QnectFinancials",qQnectFinancials,"QnectFinancialsOfficeInt","Financials ("+qFin("qnfi_qnectsystemid")+")");
	QnectFinancialsOfficeInt.data=QnectFinancialsboxlong;
	myreport.reportdetails.push(QnectFinancialsOfficeInt);
	qFin.NextRecord();
}

Response.Write(JSON.stringify(myreport));

%>