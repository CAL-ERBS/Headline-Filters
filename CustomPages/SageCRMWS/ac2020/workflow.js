<%

	function getWorkflowScreen(entity, workFlowName, workFlowState) {

		if (isWorkflowDisabled(entity))
			return null;
		var _workflows = null;
		if (workFlowName == null) {
			_workflows = getEntityWorkflows(entity);
		} else {
			_workflows = getWorkflowByName(workFlowName, workFlowState);
		}

		if (_workflows.length == 0)
			return null;

		var res = JSON.clone(_FormScreenMetadata);
		res.name = "WorkflowScreen";
		res.title = CRM.GetTrans("Tables", "Workflow");
		res.title = capitalize(res.title);
		res.subheader = CRM.GetTrans("Tables", "Workflow");
		res.entity = "workflow";
		res.content = "";

		var formelm = JSON.clone(_MyFormElement);
		formelm.name = "workflow";
		formelm.caption = CRM.GetTrans("Tables", "Workflow");
		formelm.required = "Y";
		formelm.readonly = false;
		formelm.componentType = "MyFormSelect";

		for (var tt = 0; tt < _workflows.length; tt++) {
			var _workflowObj = _workflows[tt];
			if (tt == 0) {
				formelm.value = { "text": _workflowObj.work_description, "value": _workflowObj.work_workflowId }
			}
			var opt = {
				text: _workflowObj.work_description,
				value: _workflowObj.work_workflowId
			}
			formelm.options.push(opt);
		}
		//scripting options...
		var options = formelm.options;
		var user = getUserObject("and user_userid=" + CRM.GetContextInfo("user", "user_userid"));
		var team = new String(getTeam(user.user_primarychannelid));

		function setValue(val) {
			formelm.value = val;
		}
		//get the Workflowscript_ENTITY
		var _Workflowscript = GetWebConfigValue("Workflowscript_" + entity);
		if (_Workflowscript && _Workflowscript != "") {
			try {
				//now run our script
				eval(_Workflowscript);
			} catch (e) {
				//do nothing
			}
		}
		res.formElements.push(formelm);
		return res;
	}
function isWorkflowDisabled(entity) {
	entity = new String(entity);
	entity = entity.toLowerCase();

	if (!Defined(entity) && (entity != 'appointment') && (entity != 'appt')) {
		var table = getTableInfo(entity);
		if (!Defined(table.name)) {
			//log to CRM's logs
			LogtoCRMsLogs("(" + Request.ServerVariables("SCRIPT_NAME") + ")-isWorkflowDisabled-No valid Entity found, entity is " + entity);
			throw "No valid Entity found";
		}
	}

	if (entity == "cases")
		entity = "case";
	if (entity == "opportunity")
		entity = "oppo";
	if (entity == "leads")
		entity = "lead";

	var _sql = "select Parm_Value from Custom_SysParams where 9837=9837 and parm_name = 'workflow" + entity + "'";
	var _q1 = CRM.CreateQueryObj(_sql);
	_q1.SelectSQL();
	var _res = false;
	if (!_q1.eof) {
		if (_q1("Parm_Value") == "N")
			_res = true;
	}
	return _res;
}

function getEntityWorkflows(entity) {

	var WkRl_Entity = "'" + entity + "'";
	if (entity == 'case' || entity == 'cases')
		WkRl_Entity = "'case','cases'";

	var table = getTableInfo(entity);

	if (!Defined(entity) && (entity != 'appointment') && (entity != 'appt')) {
		if (!Defined(table.name)) {
			//log to CRM's logs
			LogtoCRMsLogs("(" + Request.ServerVariables("SCRIPT_NAME") + ")-getEntityWorkflows-No valid Entity found, entity is " + entity);
			throw "No valid Entity found";
		}
	}

	var _sql = "select Work_Description, Work_WorkflowId " +
		"from workflow " +
		"where 9836=9836 and Work_Enabled='Y' and Work_WorkflowId in (select distinct WkRl_WorkflowId " +
		"from WorkflowRules " +
		"where WkRl_RuleType='Pre' and WkRl_Enabled='Y' " +
		"and WkRl_Entity in (" + WkRl_Entity + ")) order by Work_Description asc";
	var _q1 = CRM.CreateQueryObj(_sql);
	//Response.Write(_sql);
	_q1.SelectSQL();
	var _res = [];
	while (!_q1.eof) {
		var _state = getWorkflowState(_q1("work_workflowId"));
		var _witem = {
			work_workflowId: _q1("work_workflowId"),
			work_description: _q1("work_description"),
			wkst_name: _state
		}
		if (_state != "")
			_res.push(_witem);
		_q1.NextRecord();
	}
	return _res;
}

//old method that only gets the first state and does not cope with multipe primary rules
function getWorkflowState(work_workflowId) {

	if (!isNumeric(work_workflowId)) {
		//log to CRM's logs
		LogtoCRMsLogs("(" + Request.ServerVariables("SCRIPT_NAME") + ")-getWorkflowState-No valid Workflow ID found, work_workflowId is " + work_workflowId);
		throw "No valid Workflow ID found";
	}

	var _sql = "select WkSt_Name " +
		"from WorkflowState " +
		"where 9835=9835 " +
		//" and (WkSt_IsEntryPoint is null or WkSt_IsEntryPoint='N') "+
		"and WkSt_WorkflowId=" + work_workflowId + " and WkSt_StateId in (select " +
		"WkTr_NextStateId " +
		"from vWorkflowTransitionsRules WITH (NOLOCK) where WkTr_WorkflowId=" + work_workflowId + " " +
		"and WkTr_NextStateId is not null " +
		"and WkRl_RuleType= 'New' " +
		"and WkRl_Enabled= 'Y' " +
		"and WkSt_IsEntryPoint= 'Y' " +
		")";
	var _q1 = CRM.CreateQueryObj(_sql);
	_q1.SelectSQL();
	var _res = "";
	if (!_q1.eof) {
		_res = _q1("WkSt_Name");
	}
	return _res;
}

function getWorkflowById(id) {
	if (!isNumeric(id)) {
		//log to CRM's logs
		LogtoCRMsLogs("(" + Request.ServerVariables("SCRIPT_NAME") + ")-getWorkflowById-No valid Workflow ID found, id is " + id);
		throw "No valid Workflow ID found";
	}
	var _sql = "select Work_Description, Work_WorkflowId " +
		"from workflow " +
		"where 9834=9834 and  Work_deleted is null and Work_WorkflowId=" + id;
	var _q1 = CRM.CreateQueryObj(_sql);
	_q1.SelectSQL();
	var _res = {
		work_workflowId: _q1("work_workflowId"),
		work_description: _q1("work_description"),
		wkst_name: _state
	}
	if (!_q1.eof) {
		var _state = getWorkflowState(_q1("work_workflowId"));
		_res.work_workflowId = _q1("work_workflowId");
		_res.work_description = _q1("work_description");
		_res.wkst_name = _state;
	}
	return _res;
}


function getWorkflowStateByName(sWorkFlowState, work_workflowId) {

	if (!isNumeric(work_workflowId)) {
		//log to CRM's logs
		LogtoCRMsLogs("(" + Request.ServerVariables("SCRIPT_NAME") + ")-getWorkflowStateByName-No valid Workflow ID found, work_workflowId is " + work_workflowId);
		throw "No valid Workflow ID found";
	}

	var _sql = "select WkSt_Name " +
		"from WorkflowState " +
		"where 9833=9833 and WkSt_Name='" + escapeSQL(sWorkFlowState) + "' AND  (WkSt_IsEntryPoint is null or WkSt_IsEntryPoint='N') " +
		"and WkSt_WorkflowId=" + work_workflowId + " and WkSt_StateId in (select " +
		"WkTr_NextStateId " +
		"from vWorkflowTransitionsRules WITH (NOLOCK) where WkTr_WorkflowId=" + work_workflowId + " " +
		"and WkTr_NextStateId is not null " +
		")";

	Glog("getWorkflowStateByName:" + _sql);

	var _q1 = CRM.CreateQueryObj(_sql);
	_q1.SelectSQL();
	var _res = "";
	if (!_q1.eof) {
		_res = _q1("WkSt_Name");
	}
	return _res;
}


function getWorkflowByName(sWorkFlowName, sWorkFlowState) {
	var _sql = "select Work_Description, Work_WorkflowId " +
		"from workflow " +
		"where 9832=9832 and Work_Description='" + escapeSQL(sWorkFlowName) + "' and Work_Enabled='Y' and Work_Deleted is null";
	Glog("getWorkflowByName:" + _sql);

	var _q1 = CRM.CreateQueryObj(_sql);
	_q1.SelectSQL();
	var _res = [];
	var wObj = {};

	if (!_q1.eof) {
		var _state = getWorkflowStateByName(sWorkFlowState, _q1("work_workflowId"));
		wObj.work_workflowId = _q1("work_workflowId");
		wObj.work_description = _q1("work_description");
		wObj.wkst_name = _state;
		if (_state != "")
			_res.push(wObj);
	}
	return _res;
}

//WORKFLOW2.0 for AC methods
function getWorkflowPrimaryRules22(WkRl_Table) {
	var _sql = "select WkRl_RuleId,WkRl_WorkflowId,WkRl_Caption from vWorkflowRules  " +
		" where 9831=9831 and WkRl_Table='" + escapeSQL(WkRl_Table) + "' " +
		" and WkRl_RuleType='New' " +
		" and WkRl_Enabled='Y' " +
		" and WkRl_WorkflowId in (select distinct WkRl_WorkflowId  " +
		" from WorkflowRules where WkRl_RuleType='Pre' and WkRl_Enabled='Y'  " +
		" and WkRl_Entity='" + escapeSQL(WkRl_Table) + "') " +
		" and WkRl_WorkflowId in (select Work_WorkflowId from Workflow where Work_Enabled='Y')" +
		" order by WkRl_Order";
	Glog("getWorkflowPrimaryRules:" + _sql);

	var _q1 = CRM.CreateQueryObj(_sql);
	_q1.SelectSQL();
	var _res = [];
	while (!_q1.eof) {
		var wObj = {};
		wObj.workflowId = _q1("WkRl_WorkflowId");
		wObj.tablename = WkRl_Table;
		wObj.ruleId = _q1("WkRl_RuleId");
		wObj.caption = CRM.GetTrans("GenCaptions", _q1("WkRl_Caption"));
		wObj.nextstateid = getWorkflowTransition22(_q1("WkRl_WorkflowId"), _q1("WkRl_RuleId"));
		wObj.state = getWorkflowState22(_q1("WkRl_WorkflowId"), wObj.nextstateid);
		_res.push(wObj);
		_q1.NextRecord();
	}
	return _res;
}

function getWorkflowTransition22(work_workflowId, WkTr_RuleId) {

	if (!isNumeric(work_workflowId)) {
		//log to CRM's logs
		LogtoCRMsLogs("(" + Request.ServerVariables("SCRIPT_NAME") + ")-getWorkflowTransition22-No valid Workflow ID found, work_workflowId is " + work_workflowId);
		throw "No valid Workflow ID found";
	}

	WkTr_RuleId = "-1";//incorrect but quick fix as result not used yet in client app
	if ((!work_workflowId) || (work_workflowId != ""))
		work_workflowId = "-1";
	if ((!WkTr_RuleId) || (WkTr_RuleId != ""))
		WkTr_RuleId = "-1";
	var _sql = "select * from WorkflowTransition where 9830=9830 and WkTr_WorkflowId=" + work_workflowId +
		" and WkTr_RuleId =" + escapeSQL(WkTr_RuleId);
	var _q1 = CRM.CreateQueryObj(_sql);
	_q1.SelectSQL();
	var _res = "";
	if (!_q1.eof) {
		_res = _q1("WkTr_NextStateId");
	}
	return _res;
}
function getWorkflowState22(WkSt_WorkflowId, WkSt_StateId) {
	if (!isNumeric(WkSt_WorkflowId)) {
		//log to CRM's logs
		LogtoCRMsLogs("(" + Request.ServerVariables("SCRIPT_NAME") + ")-getWorkflowState22-No valid Workflow ID found, WkSt_WorkflowId is " + WkSt_WorkflowId);
		throw "No valid Workflow ID found";
	}

	WkSt_StateId = "-1";//incorrect but quick fix as result not used yet in client app
	if ((!WkSt_WorkflowId) || (WkSt_WorkflowId != ""))
		WkSt_WorkflowId = "-1";
	if ((!WkSt_StateId) || (WkSt_StateId != ""))
		WkSt_StateId = "-1";

	if (!isNumeric(WkSt_StateId)) {
		//log to CRM's logs
		LogtoCRMsLogs("(" + Request.ServerVariables("SCRIPT_NAME") + ")-getWorkflowState22-No valid Workflow State ID found, WkSt_StateId is " + WkSt_StateId);
		throw "No valid Workflow State ID found";
	}

	var _sql = "select WkSt_Name from WorkflowState where 9829=9829 and WkSt_WorkflowId=" + WkSt_WorkflowId + " and WkSt_StateId=" + WkSt_StateId;
	var _q1 = CRM.CreateQueryObj(_sql);
	_q1.SelectSQL();
	var _res = "";
	if (!_q1.eof) {
		_res = _q1("WkSt_Name");
	}
	return _res;
}

%>