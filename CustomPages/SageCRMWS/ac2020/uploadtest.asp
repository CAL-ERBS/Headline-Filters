<!-- #include file ="../sagecrm.js" -->
<%
....debug only
CurrentUser=CRM.GetContextInfo("selecteduser", "User_UserId");

container = CRM.GetBlock('container');

container.DisplayButton(Button_Default) = false;

var _url_upload=CRM.Url("sagecrmws/ac2020fupload.aspx");

_url_upload="https://dev2.crmtogether.com//CRM2021r1/CustomPages/sagecrmws/ac2020fupload.aspx?SID=173263338514726&F=&J=sagecrmws%2Fac2020fupload.aspx&id=10245&path=C:\\Program%20Files%20(x86)\\Sage\\CRM\\CRM2021r1\\Library\\\c\\crmtogether\\Comm874&type=text/plain";

CRM.AddContent("<div>");

CRM.AddContent("<form name=\"Upload\" enctype=\"multipart/form-data\" method=\"post\" action=\""+_url_upload+"\">");
CRM.AddContent("<div>Upload file: </div>");
CRM.AddContent("<div><INPUT TYPE=\"file\" NAME=\"file\" >");
CRM.AddContent("<input type=\"submit\" name=\"FileUpload\" value=\"Upload File\"></div>");
CRM.AddContent("</form>");
CRM.AddContent("</div>");

Response.Write(CRM.GetPage('acceleratortab'));

%>