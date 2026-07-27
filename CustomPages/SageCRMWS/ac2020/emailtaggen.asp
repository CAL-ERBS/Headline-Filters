<!-- #include file ="sagecrm.js" -->

<!-- #include file ="helpers.js" -->
<!-- #include file ="emailtaggen.js" -->
<%
//CustomPages/SageCRMWS/ac2020/emailtaggen.asp
var res=getEntityTag(entity, entityid);
res=JSON.stringify(res);
Response.Write(res);

%>