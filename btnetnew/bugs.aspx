<%@ Page Language="C#" MasterPageFile="~/btnetui.Master" %>

<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="shortcut icon" href="favicon.ico">
    <title id="titl" runat="server">btnet bugs</title>
    <script type="text/javascript" src="bug_list.js"></script>


    <script>

        $(document).ready(function () {
            $('.filter').click(on_invert_filter)
            $('.filter_selected').click(on_invert_filter)
        })


        function on_query_changed() {
            var frm = document.getElementById(asp_form_id);
            frm.actn.value = "query";
            frm.submit();
        }        

    </script>

</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <% //security.write_menu3(Response, Util.get_setting("PluralBugLabel", "bugs")); %>

    <div class="align">

        <table class="table1">
            <tr>
                <td style="white-space:nowrap">
                    <% if (!security.user.adds_not_allowed)
                        { %>
                    <a href="edit_bug.aspx">
                        <img src="add.png" border="0" align="top">&nbsp;add new <% Response.Write(Util.get_setting("SingularBugLabel", "bug")); %></a>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<% } %>

                <td style="white-space:nowrap">
                    <asp:DropDownList ID="query" CssClass="form-control" style="width:auto;" runat="server" onchange="on_query_changed()">
                    </asp:DropDownList>

                <td style="white-space:nowrap">&nbsp;&nbsp;&nbsp;&nbsp;<a target="_blank" href="print_bugs.aspx">print list</a>
                <td style="white-space:nowrap">&nbsp;&nbsp;&nbsp;&nbsp;<a target="_blank" href="print_bugs2.aspx">print detail</a>
                <td style="white-space:nowrap">&nbsp;&nbsp;&nbsp;&nbsp;<a target="_blank" href="print_bugs.aspx?format=excel">export to excel</a>
                <td style="white-space:nowrap" align="right" width="100%">
                    <a target="_blank" href="btnet_screen_capture.exe">
                        <img src="camera.png" border="0" align="top">&nbsp;download screen capture utility</a>
        </table>
        <br>
        <%
            if (dv != null)
            {
                if (dv.Table.Rows.Count > 0)
                {
                    if (Util.get_setting("EnableTags", "0") == "1")
                    {
                        BugList.display_buglist_tags_line(Response, security);
                    }
                    display_bugs(false);
                }
                else
                {
                    Response.Write("<p>No ");
                    Response.Write(Util.get_setting("PluralBugLabel", "bugs"));
                    Response.Write(" yet.<p>");
                }
            }
            else
            {
                Response.Write("<div class=err>Error in query SQL: " + sql_error + "</div>");
            }
        %>
        <!-- #include file = "inc_bugs2.inc" -->
    </div>

    <% Response.Write(Application["custom_footer"]); %>
</asp:Content>



<script language="C#" runat="server">
    
    btnet.Security security;
    string qu_id_string = null;
    string sql_error = "";

    ///////////////////////////////////////////////////////////////////////
    void Page_Load(Object sender, EventArgs e)
    {

        Util.do_not_cache(Response);

        security = new Security();
        security.check_security(HttpContext.Current, Security.ANY_USER_OK);

        titl.InnerText = Util.get_setting("AppTitle", "BugTracker.NET") + " - "
            + Util.get_setting("PluralBugLabel", "bugs");


        if (!IsPostBack)
        {

            load_query_dropdown();

            if (Session["just_did_text_search"] == null)
            {
                do_query();
            }
            else
            {
                Session["just_did_text_search"] = null;
                dv = (DataView)Session["bugs"];
            }

        }
        else
        {

            // posting back a query change?
            // posting back a filter change?
            // posting back a sort change?

            if (actn.Value == "query")
            {
                qu_id_string = Convert.ToString(query.SelectedItem.Value);
                reset_query_state();
                do_query();
            }
            else
            {
                // sorting, paging, filtering, so don't go back to the database

                dv = (DataView)Session["bugs"];
                if (dv == null)
                {
                    do_query();
                }
                else
                {
                    if (actn.Value == "sort")
                    {
                        new_page.Value = "0";
                    }
                }
            }
        }

        select_query_in_dropdown();

        call_sort_and_filter_buglist_dataview();

        actn.Value = "";

    }


    ///////////////////////////////////////////////////////////////////////
    void select_query_in_dropdown()
    {

        // select drop down based on whatever query we ended up using
        if (qu_id_string != null)
        {
            foreach (ListItem li in query.Items)
            {
                if (li.Value == qu_id_string)
                {
                    li.Selected = true;
                    break;
                }
            }
        }

    }

    ///////////////////////////////////////////////////////////////////////
    void reset_query_state()
    {
        new_page.Value = "0";
        filter.Value = "";
        sort.Value = "-1";
        prev_sort.Value = "-1";
        prev_dir.Value = "ASC";
    }


    ///////////////////////////////////////////////////////////////////////
    void do_query()
    {
        // figure out what SQL to run and run it.

        string bug_sql = null;


        // From the URL
        if (qu_id_string == null)
        {
            // specified in URL?
            qu_id_string = Util.sanitize_integer(Request["qu_id"]);
        }

        // From a previous viewing of this page
        if (qu_id_string == null)
        {
            // Is there a previously selected query, from a use of this page
            // earlier in this session?
            qu_id_string = (string)Session["SelectedBugQuery"];
        }


        if (qu_id_string != null && qu_id_string != "" && qu_id_string != "0")
        {
            // Use sql specified in query string.
            // This is the normal path from the queries page.
            sql = @"select qu_sql from queries where qu_id = $quid";
            sql = sql.Replace("$quid", qu_id_string);
            bug_sql = (string)DbUtil.execute_scalar(sql);
        }

        if (bug_sql == null)
        {
            // This is the normal path after logging in.
            // Use sql associated with user
            sql = @"select qu_id, qu_sql from queries where qu_id in
			(select us_default_query from users where us_id = $us)";
            sql = sql.Replace("$us", Convert.ToString(security.user.usid));
            DataRow dr = DbUtil.get_datarow(sql);
            if (dr != null)
            {
                qu_id_string = Convert.ToString(dr["qu_id"]);
                bug_sql = (string)dr["qu_sql"];
            }
        }

        // As a last resort, grab some query.
        if (bug_sql == null)
        {
            sql = @"select top 1 qu_id, qu_sql from queries order by case when qu_default = 1 then 1 else 0 end desc";
            DataRow dr = DbUtil.get_datarow(sql);
            bug_sql = (string)dr["qu_sql"];
            if (dr != null)
            {
                qu_id_string = Convert.ToString(dr["qu_id"]);
                bug_sql = (string)dr["qu_sql"];
            }
        }

        if (bug_sql == null)
        {
            Response.Write("Error!. No queries available for you to use!<p>Please contact your BugTracker.NET administrator.");
            Response.End();
        }

        // Whatever query we used, select it in the drop down
        if (qu_id_string != null)
        {
            foreach (ListItem li in query.Items)
            {
                li.Selected = false;
            }
            foreach (ListItem li in query.Items)
            {
                if (li.Value == qu_id_string)
                {
                    li.Selected = true;
                    break;
                }
            }
        }


        // replace magic variables
        bug_sql = bug_sql.Replace("$ME", Convert.ToString(security.user.usid));

        bug_sql = Util.alter_sql_per_project_permissions(bug_sql, security);

        if (Util.get_setting("UseFullNames", "0") == "0")
        {
            // false condition
            bug_sql = bug_sql.Replace("$fullnames", "0 = 1");
        }
        else
        {
            // true condition
            bug_sql = bug_sql.Replace("$fullnames", "1 = 1");
        }

        // run the query
        DataSet ds = null;
        try
        {
            ds = DbUtil.get_dataset(bug_sql);
            dv = new DataView(ds.Tables[0]);
        }
        catch (System.Data.SqlClient.SqlException e)
        {
            sql_error = e.Message;
            dv = null;
        }


        // Save it.
        Session["bugs"] = dv;
        Session["SelectedBugQuery"] = qu_id_string;

        // Save it again.  We use the unfiltered query to determine the
        // values that go in the filter dropdowns.
        if (ds != null)
        {
            Session["bugs_unfiltered"] = ds.Tables[0];
        }
        else
        {
            Session["bugs_unfiltered"] = null;
        }

    }

    ///////////////////////////////////////////////////////////////////////
    void load_query_dropdown()
    {

        // populate query drop down
        sql = @"/* query dropdown */
select qu_id, qu_desc
from queries
where (isnull(qu_user,0) = 0 and isnull(qu_org,0) = 0)
or isnull(qu_user,0) = $us
or isnull(qu_org,0) = $org
order by qu_desc";

        sql = sql.Replace("$us", Convert.ToString(security.user.usid));
        sql = sql.Replace("$org", Convert.ToString(security.user.org));

        query.DataSource = DbUtil.get_dataview(sql);

        query.DataTextField = "qu_desc";
        query.DataValueField = "qu_id";
        query.DataBind();

    }


    string sql;
    System.Data.DataView dv;
    System.Data.DataSet ds_custom_cols = null;

    ///////////////////////////////////////////////////////////////////////
    void display_bugs(bool show_checkboxes)
    {
        BugList.display_bugs(
            show_checkboxes,
            dv,
            Response,
            security,
            new_page.Value,
            IsPostBack,
            ds_custom_cols,
            filter.Value);
    }

    void call_sort_and_filter_buglist_dataview()
    {
        string filter_val = filter.Value;
        string sort_val = sort.Value;
        string prev_sort_val = prev_sort.Value;
        string prev_dir_val = prev_dir.Value;


        BugList.sort_and_filter_buglist_dataview(dv, IsPostBack,
            actn.Value,
            ref filter_val,
            ref sort_val,
            ref prev_sort_val,
            ref prev_dir_val);

        filter.Value = filter_val;
        sort.Value = sort_val;
        prev_sort.Value = prev_sort_val;
        prev_dir.Value = prev_dir_val;

    }

    void btnGoto_Click(Object sender, EventArgs e)
    {
        
        Response.Redirect("http://localhost:49412/edit_bug.aspx?id=1");
    }

</script>
