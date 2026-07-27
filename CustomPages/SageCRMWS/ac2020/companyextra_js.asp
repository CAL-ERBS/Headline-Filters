<!-- #include file ="reportobjects.js" -->
<%
////////////////////////////////////////////////////////////////////////////////////////////
//
//companyextra_js.asp
//
////////////////////////////////////////////////////////////////////////////////////////////
var myreport= JSON.clone(_reportClass);
myreport.name="test101";
//title
myreport.title="Company Extra Data";

////////////////////////////////////////////////////////////////////////////////////////////
//data section sample
var _companyboxlong=JSON.clone(_reportItem);
_companyboxlong.name='companyboxlong';
_companyboxlong.componenttype='screen';
var entityid=Request.Form("entityid");
if (!isNumeric(entityid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+entityid);
  throw "No valid Entity ID found";
}
var qCompany=CRM.Findrecord("company,vsummarycompany","comp_companyid="+entityid);
var companyboxlong=getScreenSection("company",qCompany,"companyboxlong","Company Extra");
_companyboxlong.data=companyboxlong;
myreport.reportdetails.push(_companyboxlong);

Response.Write(JSON.stringify(myreport));

%>