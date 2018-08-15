<%@ Page Language="C#" MasterPageFile="~/btnetui.Master" %>

<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<title id="titl" runat="server">btnet delete project</title>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<% security.write_menu2(Response, "admin"); %>
<p>
<div class=align>
<p>&nbsp</p>
<a href=projects.aspx>back to projects</a>

<p>or<p>

<script>
function submit_form()
{
    var frm = document.getElementById("aspnetForm");
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
	security.check_security( HttpContext.Current, Security.MUST_BE_ADMIN);

	if (IsPostBack)
	{
		// do delete here
		sql = @"delete projects where pj_id = $1";
        sql = sql.Replace("$1", Util.sanitize_integer(row_id.Value));
		DbUtil.execute_nonquery(sql);
		Server.Transfer ("projects.aspx");
	}
	else
	{
		titl.InnerText = Util.get_setting("AppTitle","BugTracker.NET") + " - "
			+ "delete project";

		string id = Util.sanitize_integer(Request["id"]);

		sql = @"declare @cnt int
			select @cnt = count(1) from bugs where bg_project = $1
			select pj_name, @cnt [cnt] from projects where pj_id = $1";
		sql = sql.Replace("$1", id);

		DataRow dr = DbUtil.get_datarow(sql);

		if ((int) dr["cnt"] > 0)
		{
			Response.Write ("You can't delete project \""
				+ Convert.ToString(dr["pj_name"])
				+ "\" because some bugs still reference it.");
			Response.End();
		}
		else
		{
			confirm_href.InnerText = "confirm delete of \""
				+ Convert.ToString(dr["pj_name"])
				+ "\"";

			row_id.Value = id;

		}

	}

}


</script>
