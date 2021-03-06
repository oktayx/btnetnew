<%@ Page Language="C#" MasterPageFile="~/btnetui.Master" %>


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

	titl.InnerText = Util.get_setting("AppTitle","BugTracker.NET") + " - "
		+ "delete custom field";

	if (IsPostBack)
	{
		// do delete here

		sql = @"select sc.name [column_name], df.name [default_constraint_name]
			from syscolumns sc
			inner join sysobjects so on sc.id = so.id
			left outer join sysobjects df on df.id = sc.cdefault
			where so.name = 'bugs'
			and sc.colorder = $id";

        sql = sql.Replace("$id", Util.sanitize_integer(row_id.Value));
		DataRow dr = DbUtil.get_datarow(sql);

		// if there is a default, delete it
		if (dr["default_constraint_name"].ToString() != "")
		{
			sql = @"alter table bugs drop constraint [$df]";
			sql = sql.Replace("$df", (string) dr["default_constraint_name"]);
			DbUtil.execute_nonquery(sql);
		}


		// delete column itself
		sql = @"
alter table orgs drop column [og_$nm_field_permission_level]
alter table bugs drop column [$nm]";
		
		sql = sql.Replace("$nm", (string) dr["column_name"]);
		DbUtil.execute_nonquery(sql);


		//delete row from custom column table
		sql = @"delete from custom_col_metadata
		where ccm_colorder = $num";
        sql = sql.Replace("$num", Util.sanitize_integer(row_id.Value));
		
		Application["custom_columns_dataset"]  = null;
		DbUtil.execute_nonquery(sql);

		Response.Redirect("customfields.aspx");


	}
	else
	{
		string id = Util.sanitize_integer(Request["id"]);

		sql = @"select sc.name
			from syscolumns sc
			inner join sysobjects so on sc.id = so.id
			left outer join sysobjects df on df.id = sc.cdefault
			where so.name = 'bugs'
			and sc.colorder = $id";

		sql = sql.Replace("$id",id);
		DataRow dr = DbUtil.get_datarow(sql);

		confirm_href.InnerText = "confirm delete of \""
			+ Convert.ToString(dr["name"])
			+ "\"";

		row_id.Value = id;
	}

}

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!--
Copyright 2002-2011 Corey Trager
Distributed under the terms of the GNU General Public License
-->
<!-- #include file = "inc.aspx" -->
<title id="titl" runat="server">btnet delete customfield</title>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<% security.write_menu2(Response, "admin"); %>
<a href=customfields.aspx>back to custom fields</a>

<p>or</p>

<script>
function submit_form()
{
    var frm = document.forms[0];
    frm.submit();
    return true;
}

</script>
<a id="confirm_href" class="btn btn-danger" runat="server" href="javascript: submit_form()"></a>
<input type="hidden" id="row_id" runat="server">


    <% Response.Write(Application["custom_footer"]); %>
</asp:Content>


