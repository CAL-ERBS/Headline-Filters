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
///THIS IS A SAMPLE PAGE WITH HARD CODED VALUES FOR SAGE 300 DATABASE 
//    Saminc
// AND CUSTOMER Number
//     7300
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

CurrentUser=CRM.GetContextInfo("selecteduser", "User_UserId");

container = CRM.GetBlock('container');
container.DisplayButton(Button_Default) = false;

customcontent = CRM.GetBlock("content");
customcontent.NewLine = false;
customcontent.contents="";

container.AddBlock( customcontent );
var id=Request.QueryString("id");
if (!isNumeric(id)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid company ID found, id is "+id);
  throw "No valid company ID found";
}

var comprec=CRM.FindRecord("company","comp_companyid="+id);
var comp_database="SAMINC";
try{
 comp_database=comprec("comp_database");
}catch(e){}
var comp_custid="7300";
try{
 comp_custid=comprec("comp_custid");
}catch(e){}

if ((comp_database=="")||(comp_custid=="")||(comp_custid+""=="undefined"))
{
  customcontent.contents="No Sage 300 data links found";
	  Response.Write(container.Execute());
	  Response.End();  
}else{
	var fieldlist="IDCUST,NAMECUST,TEXTSTRE1,TEXTSTRE2,TEXTSTRE3,TEXTSTRE4,NAMECITY,CODESTTE,CODEPSTL,NAMECTAC,TEXTPHON1,TEXTPHON2,AMTCRLIMT,	AMTBALDUET,AMTBALDUEH,EMAIL1";
	var sql = "select "+fieldlist+" from "+comp_database+".dbo.ARCUS where IDCUST='"+comp_custid+"'";

	var ARCUS=CRM.CreateQueryObj(sql);
	ARCUS.SelectSQL();
	if (ARCUS.eof)
	{
	  customcontent.contents="No Sage 300 record found";
	  Response.Write(container.Execute());
	  Response.End();
	}
	customcontent.contents=readFile("customscreenheader.inc");
	customcontent.contents=customcontent.contents.replace("__SCREENTITLE__","Sage 300");
	customcontent.contents=customcontent.contents.replace("__CRMPATH__",sInstallName);
	
    var itemtemplate=readFile("customscreenitem.inc");
	if (!ARCUS.eof)
	{
	  var tmpitemtemplate=itemtemplate;
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","IDCUST");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","Customer No:");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",ARCUS("IDCUST"));
	  customcontent.contents+=tmpitemtemplate;

	  tmpitemtemplate=itemtemplate;
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","AMTCRLIMT");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","Credit Limit:");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",ARCUS("AMTCRLIMT"));
	  customcontent.contents+=tmpitemtemplate;

	  tmpitemtemplate=itemtemplate;
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","AMTBALDUET");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","Balance Due:");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",ARCUS("AMTBALDUET"));
	  customcontent.contents+=tmpitemtemplate;	 
	  
	  tmpitemtemplate=itemtemplate;
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","AMTBALDUEH");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","Total Balance Due:");
	  tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",ARCUS("AMTBALDUEH"));
	  customcontent.contents+=tmpitemtemplate; 
    }
	customcontent.contents+=readFile("customscreenfooter.inc");
}


//add in our chart
customcontent.contents+='<canvas id="yearchart" width="1242" 400"="" height="621" style="display: block; height: 207px; width: 414px;" class="chartjs-render-monitor"></canvas>';

//get our data for this year
var csql="select sum(TERMTTLDUE) as amt, "+
         "DATEPART(m, convert(datetime,convert(varchar(10),INVDATE,120))) as mth, "+
         "DATEPART(yyyy, convert(datetime,convert(varchar(10),INVDATE,120))) as yr "+
         "from "+comp_database+".dbo.OEINVH "+
         "where CUSTOMER='"+comp_custid+"' "+
		 "and ( "+
		 "DATEPART(yyyy, convert(datetime,convert(varchar(10),INVDATE,120) )) = DATEPART(yyyy, getdate())  "+
		 ") "+
         "group by "+
         "DATEPART(m, convert(datetime,convert(varchar(10),INVDATE,120))), "+
         "DATEPART(yyyy, convert(datetime,convert(varchar(10),INVDATE,120)))"+
		 "order by yr, mth";
//get our data for last year	 
var csql2="select sum(TERMTTLDUE) as amt, "+
         "DATEPART(m, convert(datetime,convert(varchar(10),INVDATE,120))) as mth, "+
         "DATEPART(yyyy, convert(datetime,convert(varchar(10),INVDATE,120))) as yr "+
         "from "+comp_database+".dbo.OEINVH "+
         "where CUSTOMER='"+comp_custid+"' "+
		 "and ("+
		 "DATEPART(yyyy, convert(datetime,convert(varchar(10),INVDATE,120) )) = DATEPART(yyyy,  DATEADD(yyyy, -1, getdate()))  "+
		 ") "+
         "group by "+
         "DATEPART(m, convert(datetime,convert(varchar(10),INVDATE,120))), "+
         "DATEPART(yyyy, convert(datetime,convert(varchar(10),INVDATE,120)))"+
		 "order by yr, mth";		 

//init our data
var thisyeardata=[0,0,0,0,0,0,0,0,0,0,0,0];
var lastyeardata=[0,0,0,0,0,0,0,0,0,0,0,0];

var csqlq=CRM.CreateQueryObj(csql);
csqlq.SelectSQL();
while(!csqlq.eof)
{
    var mth=new Number(csqlq("mth"));
	thisyeardata[mth-1]=csqlq("amt");
	csqlq.NextRecord();
}

var csqlq2=CRM.CreateQueryObj(csql2);
csqlq2.SelectSQL();
while(!csqlq2.eof)
{
    var mth=new Number(csqlq2("mth"));
	lastyeardata[mth-1]=csqlq2("amt");
	csqlq2.NextRecord();
}

//order data
customcontent.contents+='<canvas id="yearchartorders" width="1242" 400"="" height="621" style="display: block; height: 207px; width: 414px;" class="chartjs-render-monitor"></canvas>';

var osql="select count(*) as numberoforders, "+
         "DATEPART(m, convert(datetime,convert(varchar(10),ORDDATE,120))) as mth,  "+
         "DATEPART(yyyy, convert(datetime,convert(varchar(10),ORDDATE,120))) as yr  "+
         "from Saminc.dbo.OEORDH  "+
         "where CUSTOMER='"+comp_custid+"' and  "+
         "( DATEPART(yyyy, convert(datetime,convert(varchar(10),ORDDATE,120) )) = DATEPART(yyyy, getdate()) )  "+
         "group by DATEPART(m, convert(datetime,convert(varchar(10),ORDDATE,120))),  "+
         "DATEPART(yyyy, convert(datetime,convert(varchar(10),ORDDATE,120)))  "+
         "order by yr, mth";
//get our data for last year	 
var osql2="select count(*) as numberoforders, "+
         "DATEPART(m, convert(datetime,convert(varchar(10),ORDDATE,120))) as mth,  "+
         "DATEPART(yyyy, convert(datetime,convert(varchar(10),ORDDATE,120))) as yr  "+
         "from Saminc.dbo.OEORDH  "+
         "where CUSTOMER='"+comp_custid+"' and  "+
         "(DATEPART(yyyy, convert(datetime,convert(varchar(10),ORDDATE,120) )) = DATEPART(yyyy,  DATEADD(yyyy, -1, getdate())))  "+
		 "group by DATEPART(m, convert(datetime,convert(varchar(10),ORDDATE,120))),  "+
         "DATEPART(yyyy, convert(datetime,convert(varchar(10),ORDDATE,120)))  "+
         "order by yr, mth";

//init our data
var othisyeardata=[0,0,0,0,0,0,0,0,0,0,0,0];
var olastyeardata=[0,0,0,0,0,0,0,0,0,0,0,0];

var osqlq=CRM.CreateQueryObj(osql);
osqlq.SelectSQL();
while(!osqlq.eof)
{
    var mth=new Number(osqlq("mth"));
	othisyeardata[mth-1]=osqlq("numberoforders");
	osqlq.NextRecord();
}

var osqlq2=CRM.CreateQueryObj(osql2);
osqlq2.SelectSQL();
while(!osqlq2.eof)
{
    var mth=new Number(osqlq2("mth"));
	olastyeardata[mth-1]=osqlq2("numberoforders");
	osqlq2.NextRecord();
}

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
var othisyeardata=[<%=othisyeardata%>];
var olastyeardata=[<%=olastyeardata%>];
var chartperiods=[1,2,3,4,5,6,7,8,9,10,11,12];
var chartlabels=[];
//months
for (var i = 0; i < chartperiods.length; i++) {
	chartlabels[i]=_getPeriod((i+1)+"");
}	

var _backgroundColors=[window.chartColors.green,
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
	
var _obackgroundColors=[window.chartColors.green,
					window.chartColors.green,
					window.chartColors.green,				
					window.chartColors.green,
					window.chartColors.green,
					window.chartColors.green,
					window.chartColors.green,
					window.chartColors.green,
					window.chartColors.green,
					window.chartColors.green,
					window.chartColors.green,
					window.chartColors.green,
					window.chartColors.green,
					window.chartColors.green];
var _oborderColor=['rgba(54, 162, 235, 1)',
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
 
var _obackgroundColors2=[window.chartColors.purple,
					window.chartColors.purple,
					window.chartColors.purple,
					window.chartColors.purple,
					window.chartColors.purple,
					window.chartColors.purple,
					window.chartColors.purple,
					window.chartColors.purple,
					window.chartColors.purple,
					window.chartColors.purple,
					window.chartColors.purple,
					window.chartColors.purple,
					window.chartColors.purple,
					window.chartColors.purple]
var _oborderColor2=['rgba(255, 159, 64, 1)',
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
	
	var octx = document.getElementById('yearchartorders').getContext('2d');
	var omyChart = new Chart(octx, {
		type: 'bar',
		data: {
			labels: chartlabels,
			datasets: [{
				label: 'Order# this year',
				data: othisyeardata,
				backgroundColor: _obackgroundColors,
				borderColor: _oborderColor,
				borderWidth: 1
			},{
				label: 'Order# last year',
				data: olastyeardata,
				backgroundColor: _obackgroundColors2,
				borderColor: _oborderColor2,
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