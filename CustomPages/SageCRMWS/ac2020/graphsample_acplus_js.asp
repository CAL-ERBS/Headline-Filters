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
myreport.title="Sample Report";

////////////////////////////////////////////////////////////////////////////////////////////
//data section sample
var _header=JSON.clone(_reportItem);
_header.name='rawheaderhtml';
_header.componenttype='html';
_header.element="div";
_header.data="<span style=\"background-Color:red\">this is raw html in the header</span>";
myreport.reportheader.push(_header);

////////////////////////////////////////////////////////////////////////////////////////////
//chart example - doughnut
var _chartClass=JSON.clone(_reportItem);
_chartClass.name='chartexample';
_chartClass.componenttype='chart';
//now the chart data
var _chart={
	'type':'doughnut-chart'
}
_chart.centertext="450";
_chart.data= {
  labels: [
    'Red',
    'Blue',
    'Yellow'
  ],
  datasets: [{
    label: 'My First Dataset',
    data: [300, 50, 100],
    backgroundColor: [
      'rgb(255, 99, 132)',
      'rgb(54, 162, 235)',
      'rgb(255, 205, 86)'
    ],
    hoverOffset: 4
  }]
};
_chartClass.data=_chart;//assign to the data property of the reportItem
myreport.reportdetails.push(_chartClass);
////////////////////////////////////////////////////////////////////////////////////////////
//data section sample
var _companyboxlong=JSON.clone(_reportItem);
_companyboxlong.name='companyboxlong';
_companyboxlong.componenttype='screen';
var compid=Request.QueryString("id");
if (!isNumeric(compid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Company ID found, compid is "+compid);
  throw "No valid Company ID found";
}

var qCompany=CRM.Findrecord("company,vsummarycompany","comp_companyid="+compid);
var companyboxlong=getScreenSection("company",qCompany,"companyboxlong","Some title");
_companyboxlong.data=companyboxlong;
myreport.reportdetails.push(_companyboxlong);
////////////////////////////////////////////////////////////////////////////////////////////
//chart example - line
var _chartClass2=JSON.clone(_reportItem);
_chartClass2.name='chartexample2';
_chartClass2.componenttype='chart';
//now the chart data
var _chart2={
	'type':'line-chart'
}
var labels = ['Jan','Feb','Mar','Apr','May','Jun','Jul'];
_chart2.data = {
  labels: labels,
  datasets: [{
    label: 'My First Dataset',
    data: [65, 59, 80, 81, 56, 55, 40],
    fill: false,
    borderColor: 'rgb(75, 192, 192)',
    tension: 0.1
  }]
};
_chartClass2.data=_chart2;//assign to the data property of the reportItem
myreport.reportdetails.push(_chartClass2);
////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////
//chart example - pie
var _chartClass3=JSON.clone(_reportItem);
_chartClass3.name='chartexample2';
_chartClass3.componenttype='chart';
//now the chart data
var _chart3={
	'type':'pie-chart'
}
_chart3.data={
          datasets: [{
            data: [4,5,7,8,1],
            backgroundColor: ["rgba(255, 99, 132, 0.2)", "rgba(54, 162, 235, 0.2)", "rgba(255, 206, 86, 0.2)", "rgba(75, 192, 192, 0.2)", "rgba(153, 102, 255, 0.2)", "rgba(255, 159, 64, 0.2)"],
            borderColor: ["rgba(255,99,132,1)", "rgba(54, 162, 235, 1)", "rgba(255, 206, 86, 1)", "rgba(75, 192, 192, 1)", "rgba(153, 102, 255, 1)", "rgba(255, 159, 64, 1)"],
            borderWidth: 1
          }],
          labels: ["Logged","In Progress","Closed"]
        };
_chart3.props={};
_chartClass3.data=_chart3;//assign to the data property of the reportItem
myreport.reportdetails.push(_chartClass3);
////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////
//list/table sample
var samplelist=JSON.clone(_reportItem);
samplelist.name='samplelist';
samplelist.componenttype='list';
var qsamplelist=CRM.Findrecord("company,vsummarycompany","comp_companyid<"+compid);
samplelist.data=getListSection(qsamplelist, "company", ["comp_name","comp_website"]);
myreport.reportdetails.push(samplelist);
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
//data section sample
var _footer=JSON.clone(_reportItem);
_footer.name='rawfooterhtml';
_footer.componenttype='html';
_footer.element="div";
_footer.data="<span style=\"background-Color:blue\">this is raw html in the footer</span>";
myreport.reportfooter.push(_footer);

////////////////////////////////////////////////////////////////////////////////////////////



Response.Write(JSON.stringify(myreport));

%>