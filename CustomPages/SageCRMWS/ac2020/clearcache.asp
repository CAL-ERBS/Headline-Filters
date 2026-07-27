<%@ CodePage=65001 Language=JavaScript%>
<%
//clear cache

Application.Contents.RemoveAll();


if (Request.QueryString("autoclose")=="Y")
{
  Response.Write("<script>window.close();</script>");
}
Response.Write("Cache cleared");
Response.Write("<br>Please close this window.");
%>