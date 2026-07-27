<!-- #include file ="sagecrm.js" -->

<!-- #include file ="helpers.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="selectentity.js" -->
<%
    var u = CRM.FindRecord("Users, vUsers", "user_logon='" + escapeSQL(Request.Form("username")) + "'");
    var user = {};

    var e = new Enumerator(u); 
    while (!e.atEnd()) {
        var i = e.item();
        user[i.toLowerCase()] = u(i);
        e.moveNext();
    }


    var mobileMenuName = 'UserMobileNav';
    var tabs = CRM.FindRecord("Custom_Tabs", "tabs_entity='"+mobileMenuName+"'");
    tabs.OrderBy = 'tabs_order ASC';
    var navItems = [];
    var route;
    var hasViewPermision = true;
    
    while(!tabs.eof) {
        addToNav = true;
        var path1 = new String(tabs.tabs_customfilename).toLowerCase();    
        route = "/"+ path1; 
        if (path1 == 'entity') {
            var entity = new String(tabs.tabs_customfunction).toLowerCase();
            var btn = CRM.Button("My button","MyImage.gif", CRM.Url("MyPage.asp"), entity, "VIEW");
            var addToNav = Defined(btn) && btn != ""            
            route += "/" + (Defined(tabs.tabs_customfunction) ? tabs.tabs_customfunction : '' );
        }

        if (addToNav) {
            navItems.push({ title: CRM.GetTrans("GetCaptions", tabs.tabs_caption), route: route,  icon: tabs.tabs_WhereSql, button: r });
        }
        tabs.nextRecord();
    }

    var permissions = ['view', 'edit', 'insert', 'delete']
    var userPermissions = {};
    var primaryTables = [];
    var checkEntitiesRecords = CRM.FindRecord("Custom_Tables", "Bord_PrimaryTable='Y'");
    checkEntitiesRecords.OrderBy = "Bord_Caption ASC";
    while(!checkEntitiesRecords.eof) {
        primaryTables.push(new String(checkEntitiesRecords.bord_caption).toLowerCase());
        checkEntitiesRecords.NextRecord();
    }

    //get permission per entity     
    for (var j=0; j < primaryTables.length; j++) {
        permissionObject = {};
        for (var i=0; i < permissions.length; i++) {
            var r = CRM.Button("My button","MyImage.gif", CRM.Url("MyPage.asp"), primaryTables[j], permissions[i]);
            permissionObject[permissions[i]] =  Defined(r) && r != "";  
        }

        userPermissions[primaryTables[j]] = permissionObject;
    }
    user["id"]  = u.RecordId;
    user["fcmToken"] = Defined(u("user_ct_fcmtoken")) ? u("user_ct_fcmtoken") : "";
    var result = { user: user, navItems : navItems, permissions : userPermissions };
    Response.Write(JSON.stringify(result));
%>