<!-- #include file ="reportobjects.js" -->
<%
////////////////////////////////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////
var myreport= JSON.clone(_reportClass);
myreport.name="crmusers";
//title
myreport.title="CRM Users";

////////////////////////////////////////////////////////////////////////////////////////////
//data section sample
var _header=JSON.clone(_reportItem);
_header.name='rawheaderhtml';
_header.componenttype='html';
_header.element="div";
_header.data="<span style=\"background-Color:Gray\">"+CRM.GetTrans("TabNames","Users")+"</span>";
myreport.reportheader.push(_header);

////////////////////////////////////////////////////////////////////////////////////////////
//list/table sample
var userlist=JSON.clone(_reportItem);
userlist.name='userlist';
userlist.componenttype='list';
var quserlist=CRM.Findrecord("user,vusers","(User_Resource='False' or User_Resource is null) and (User_IsTemplate='N' or User_IsTemplate is null)");
userlist.data=getListSection(quserlist, "user", ["User_fullname","User_Department","User_MobilePhone","User_EmailAddress","User_Phone","User_Extension"]);
myreport.reportdetails.push(userlist);
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