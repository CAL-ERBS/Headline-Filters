<%@ CodePage=65001 Language=JavaScript%>
<!-- #include file ="sagecrmnolang.js" -->

<%

if (typeof JSON.clone !== "function") {
    JSON.clone = function(obj) {
        return JSON.parse(JSON.stringify(obj));
    };
}

var _reportClass={
			"name": "",
			"type":"report",
			"reportheader": {},
			"reportfooter": {},
			"reportdetails":[]
		}
		
var _chartClass={
  'name':'',
  'componenttype':'chart',
  'type':'doughnut-chart',
  'data': {
          datasets: [{
            data: [4],
            backgroundColor: ["rgba(255, 99, 132, 0.2)", "rgba(54, 162, 235, 0.2)", "rgba(255, 206, 86, 0.2)", "rgba(75, 192, 192, 0.2)", "rgba(153, 102, 255, 0.2)", "rgba(255, 159, 64, 0.2)"],
            borderColor: ["rgba(255,99,132,1)", "rgba(54, 162, 235, 1)", "rgba(255, 206, 86, 1)", "rgba(75, 192, 192, 1)", "rgba(153, 102, 255, 1)", "rgba(255, 159, 64, 1)"],
            borderWidth: 1
          }],
          labels: ["Logged"]
        },
  'props':{}
}	

var myreport= JSON.clone(_reportClass);
myreport.name="test101";
var mychart= JSON.clone(_chartClass);
myreport.reportdetails.push(mychart);

Response.Write(JSON.stringify(myreport));

%>