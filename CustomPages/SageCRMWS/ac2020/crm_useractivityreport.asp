<!-- #include file ="sagecrm.js" -->
<!-- #include file ="json2.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<%
///File: crm_useractivityreport.asp
///shows a summary of todays comm activity for a user

%>
<script type="text/javascript" src="../js/lib/jquery-1.8.2.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.3/dist/Chart.min.js" integrity="sha256-R4pqcOYV8lt7snxMQO/HSbVCFRPMdrhAFMH+vr9giYI=" crossorigin="anonymous"></script>
<%
function arrayIndexOfAction(actionName, arraytouse){
	var res=-1;
	for(var xx=0;xx<arraytouse.length;xx++)
	{
		if (actionName==arraytouse[xx]){
			res=xx;
			break;
		}
	}	
	return res;
}
function readFile(fname){
	var fso = Server.CreateObject("Scripting.FilesystemObject");
	var txt = fso.OpenTextFile(Server.MapPath(fname));
	return txt.ReadAll();
}

CurrentUser=CRM.GetContextInfo("selecteduser", "User_UserId");

container = CRM.GetBlock('container');
container.DisplayButton(Button_Default) = false;

customcontent = CRM.GetBlock("content");
customcontent.NewLine = false;
customcontent.contents="";

container.AddBlock( customcontent );

	customcontent.contents=readFile("customscreenheader.inc");	
	customcontent.contents=customcontent.contents.replace("__SCREENTITLE__","Your Stats (today)");
	customcontent.contents=customcontent.contents.replace("__CRMPATH__",sInstallName);
	
    var itemtemplate=readFile("customscreenitem2cols.inc");

var _today=new Date();
var _commsql="select count(comm_communicationid) Count, 0 as comm_communicationid,"+
				"(select top 1 capt_"+getCRMUserLang()+" from Custom_Captions "+
				"where Capt_Code=Comm_Action and Capt_FamilyType='Choices' and Capt_Family='Comm_Action') as comm_Action "+
				"from Communication "+
				"where comm_deleted is null "+
				"and Comm_CreatedBy="+getUserId()+
				" and Comm_Action not in ('Demo','EMarketingDripEmail','EMarketingEmail','Vacation')"+
				" AND (Comm_CreatedDate between '"+getSQLDate(_today)+" 00:00' and '"+getSQLDate(_today)+" 23:59') "+
				"group by Comm_Action";	
var _commsqlq=CRM.CreateQueryObj(_commsql);
_commsqlq.SelectSQL();	
var _actionCount=[];
///build our labels
var _actionLabels=[];
var _actionsql="select capt_us from Custom_Captions where Capt_FamilyType='Choices' and Capt_Family='Comm_Action'"+
				" and capt_code not in ('Demo','EMarketingDripEmail','EMarketingEmail','Vacation')";
var _actionsqlq=CRM.CreateQueryObj(_actionsql);
_actionsqlq.SelectSQL();	
while (!_actionsqlq.eof)
{
	_actionLabels.push("'"+_actionsqlq("capt_us")+"'");
	_actionCount.push(0);
	_actionsqlq.NextRecord();
}
//build the data...
while (!_commsqlq.eof)
{
	var _idx=arrayIndexOfAction("'"+_commsqlq("comm_action")+"'",_actionLabels);
	_actionCount[_idx]=_commsqlq("Count");
	var tmpitemtemplate=itemtemplate;
	tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__",_commsqlq("comm_action"));
	tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","Action");
	tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",_commsqlq("comm_action"));
	tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION2__","Count");
	tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA2__",_commsqlq("Count"));
	customcontent.contents+=tmpitemtemplate;
	_commsqlq.NextRecord();
}
	  
	customcontent.contents+=readFile("customscreenfooter.inc");

%>
<tr id="myChartTodayTR"><td style="" >
<table><tr ><td>
<canvas id="myChartToday" width="300" height="300"></canvas>
</td></tr> </table>
</td></tr>
  <style>
  body{
      background-color: #EBEDEF !important;
      color: black !important;
  }
  </style>

<script>
var _ourlabels = [<%=_actionLabels%>];
var _todaysdata = [<%=_actionCount%>];


function createChart(__chartname, __dataset, __showlegend) {
	var ctx = document.getElementById(__chartname);
	var myChart = new Chart(ctx, {
		type: 'pie',
		data: {
			labels: _ourlabels,
			datasets: [{
				label: '',
				data: __dataset,
				backgroundColor: [
					'rgba(255, 99, 132, 0.2)',
					'rgba(54, 162, 235, 0.2)',
					'rgba(255, 206, 86, 0.2)',
					'rgba(75, 192, 192, 0.2)',
					'rgba(153, 102, 255, 0.2)',
						'rgba(255, 99, 132, 0.6)',
					'rgba(54, 162, 235, 0.6)',
					'rgba(255, 206, 86, 0.6)',
					'rgba(75, 192, 192, 0.6)',
					'rgba(153, 102, 255, 0.6)',
						'rgba(255, 99, 132, 0.9)',
					'rgba(54, 162, 235, 0.9)',
					'rgba(255, 206, 86, 0.9)',
					'rgba(75, 192, 192, 0.9)',
					'rgba(153, 102, 255, 0.9)'
				],
				borderColor: [
					'rgba(255, 99, 132, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(255, 206, 86, 1)',
					'rgba(75, 192, 192, 1)',
					'rgba(153, 102, 255, 1)',
						'rgba(255, 99, 132, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(255, 206, 86, 1)',
					'rgba(75, 192, 192, 1)',
					'rgba(153, 102, 255, 1)',
						'rgba(255, 99, 132, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(255, 206, 86, 1)',
					'rgba(75, 192, 192, 1)',
					'rgba(153, 102, 255, 1)'
				],
				borderWidth: 1
			}]
		},
		options: {
			legend: {
				display: __showlegend,
				position: 'left'
			},
			responsive: false,
			maintainAspectRatio: false,
		}
	});
}
		
$( document ).ready(function() {
   createChart('myChartToday', _todaysdata, true);
});
</script>
<%
Response.Write(container.Execute());
%>
<script>
 $("body").css("overflow", "scroll");
</script>