<!-- #include file ="sagecrm.js" -->
<!-- #include file ="json2.js" -->
<!-- #include file ="configreader.js" -->
<!-- #include file ="helpers.js" -->
<%
//file: SageCRMws/ac2020/crmgadgetdemo.asp

var thisSID = Request.QueryString("SID");
var dashboardid=6000;//need to get this from crm
var url = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() + "/" + sInstallName +
               "/InteractiveDashboard/InteractiveDashboard.asp?"+
			   "lpLayout_LayoutId="+dashboardid+
			   "&templateEditMode=false&workspaceOnLoad=openNothing&"+
			   "contextDashboardAction=1180"+
			   "&SID="+thisSID+"&contextEntityId=-1&contextRecordId=-1";
			   
%>
<script>
 window.location="<%=url%>";
 //$("body").css("overflow", "scroll");
</script>