<%@ Page Language="vb" Trace="False" AutoEventWireup="false" debug="true" %>
<%@ Import Namespace="System.Data" %>

<script language="vb" runat="server">

    Private sSite As SearchDotnet.Searchs.UserSearch

    '*********************************************************************
    '
    ' Page_Load event
    '
    ' Add code to this event.
    '
    '*********************************************************************
    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        If IsNothing(sSite) Then
            sSite = Session("Site")
        End If
    End Sub

    '*********************************************************************
    '
    ' srchbtn_Click event
    '
    ' Add code to this event.
    '
    '*********************************************************************
    Private Sub srchbtn_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) 
        Dim strSearchWords As String
        'If there is no words entered by the user to search for then dont carryout the file search routine
        pnlSearchResults.Visible = False
        strSearchWords = Trim(Request.Params("search"))

        If Not strSearchWords.Equals("") Then
            SearchDotnet.Searchs.Site.ApplicationPath = String.Format("http://{0}{1}", Request.ServerVariables("HTTP_HOST"), Request.ApplicationPath)
            sSite = SearchSite(strSearchWords)
            Session("Site") = sSite
            dgrdPages.CurrentPageIndex = 0
            DisplayContent()

        End If
    End Sub

    '*********************************************************************
    '
    ' SearchSite method
    '
    ' The  sSite.PageDataset is used to populate the datagrid.
    '
    '*********************************************************************
    Private Function SearchSite(ByVal strSearch As String) As SearchDotnet.Searchs.UserSearch
        Dim srchSite As SearchDotnet.Searchs.UserSearch
        srchSite = New SearchDotnet.Searchs.UserSearch()
        'Read in all the search words into one variable
        srchSite.SearchWords = strSearch

        If Phrase.Checked Then
            srchSite.SearchCriteria = SearchDotnet.Searchs.SearchCriteria.Phrase
        ElseIf AllWords.Checked Then
            srchSite.SearchCriteria = SearchDotnet.Searchs.SearchCriteria.AllWords
        ElseIf AnyWords.Checked Then
            srchSite.SearchCriteria = SearchDotnet.Searchs.SearchCriteria.AnyWords
        End If
		srchSite.Search(Server.MapPath("./"))
        Return srchSite
    End Function

    '*********************************************************************
    '
    ' DisplayContent method
    '
    ' The  data is bound to the respective fields.
    '
    '*********************************************************************
    Private Sub DisplayContent()
        If Not IsNothing(sSite.PageDataset) Then
            pnlSearchResults.Visible = True
            lblSearchWords.Text = sSite.SearchWords

            If ViewState("SortExpression") Is Nothing Then
                ViewState("SortExpression") = "MatchCount Desc"
            End If

            BindDataGrid(ViewState("SortExpression"))
            lblTotalFiles.Text = sSite.TotalFilesSearched
            lblFilesFound.Text = sSite.TotalFilesFound
        End If
    End Sub

    '*********************************************************************
    '
    ' BindDataGrid method
    '
    ' The  sSite.PageDataset is used to populate the datagrid.
    '
    '*********************************************************************
    Private Sub BindDataGrid(ByVal strSortField As String)
        Dim dvwPages As DataView
        dvwPages = sSite.PageDataset.Tables("Pages").DefaultView
        dvwPages.Sort = strSortField
        dgrdPages.DataSource = dvwPages
        dgrdPages.DataBind()
    End Sub

    
    '*********************************************************************
    '
    ' dgrdPages_PageIndexChanged event
    '
    ' The CurrentPageIndex is Assigned the page index value.
    ' The datagrid is then populated using the BindDataGrid function.
    '
    '*********************************************************************
    Private Sub dgrdPages_PageIndexChanged(ByVal s As Object, ByVal e As DataGridPageChangedEventArgs) 
        dgrdPages.CurrentPageIndex = e.NewPageIndex
		If IsNothing(sSite) Then
            sSite = Session("Site")
        End If
        DisplayContent()
    End Sub

    '*********************************************************************
    '
    ' DisplayTitle method
    '
    ' Display title of searched pages 
    '
    '*********************************************************************
    Private Function DisplayTitle(ByVal Title As String, ByVal Path As String) As String
        Return String.Format("<A href='{1}'>{0}</a>", Title, Path)
    End Function

    '*********************************************************************
    '
    ' DisplayPath method
    '
    ' Path of the file is returned 
    '
    '*********************************************************************
    Private Function DisplayPath(ByVal Path As String) As String
        Return String.Format("{0}{1}/{2}", Request.ServerVariables("HTTP_HOST"), Request.ApplicationPath, Path)
    End Function

    Protected Sub dgrdPages_SelectedIndexChanged(sender As Object, e As EventArgs)

    End Sub
</script>
<HTML>
	<HEAD>
		<title>Search the Website</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<meta content="Search the web site for pages or information that you are after" name="description">
		<!-- Check the from is filled in correctly before submitting -->
		<script language="JavaScript">
<!-- Hide from older browsers...


//Check the form before submitting
function CheckForm () {

	//Check for a word to search
    if (document.frmSiteSearch.search.value == "")
    {
		alert("Please enter at least one keyword to search");
		document.frmSiteSearch.search.focus();
		return false;
	}
	
	return true
}
function IMG1_onclick() {

}

// -->
		</script>
		<LINK href="CSS/SearchSite.css" type="text/css" rel="stylesheet">
	</HEAD>
	<body bgColor="#ffffff" text="#000000" link="#0000cc" vLink="#0000cc" aLink="#ff0000" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr>
							<td width="77%" style="height: 120px"><img src="searchimages/search-top.jpg" width="777" height="120" id="IMG1" onclick="return IMG1_onclick()"></td>
							<td width="23%" valign="bottom" style="height: 120px"><img src="searchimages/search--word.jpg" width="205" height="35"></td>
						</tr>
						<tr>
							<td height="1" colspan="2" bgcolor="#ecdfbc"></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<form id="frmSiteSearch" name="frmSiteSearch" runat="server">
			<table cellSpacing="0" cellPadding="0" width="90%" align="center">
				<tr>
					<td vAlign="center" align="right" width="165" height="66" rowSpan="3">&nbsp;
					</td>
					<td vAlign="center" align="right" width="15" height="66" rowSpan="3">&nbsp;</td>
					<td width="571" height="4">Search the Web Site:
					</td>
				</tr>
				<tr>
					<td width="571" height="2"><asp:textbox id="Search" runat="server" CssClass="Textbox"></asp:textbox>&nbsp;
						<asp:button id="srchbtn" runat="server" CssClass="Button" Text="Search >>" onclick="srchbtn_Click"></asp:button></td>
				</tr>
				<tr>
					<td vAlign="top" width="571" height="34">Search On :
						<asp:radiobutton id="AllWords" runat="server" Text="All Words " Checked="True" GroupName="mode"></asp:radiobutton><asp:radiobutton id="AnyWords" runat="server" Text="Any Words " GroupName="mode"></asp:radiobutton><asp:radiobutton id="Phrase" runat="server" Text="Phrase" GroupName="mode"></asp:radiobutton></td>
				</tr>
			</table>
            &nbsp;
			<asp:panel id="pnlSearchResults" runat="server" Visible="False">
				<TABLE class="SearchStatus" cellSpacing="1" cellPadding="1" width="98%" align="center" border="0">
					<TR>
						<TD height="18">Searched the site for
							<asp:Label id="lblSearchWords" runat="server" Font-Bold="True"></asp:Label>.&nbsp;&nbsp;&nbsp;
							<asp:Label id="lblFilesFound" runat="server" Font-Bold="True">Label</asp:Label>&nbsp;Files 
							found</TD>
					</TR>
				</TABLE>
				<BR>
				<asp:DataGrid id="dgrdPages" CssClass="Grid" Runat="Server" CellPadding="0" ItemStyle-CssClass="GridItem" AlternatingItemStyle-CssClass="GridAlternatingItem" SelectedItemStyle-CssClass="GridSelectedItem" FooterStyle-CssClass="GridFooter" PagerStyle-CssClass="GridPager" HeaderStyle-CssClass="GridHeader" AllowSorting="True" AutoGenerateColumns="False" DataKeyField="PageId" PagerStyle-Mode="NumericPages" PageSize="10" AllowPaging="True" ShowHeader="False" BorderWidth="0" CellSpacing="0" Width="98%" HorizontalAlign="Center" OnPageIndexChanged="dgrdPages_PageIndexChanged" OnSelectedIndexChanged="dgrdPages_SelectedIndexChanged">
					<SelectedItemStyle CssClass="GridSelectedItem"></SelectedItemStyle>
					<AlternatingItemStyle CssClass="GridAlternatingItem"></AlternatingItemStyle>
					<ItemStyle CssClass="GridItem"></ItemStyle>
					<HeaderStyle CssClass="GridHeader"></HeaderStyle>
					<FooterStyle CssClass="GridFooter"></FooterStyle>
					<Columns>
						<asp:TemplateColumn>
							<ItemTemplate>
								<%# DisplayTitle(Container.DataItem( "Title" ),Container.DataItem( "Path" )) %>
								<br>
								<%# Container.DataItem( "Description" ) %>
								<br>
								<span class="Path">
									<%# String.Format("{0} - {1}kb", DisplayPath(Container.DataItem( "Path" )),Container.DataItem( "Size" )) %>
								</span>
								<br>
								<br>
							</ItemTemplate>
						</asp:TemplateColumn>
					</Columns>
					<PagerStyle CssClass="GridPager" Mode="NumericPages"></PagerStyle>
				</asp:DataGrid>
				<TABLE class="SearchStatus" cellSpacing="1" cellPadding="1" width="98%" align="center" border="0">
					<TR>
						<TD width="47%" height="18">&nbsp;Searched
							<asp:Label id="lblTotalFiles" runat="server" Font-Bold="True"></asp:Label>&nbsp;documents 
							in total.</TD>
						<TD align="right" width="53%" height="18"></TD>
					</TR>
				</TABLE>
			</asp:panel></form>
	</body>
</HTML>
