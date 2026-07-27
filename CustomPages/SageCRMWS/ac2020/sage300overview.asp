<!-- #include file ="sagecrm.js" -->
<script type="text/javascript" src="../js/lib/jquery-1.8.2.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.3/dist/Chart.min.js" integrity="sha256-R4pqcOYV8lt7snxMQO/HSbVCFRPMdrhAFMH+vr9giYI=" crossorigin="anonymous"></script>

<script>

function _getPeriod(val){
	switch(val) {
	  case "1":
		return "Jan";
		break;
	  case "2":
		return "Feb";
		break;
	  case "3":
		return "Mar";
		break;
	  case "4":
		return "Apr";
		break;		
	  case "5":
		return "May";
		break;
	  case "6":
		return "Jun";
		break;
	  case "7":
		return "Jul";
		break;
	  case "8":
		return "Aug";
		break;		
	  case "9":
		return "Sep";
		break;
	  case "10":
		return "Oct";
		break;
	  case "11":
		return "Nov";
		break;
	  case "12":
		return "Dec";
		break;		
	  default:
		return val;
	}
}
</script>
<%

function readFile(fname){
	var fso = Server.CreateObject("Scripting.FilesystemObject");
	var txt = fso.OpenTextFile(Server.MapPath(fname));
	return txt.ReadAll();
}

//////////////////////////////////////////////////////////////////
///THIS IS A SAMPLE PAGE WITH HARD CODED VALUES FOR ERP
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

CurrentUser=CRM.GetContextInfo("selecteduser", "User_UserId");

container = CRM.GetBlock('container');
container.DisplayButton(Button_Default) = false;

customcontent = CRM.GetBlock("content");
customcontent.NewLine = false;
customcontent.contents="";

container.AddBlock( customcontent );

	customcontent.contents=readFile("customscreenheader.inc");	
	customcontent.contents=customcontent.contents.replace("__SCREENTITLE__","ERP");
	customcontent.contents=customcontent.contents.replace("__CRMPATH__",sInstallName);
	
    var itemtemplate=readFile("customscreenitem.inc");

	  var tmpitemtemplate=itemtemplate;
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","IDCUST");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","Balance");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__","$1,523,231");
	  customcontent.contents+=tmpitemtemplate;

	  tmpitemtemplate=itemtemplate;
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","AMTCRLIMT");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","We are owed:");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__","$350,235");
	  customcontent.contents+=tmpitemtemplate;

	  tmpitemtemplate=itemtemplate;
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","AMTBALDUET");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","We owe:");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__","$170,002");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__","$170,002");
	  customcontent.contents+=tmpitemtemplate;	 
	  
	customcontent.contents+=readFile("customscreenfooter.inc");

//add in our chart
customcontent.contents+='<canvas id="yearchart" width="1242" 400"="" height="621" style="display: block; height: 207px; width: 414px;" class="chartjs-render-monitor"></canvas>';
 
//init our data
var thisyeardata=[220,120,277,299,255,267,282,245,212,288,223,212];
var lastyeardata=[99,75,156,187,199,132,153,188,132,156,173,122];

%>
  <style>
  body{
      background-color: #EBEDEF !important;
      color: black !important;
  }
  </style>

<script>
window.chartColors = {
	red: 'rgb(255, 99, 132)',
	orange: 'rgb(255, 159, 64)',
	yellow: 'rgb(255, 205, 86)',
	green: 'rgb(75, 192, 192)',
	blue: 'rgb(54, 162, 235)',
	purple: 'rgb(153, 102, 255)',
	grey: 'rgb(201, 203, 207)'
};

//init our data
var thisyeardata=[<%=thisyeardata%>];
var lastyeardata=[<%=lastyeardata%>];
var chartperiods=[1,2,3,4,5,6,7,8,9,10,11,12];
var chartlabels=[];
//months
for (var i = 0; i < chartperiods.length; i++) {
	chartlabels[i]=_getPeriod((i+1)+"");
}	

var _backgroundColors=[window.chartColors.blue,
					window.chartColors.blue,
					window.chartColors.blue,				
					window.chartColors.blue,
					window.chartColors.blue,
					window.chartColors.blue,
					window.chartColors.blue,
					window.chartColors.blue,
					window.chartColors.blue,
					window.chartColors.blue,
					window.chartColors.blue,
					window.chartColors.blue,
					window.chartColors.blue,
					window.chartColors.blue];
var _borderColor=['rgba(54, 162, 235, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(54, 162, 235, 1)',
					'rgba(54, 162, 235, 1)']
 
var _backgroundColors2=[window.chartColors.orange,
					window.chartColors.orange,
					window.chartColors.orange,				
					window.chartColors.orange,
					window.chartColors.orange,
					window.chartColors.orange,
					window.chartColors.orange,
					window.chartColors.orange,
					window.chartColors.orange,
					window.chartColors.orange,
					window.chartColors.orange,
					window.chartColors.orange,
					window.chartColors.orange,
					window.chartColors.orange];
var _borderColor2=['rgba(255, 159, 64, 1)',
					'rgba(255, 159, 64, 1)',
					'rgba(255, 159, 64, 1)',
					'rgba(255, 159, 64, 1)',
					'rgba(255, 159, 64, 1)',
					'rgba(255, 159, 64, 1)',
					'rgba(255, 159, 64, 1)',
					'rgba(255, 159, 64, 1)',
					'rgba(255, 159, 64, 1)',
					'rgba(255, 159, 64, 1)',
					'rgba(255, 159, 64, 1)',
					'rgba(255, 159, 64, 1)',
					'rgba(255, 159, 64, 1)']
					
$( document ).ready(function() {
	var ctx = document.getElementById('yearchart').getContext('2d');
	var myChart = new Chart(ctx, {
		type: 'bar',
		data: {
			labels: chartlabels,
			datasets: [{
				label: 'Invoice Amounts this year',
				data: thisyeardata,
				backgroundColor: _backgroundColors,
				borderColor: _borderColor,
				borderWidth: 1
			},{
				label: 'Invoice Amounts last year',
				data: lastyeardata,
				backgroundColor: _backgroundColors2,
				borderColor: _borderColor2,
				borderWidth: 1
			}]
		},
		options: {
			scales: {
				yAxes: [{
					ticks: {
						beginAtZero: true
					}
				}]
			}
		}
	});

});
</script>
<%
Response.Write(container.Execute());
%>
<script>
 $("body").css("overflow", "scroll");
</script>