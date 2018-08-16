<%@ Page Language="C#" MasterPageFile="~/btnetui.Master" %>



<script language="C#" runat="server">

    String sql;

    Security security;

    void Page_Init(object sender, EventArgs e) { ViewStateUserKey = Session.SessionID; }

    ///////////////////////////////////////////////////////////////////////
    void Page_Load(Object sender, EventArgs e)
    {

        Util.do_not_cache(Response);

        security = new Security();
        security.check_security(HttpContext.Current, Security.MUST_BE_ADMIN);

        if (IsPostBack)
        {
            // do delete here
            sql = @"delete priorities where pr_id = $1";
            sql = sql.Replace("$1", Util.sanitize_integer(row_id.Value));
            DbUtil.execute_nonquery(sql);
            Server.Transfer("priorities.aspx");
        }
        else
        {

            titl.InnerText = Util.get_setting("AppTitle", "BugTracker.NET") + " - "
                + "delete priority";

            string id = Util.sanitize_integer(Request["id"]);


            sql = @"declare @cnt int
			select @cnt = count(1) from bugs where bg_priority = $1
			select pr_name, @cnt [cnt] from priorities where pr_id = $1";
            sql = sql.Replace("$1", id);

            DataRow dr = DbUtil.get_datarow(sql);

            if ((int)dr["cnt"] > 0)
            {
                Response.Write("You can't delete priority \""
                    + Convert.ToString(dr["pr_name"])
                    + "\" because some bugs still reference it.");
                Response.End();
            }
            else
            {

                confirm_href.InnerText = "confirm delete of \""
                    + Convert.ToString(dr["pr_name"])
                    + "\"";

                row_id.Value = id;

            }

        }

    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!--
Copyright 2002-2011 Corey Trager
Distributed under the terms of the GNU General Public License
-->
<!-- #include file = "inc.aspx" -->
    <title id="titl" runat="server">btnet delete priority</title>
    <link rel="StyleSheet" href="btnet.css" type="text/css">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <% security.write_menu2(Response, "admin"); %>
    <a href="priorities.aspx">back to priorities</a>

    <p>or</p>

    <script>
        function submit_form() {
            var frm = document.forms[0];
            frm.submit();
            return true;
        }

    </script>
    <a id="confirm_href" class="btn btn-danger" runat="server" href="javascript: submit_form()"></a>
    <input type="hidden" id="row_id" runat="server">
    <% Response.Write(Application["custom_footer"]); %>
</asp:Content>


