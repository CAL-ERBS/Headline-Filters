<!-- #include file ="reportobjects.js" -->
<%
////////////////////////////////////////////////////////////////////////////////////////////
//File: crm_useractivityreport.asp
//Shows a summary of a users communication activity for today
//
////////////////////////////////////////////////////////////////////////////////////////////
var myreport= JSON.clone(_reportClass);
myreport.name="crm_useractivityreport";
//title
myreport.name="Activity Summary Report";
myreport.title="Activity Summary";

////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////
//data section sample
var _header=JSON.clone(_reportItem);
_header.name='rawheaderhtml';
_header.componenttype='html';
_header.element="div";
_header.data="<div style=\"max-height: 55px; background: rgb(243, 242, 241);\"><span class=\"title EntityViewXCardClassTitle\">Todays Activity</span></div>";
myreport.reportdetails.push(_header);

////////////////////////////////////////////////////////////////////////////////////////////
var _today=new Date();
var commslist=JSON.clone(_reportItem);
commslist.name='commslist';
commslist.componenttype='list';
var _commsql="select count(comm_communicationid) Count, 0 as comm_communicationid,"+
				"(select top 1 capt_us from Custom_Captions "+
				"where Capt_Code=Comm_Action and Capt_FamilyType='Choices' and Capt_Family='Comm_Action') as comm_Action "+
				"from Communication "+
				"where comm_deleted is null "+
				"and Comm_CreatedBy="+getUserId()+
				" AND (Comm_CreatedDate between '"+getSQLDate(_today)+" 00:00' and '"+getSQLDate(_today)+" 23:59') "+
				"group by Comm_Action";		
	
var qcommslist=CRM.CreateQueryObj(_commsql);
qcommslist.SelectSQL();
if (!qcommslist.eof){
  commslist.data=getListSection(qcommslist, "communication", ["Comm_Action","Count"]);
}
myreport.reportdetails.push(commslist);

Response.Write(JSON.stringify(myreport));

%>