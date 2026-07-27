<!-- #include file ="sagecrm.js" -->


<%    

//no longer used
so breaking with this code

    var id = Request.Form("id");
    var record = CRM.FindRecord("Communication", "comm_communicationid = " + id);
    var e = new Enumerator(record);
    while(!e.atEnd()) {
        field = e.item();
        if (Defined(Request.Form(field))) {
            record(field) = Request.Form(field);
        }
        e.moveNext();
    }
	
    var status = 'success';
    try {
	    record.SaveChangesNoTls();
	} catch(ex) {
        status = { "error" : ex.message }; 
    }
    var result = { "status" : status };
    Response.Write(JSON.stringify(result));

%>