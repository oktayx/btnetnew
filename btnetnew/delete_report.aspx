<%@ Page language="C#" MasterPageFile="~/btnet.Master"%>
<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<title id="titl" runat="server">btnet delete report</title>
<link rel="StyleSheet" href="btnet.css" type="text/css">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<% security.write_menu2(Response, "reports"); %>
<p>
<div class=align>
<p>&nbsp</p>
<a href=reports.aspx>Back to reports</a>

<p>or<p>

<script>
function submit_form()
{
    var frm = document.forms[0];
    frm.submit();
    return true;
}

</script>
<a id="confirm_href" runat="server" href="javascript: submit_form()"></a>
<input type="hidden" id="row_id" runat="server">

</div>
<% Response.Write(Application["custom_footer"]); %>

</asp:Content>



<script language="C#" runat="server">

String sql;

Security security;

void Page_Init (object sender, EventArgs e) {ViewStateUserKey = Session.SessionID;}

///////////////////////////////////////////////////////////////////////
void Page_Load(Object sender, EventArgs e)
{

	Util.do_not_cache(Response);
	
	security = new Security();

	security.check_security( HttpContext.Current, Security.ANY_USER_OK_EXCEPT_GUEST);

	if (security.user.is_admin || security.user.can_edit_reports)
	{
		//
	}
	else
	{
		Response.Write ("You are not allowed to use this page.");
		Response.End();
	}

	if (IsPostBack)
	{
		// do delete here
		sql = @"
delete reports where rp_id = $1;
delete dashboard_items where ds_report = $1";
        sql = sql.Replace("$1", Util.sanitize_integer(row_id.Value));
		DbUtil.execute_nonquery(sql);
		Server.Transfer ("reports.aspx");
	}
	else
	{
		titl.InnerText = Util.get_setting("AppTitle","BugTracker.NET") + " - "
			+ "delete report";

		string id = Util.sanitize_integer(Request["id"] );

		sql = @"select rp_desc from reports where rp_id = $1";
		sql = sql.Replace("$1", id);

		DataRow dr = DbUtil.get_datarow(sql);

		confirm_href.InnerText = "confirm delete of report: "
				+ Convert.ToString(dr["rp_desc"]);

		row_id.Value = id;

	}

}

</script>