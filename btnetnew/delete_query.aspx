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

        security.check_security(HttpContext.Current, Security.ANY_USER_OK);

        if (IsPostBack)
        {
            // do delete here
            sql = @"delete queries where qu_id = $1";
            sql = sql.Replace("$1", Util.sanitize_integer(row_id.Value));
            DbUtil.execute_nonquery(sql);
            Server.Transfer("queries.aspx");
        }
        else
        {
            titl.InnerText = Util.get_setting("AppTitle", "BugTracker.NET") + " - "
                + "delete query";

            string id = Util.sanitize_integer(Request["id"]);

            sql = @"select qu_desc, isnull(qu_user,0) qu_user from queries where qu_id = $1";
            sql = sql.Replace("$1", id);

            DataRow dr = DbUtil.get_datarow(sql);

            if ((int)dr["qu_user"] != security.user.usid)
            {
                if (security.user.is_admin || security.user.can_edit_sql)
                {
                    // can do anything
                }
                else
                {
                    Response.Write("You are not allowed to delete this item");
                    Response.End();
                }
            }

            confirm_href.InnerText = "confirm delete of query: "
                    + Convert.ToString(dr["qu_desc"]);

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
    <title id="titl" runat="server">btnet delete query</title>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <% security.write_menu2(Response, "queries"); %>
    <a href="queries.aspx">back to queries</a>

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


