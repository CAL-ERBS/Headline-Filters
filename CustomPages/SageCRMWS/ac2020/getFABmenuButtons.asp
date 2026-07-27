<!-- #include file ="sagecrm.js" -->

<!-- #include file ="helpers.js" -->
<%
var crmMenuName = "ctCustomFABActions";
    var tabs = CRM.FindRecord("Custom_Tabs", "Tabs_Entity='"+crmMenuName+"'");
    var res = [];
    while (!tabs.Eof) {
        var attrs = new String(tabs("tabs_WhereSQL")).split("#");
        res.push({"icon":attrs[0],"tooltip":tabs("tabs_CustomFileName"),"action":tabs("tabs_CustomFunction"),"color":attrs[1]});
        tabs.NextRecord();
    }
    res=JSON.stringify(res);
    Response.Clear();
    Response.AddHeader("Content-Type", "application/json");
    Response.Write(res);
    Response.End();
%>