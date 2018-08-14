<input type=hidden name="new_page" id="new_page" runat="server" value="0" ClientIDMode="Static">
<input type=hidden name="actn" id="actn" runat="server" value="" ClientIDMode="Static">
<input type=hidden name="filter" id="filter" runat="server" value="" ClientIDMode="Static">
<input type=hidden name="sort" id="sort" runat="server" value="-1" ClientIDMode="Static">
<input type=hidden name="prev_sort" id="prev_sort" runat="server" value="-1" ClientIDMode="Static">
<input type=hidden name="prev_dir" id="prev_dir" runat="server" value="ASC" ClientIDMode="Static">
<input type=hidden name="tags" id="tags" value="" ClientIDMode="Static">

<script>
	var enable_popups = <% Response.Write(security.user.enable_popups ? "1" : "0"); %>;
	var asp_form_id = '<% Response.Write(Util.get_form_name()); %>';
</script>

<div id="popup" class="buglist_popup"></div>