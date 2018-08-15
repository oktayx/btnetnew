<%@ Page Language="C#" MasterPageFile="~/btnetui.Master" %>

<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<script language="C#" runat="server">

    String sql;


    Security security;


    ///////////////////////////////////////////////////////////////////////
    void Page_Load(Object sender, EventArgs e)
    {

        Util.do_not_cache(Response);

        security = new Security();
        security.check_security(HttpContext.Current, Security.MUST_BE_ADMIN);

        msg.InnerText = "";

        if (!IsPostBack)
        {
            datatype.Items.Insert(0, new ListItem("char", "char"));
            datatype.Items.Insert(0, new ListItem("datetime", "datetime"));
            datatype.Items.Insert(0, new ListItem("decimal", "decimal"));
            datatype.Items.Insert(0, new ListItem("int", "int"));
            datatype.Items.Insert(0, new ListItem("nchar", "nchar"));
            datatype.Items.Insert(0, new ListItem("nvarchar", "nvarchar"));
            datatype.Items.Insert(0, new ListItem("varchar", "varchar"));

            dropdown_type.Items.Insert(0, new ListItem("not a dropdown", ""));
            dropdown_type.Items.Insert(1, new ListItem("normal", "normal"));
            dropdown_type.Items.Insert(2, new ListItem("users", "users"));

            sort_seq.Value = "1";

        }
        else
        {
            on_update();
        }

    }


    ///////////////////////////////////////////////////////////////////////
    Boolean validate()
    {

        name_err.InnerText = "";
        length_err.InnerText = "";
        sort_seq_err.InnerText = "";
        default_err.InnerText = "";
        vals_err.InnerText = "";
        datatype_err.InnerText = "";
        required_err.InnerText = "";

        Boolean good = true;

        if (string.IsNullOrEmpty(name.Value))
        {
            good = false;
            name_err.InnerText = "Field name is required.";
        }
        else
        {
            if (name.Value.ToLower() == "url")
            {
                good = false;
                name_err.InnerText = "Field name of \"URL\" causes problems with ASP.NET.";
            }
            else if (name.Value.Contains("'")
            || name.Value.Contains("\\")
            || name.Value.Contains("/")
            || name.Value.Contains("\"")
            || name.Value.Contains("<")
            || name.Value.Contains(">"))
            {
                good = false;
                name_err.InnerText = "Some special characters like quotes, slashes are not allowed.";
            }
        }


        if (string.IsNullOrEmpty(length.Value))
        {
            if (datatype.SelectedItem.Value == "int"
            || datatype.SelectedItem.Value == "datetime")
            {
                // ok
            }
            else
            {
                good = false;
                length_err.InnerText = "Length or Precision is required for this datatype.";
            }
        }
        else
        {
            if (datatype.SelectedItem.Value == "int"
            || datatype.SelectedItem.Value == "datetime")
            {
                good = false;
                length_err.InnerText = "Length or Precision not allowed for this datatype.";
            }
        }


        if (required.Checked)
        {
            if (string.IsNullOrEmpty(default_text.Value))
            {
                good = false;
                default_err.InnerText = "If \"Required\" is checked, then Default is required.";
            }

            if (dropdown_type.SelectedItem.Value != "")
            {
                good = false;
                required_err.InnerText = "Checking \"Required\" is not compatible with a normal or users dropdown";
            }

        }


        if (dropdown_type.SelectedItem.Value == "normal")
        {
            if (string.IsNullOrEmpty(vals.Value))
            {
                good = false;
                vals_err.InnerText = "Dropdown values are required for dropdown type of \"normal\".";
            }
            else
            {
                string vals_error_string = Util.validate_dropdown_values(vals.Value);
                if (!string.IsNullOrEmpty(vals_error_string))
                {
                    good = false;
                    vals_err.InnerText = vals_error_string;
                }
                else
                {
                    if (datatype.SelectedItem.Value == "int"
                    || datatype.SelectedItem.Value == "decimal"
                    || datatype.SelectedItem.Value == "datetime")
                    {
                        good = false;
                        datatype_err.InnerText = "For a normal dropdown datatype must be char, varchar, nchar, or nvarchar.";
                    }
                }
            }

        }
        else if (dropdown_type.SelectedItem.Value == "users")
        {
            if (datatype.SelectedItem.Value != "int")
            {
                good = false;
                datatype_err.InnerText = "For a users dropdown datatype must be int.";
            }
        }


        if (dropdown_type.SelectedItem.Value != "normal")
        {
            if (vals.Value != "")
            {
                good = false;
                vals_err.InnerText = "Dropdown values are only used for dropdown of type \"normal\".";
            }
        }


        if (string.IsNullOrEmpty(sort_seq.Value))
        {
            good = false;
            sort_seq_err.InnerText = "Sort Sequence is required.";
        }
        else
        {
            if (!Util.is_int(sort_seq.Value))
            {
                good = false;
                sort_seq_err.InnerText = "Sort Sequence must be an integer.";
            }
        }


        return good;
    }

    ///////////////////////////////////////////////////////////////////////
    void on_update()
    {

        Boolean good = validate();

        if (good)
        {
            sql = @"
alter table orgs add [og_$nm_field_permission_level] int null
alter table bugs add [$nm] $dt $ln $null $df";

            sql = sql.Replace("$nm", name.Value);
            sql = sql.Replace("$dt", datatype.SelectedItem.Value);

            if (length.Value != "")
            {
                if (length.Value.StartsWith("("))
                {
                    sql = sql.Replace("$ln", length.Value);
                }
                else
                {
                    sql = sql.Replace("$ln", "(" + length.Value + ")");
                }
            }
            else
            {
                sql = sql.Replace("$ln", "");
            }

            if (default_text.Value != "")
            {
                if (default_text.Value.StartsWith("("))
                {
                    sql = sql.Replace("$df", "DEFAULT " + default_text.Value);
                }
                else
                {
                    sql = sql.Replace("$df", "DEFAULT (" + default_text.Value + ")");
                }
            }
            else
            {
                sql = sql.Replace("$df", "");
            }


            if (required.Checked)
            {
                sql = sql.Replace("$null", "NOT NULL");
            }
            else
            {
                sql = sql.Replace("$null", "NULL");
            }

            bool alter_table_worked = false;
            try
            {
                DbUtil.execute_nonquery(sql);
                alter_table_worked = true;
            }
            catch (Exception e2)
            {
                msg.InnerHtml = "The generated SQL was invalid:<br><br>SQL:&nbsp;" + sql + "<br><br>Error:&nbsp;" + e2.Message;
                alter_table_worked = false;
            }

            if (alter_table_worked)
            {
                sql = @"declare @colorder int

				select @colorder = sc.colorder
				from syscolumns sc
				inner join sysobjects so on sc.id = so.id
				where so.name = 'bugs'
				and sc.name = '$nm'

				insert into custom_col_metadata
				(ccm_colorder, ccm_dropdown_vals, ccm_sort_seq, ccm_dropdown_type)
				values(@colorder, N'$v', $ss, '$dt')";


                sql = sql.Replace("$nm", name.Value);
                sql = sql.Replace("$v", vals.Value.Replace("'", "''"));
                sql = sql.Replace("$ss", sort_seq.Value);
                sql = sql.Replace("$dt", dropdown_type.SelectedItem.Value.Replace("'", "''"));

                DbUtil.execute_nonquery(sql);
                Application["custom_columns_dataset"] = null;
                Server.Transfer("customfields.aspx");
            }

        }
        else
        {
            msg.InnerText = "Custom field was not created.";
        }

    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title id="titl" runat="server">btnet add custom field</title>

    <!--
Copyright 2002-2011 Corey Trager
Distributed under the terms of the GNU General Public License
-->
    <!-- #include file = "inc.aspx" -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <% security.write_menu2(Response, "admin"); %>
    <a href="customfields.aspx">back to custom fields</a>
    <table class="table">

        <tr>
            <td colspan="3">
                <div class="well smallnote">Don't use single quotes, &gt;, or &lt; characters in the Field Name.</div>
            </td>
        </tr>

        <tr>
            <td class="lbl">Field Name:</td>
            <td>
                <input runat="server" type="text" class="form-control" id="name" maxlength="30" size="30"></td>
            <td runat="server" class="err" id="name_err">&nbsp;</td>
        </tr>

        <tr>
            <td colspan="3">&nbsp;
            </td>
        </tr>

        <tr>
            <td colspan="3" width="350">
                <div class="well smallnote">A dropdown type of "normal" uses the values specified in "Normal Dropdown Values"
	below. A dropdown type of "users" is filled with values from the users table. The
	same list that is used for "assigned to" will be used for a "user" dropdown.
                </div>
            </td>
        </tr>


        <tr>
            <td class="lbl">Dropdown Type:</td>
            <td>
                <asp:DropDownList ID="dropdown_type" CssClass="form-control" runat="server">
                </asp:DropDownList></td>
            <td>&nbsp</td>
        </tr>

        <tr>
            <td colspan="3">
                <div class="well smallnote">For "user" dropdown, select "int"</div>
            </td>
        </tr>

        <tr>
            <td class="lbl">Datatype:</td>
            <td>
                <asp:DropDownList ID="datatype" CssClass="form-control" runat="server">
                </asp:DropDownList>
            </td>
            <td nowrap runat="server" class="err" id="datatype_err">&nbsp;</td>
        </tr>

        <tr>
            <td colspan="3">
                <div class="well smallnote">
                    For text type fields like char, varchar, nvarchar, etc, specify max length.<br>
                    <br>
                    For decimal type, specify as A,B where A is the total number of digits and<br>
                    B is the number of those digits to the right of decimal point.<br>
                </div>
            </td>
        </tr>

        <tr>
            <td class="lbl">Length/Precision:</td>
            <td>
                <input runat="server" type="text" class="form-control" id="length" maxlength="6" size="6"></td>
            <td nowrap runat="server" class="err" id="length_err">&nbsp;</td>
        </tr>

        <tr>
            <td colspan="3">
                <div class="well smallnote">
                    If you specify required, you must supply a default.&nbsp;&nbsp;Don't forget the parenthesis.
                </div>
            </td>
        </tr>

        <tr>
            <td class="lbl">Required (NULL or NOT NULL):</td>
            <td>
                <asp:CheckBox runat="server" class="cb" ID="required" /></td>
            <td nowrap runat="server" class="err" id="required_err">&nbsp;</td>
        </tr>

        <tr>
            <td class="lbl">Default:</td>
            <td>
                <input runat="server" type="text" class="form-control" id="default_text" maxlength="30" size="30">

            </td>
            <td nowrap runat="server" class="err" id="default_err">&nbsp;</td>
        </tr>

        <tr>
            <td colspan="3">&nbsp;
            </td>
        </tr>

        <tr>
            <td colspan="3">
                <div class="well smallnote">Use the following if you want the custom field to be a "normal" dropdown.
	<br>
                    Create a pipe seperated list of values as shown below.
	<br>
                    No individiual value should be longer than the length of your custom field.
	<br>
                    Don't use commas, &gt;, &lt;, or quotes in the list of values.
	<br>
                    Line breaks for your readability are ok.
	<br>
                    Here are some examples:
	<br>
                    "1.0|1.1|1.2"
	<br>
                    "red|blue|green"
	<br>
                    It's ok to have one of the values be blank:<br>
                    "|red|blue|green"
                </div>
            </td>
        </tr>


        <tr>
            <td colspan="3">
                <div class="lbl">Normal Dropdown Values:</div>
                    <textarea runat="server" class="form-control" id="vals" rows="6"></textarea>
                    <span runat="server" class="err" id="vals_err">&nbsp;</span>
        </tr>

        <tr>
            <td colspan="3">
                <div class="well smallnote">Controls what order the custom fields display on the page.
                </div>
            </td>
        </tr>

        <tr>
            <td class="lbl">Sort Sequence:</td>
            <td>
                <input runat="server" type="text" class="form-control" id="sort_seq" maxlength="2" size="2"></td>
            <td runat="server" class="err" id="sort_seq_err">&nbsp;</td>
        </tr>

        <tr>
            <td colspan="3" align="left">
                <span runat="server" class="err" id="msg">&nbsp;</span>
            </td>
        </tr>

        <tr>
            <td colspan="2" align="center">
                <input runat="server" class="btn btn-info" type="submit" id="sub" value="Create">
                <td>&nbsp</td>
            </td>
        </tr>

    </table>
    <% Response.Write(Application["custom_footer"]); %>
</asp:Content>


