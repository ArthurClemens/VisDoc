<#--

Creates a link if uri is passed, otherwise writes the name

-->
<#macro link linkData>
	<#if linkData.uri?? && linkData.uri?length gt 0>
		<a href="${linkData.uri}.html<#if linkData.memberName??>#${linkData.memberName}</#if>"><#if linkData.packagePath??><span class='packagePath'>${linkData.packagePath}</span></#if><#if linkData.name??>${linkData.name}</#if><#if link.attribute??><span>${link.attribute}</span></#if></a>
	<#else>
		${linkData.name}
	</#if>
</#macro>			
<#--

Creates a simple row: <tr><th>title</th><td>value</td></tr>

-->
<#macro classDataRow data>
	<tr>
		<th>${data.title}:</th>
		<td>${data.value}</td>
	</tr>
</#macro>
<#--

Description field with title and items

-->
<#macro descriptionField title items>
	<div class='field'>
		<span class='title'>${title}</span>
		<#if items??>
		<#list items as item>
			${item.value}
		</#list>
		</#if>
	</div>
</#macro>
<#--

Description field with title and items

-->
<#macro paramfield paramData>
	<div class='item'>
		<@keyvalue fieldData=paramData />
	</div>
</#macro>
<#macro keyvalue fieldData>
<#if fieldData.name??>
<span class='colorizedCode code'>${fieldData.name}<span class='itemSeparator'>:</span></span>
</#if>
<#if fieldData.description??>
${fieldData.description}
<#else>
&nbsp;
</#if>
<#if fieldData.access??>
<span class='access'>${fieldData.access}</span>
</#if>
</#macro>
<#--

-->
<#macro metadatatags><#-- TODO: create macro metadatatags --></#macro>
<#--

Field within box

-->
<#macro field data>
	<div class='boxedElem'>
		<div class='contentHolder'>
			<span class='title'>${data.title}</span>
	<#if data.paramfield??>
			<@paramfield paramData=data.paramfield/>
	<#else>
			<div class='item'>
		<#if data.description.item??>
			<ul>
				<#list data.description.item as item>
				<li>
					<#if item.value??>${item.value}</#if>
					<#if item.summary??>
						<ul class='summary inheritDoc'>
							<li>
								${item.value}
							</li>
						</ul>
					</#if>
				</li>
				</#list>
			</ul>
		</#if>
			</div>
			<@metadatatags />
	</#if>
		</div>
	</div>
</#macro>
<#--

-->
<#assign tmplClassData_classDetails>
<#list classData.classDetails.item as i>
	<tr>
		<th class='classDetails'>${i.title}:</th>
		<td class='classDetails'>${i.value}</td>
	</tr>
</#list>
</#assign>
<#--

-->
<#macro classDataLinkList data>
	<tr>
		<th>${data.title}:</th>
		<td>
			<ul>
				<#list data.item as x>
				<li><@link linkData=x.link /></li>
				</#list>
			</ul>
		</td>
	</tr>
</#macro>
<#--

-->
<#macro classDataHeaderRow data>
	<tr>
		<th colspan='2'>${data.title}</th>
	</tr>
</#macro>
<#--

-->
<#assign tmplClassData_sourceCode>
<div class='sourceCode'>
	<#if classData.sourceCode.viewSourceButton??>
			<span class='sourceCodeShow'><a href="#"><span class='closure'>&#9658;&nbsp;</span><span class='linkLabel'>${classData.sourceCode.viewSourceButton}</span></a></span><span class='sourceCodeHide'><a href="#"><span class='disclosure'>&#9660;&nbsp;</span><span class='linkLabel'>${classData.sourceCode.hideSourceButton}</span></a></span>
	</#if>
	<pre id="source" class="brush:<#if language='as2'>as3</#if><#if language='as3'>as3</#if><#if language='java'>java</#if>">${classData.sourceCode.sourceCodeText}</pre>
</div>
</#assign>
<#--

-->
<#assign tmplClassData_classDescription>
<div class='classDescription'>
<#if classData.classDescription.field??>
	<div class='fields'>
<#list classData.classDescription.field as x>
		<@descriptionField title=x.title items=x.description.item />
</#list>
	</div>
</#if>
<#if classData.classDescription.summary??>
	<span class='descriptionSummary'>${classData.classDescription.summary}</span>
</#if>
<#if classData.classDescription.restOfDescription??>
	${classData.classDescription.restOfDescription}
</#if>
<#if classData.field??>
	<div class='classFields'>
		<div class='boxWithBorder'>
			<#list classData.field as field>
				<@field data=field />
			</#list>
		</div>
	</div>
</#if>
</div>
</#assign>
<#--

-->
<#assign tmplClassData>
<#if classData??>
	<div class='classProperties'>
		<table cellspacing='0'>
			<#if classData.kindOfClass??><@classDataRow data=classData.kindOfClass /></#if>
			<#if classData.enclosingClass??><@classDataHeaderRow data=classData.enclosingClass /></#if>
			<#if classData.package??><@classDataLinkList data=classData.package /></#if>
			<#if classData.packageTitle??><@classDataHeaderRow data=classData.packageTitle /></#if>
			<#if classData.inheritsFrom??><@classDataLinkList data=classData.inheritsFrom /></#if>
			<#if classData.conformsTo??><@classDataLinkList data=classData.conformsTo /></#if>
			<#if classData.implementedBy??><@classDataLinkList data=classData.implementedBy /></#if>
			<#if classData.subclasses??><@classDataLinkList data=classData.subclasses /></#if>
			<#if classData.dispatchedBy??><@classDataLinkList data=classData.dispatchedBy /></#if>
			<#if classData.classDetails??>${tmplClassData_classDetails}</#if>
		</table>
	</div>
	<#if classData.sourceCode??>${tmplClassData_sourceCode}</#if>
	<#if classData.classDescription??>${tmplClassData_classDescription}</#if>
</#if>
</#assign>
<#--

-->
<#assign tmplShowHidePrivate>
<li id='togglePrivateButton'>
	<@iconButton class="privateHide" icon="&times;" label="${meta.hidePrivate}" />
	<@iconButton class="privateShow" icon="+" label="${meta.showPrivate}" />
</li>
</#assign>
<#--

-->
<#macro iconButton class icon label>
<span class='${class}'><a href="#" class='jqButton jqButtonSmall'><span class='jqButtonIcon'>${icon}</span>${label}</a></span>
</#macro>
<#--

Creates summary block of inherited methods.
data: summaryInheritedMethods

-->
<#macro summaryInheritedMethods data>
<#if data??>
<div class='boxWithBorder<#if data.private?? && data.private==1> private</#if>'>
<#list data.fromClass as superclass>
	<div class='boxedElem'>
		<div class='contentHolder'>
			<span class='title'>${superclass.title.text} <span class='superclass'><@link linkData=superclass.title.link /></span></span>
			<div class='item inheritedList'>
			<#list superclass.item as member>
			<@link linkData=member.link />
			</#list>
			</div>
		</div>
	</div>
</#list>
</div>
</#if>
</#macro>
<#--

-->
<#assign tmplPageSummary>
<#if pageSummary?? && pageSummary.memberList??>
	<div class='toc'>
		<h2 id='${pageSummary.id}'>${pageSummary.title}</h2>
		<div class='docNav'>
			<ul>
				<#if pageSummary.memberList.showHideTypeInfo??>
					<li>
						<@iconButton class="typeInfoHide" icon="&times;" label="${pageSummary.memberList.showHideTypeInfo.hideTypeInfo}" />
						<@iconButton class="typeInfoShow" icon="+" label="${pageSummary.memberList.showHideTypeInfo.showTypeInfo}" />
					</li>
				</#if>
				<#if pageSummary.memberList.showHideSummaries??>
					<li>
						<@iconButton class="summariesHide" icon="&times;" label="${pageSummary.memberList.showHideSummaries.hideSummaries}" />
						<@iconButton class="summariesShow" icon="+" label="${pageSummary.memberList.showHideSummaries.showSummaries}" />
					</li>
				</#if>
			</ul>
			<div class='clear'></div>
		</div>
		<#if pageSummary.memberList.memberSummaryPart??>
		<div class='memberList'>
			<#list pageSummary.memberList.memberSummaryPart as part>
				<div class='memberSummaryPart<#if part.private?? && part.private==1> private</#if>'>
					<span class='title'>${part.title}</span>
					<ul>
						<#list part.item as item>
							<li class='<#if item.private?? && item.private==1>private</#if>'>								
								<a href="#${item.id}">${item.title}</a>
								<#if item.typeInfo.typeInfoString??>
								<span class='typeInfo'>${item.typeInfo.typeInfoString}</span>
								</#if>
								<#if item.typeInfo.summary??>
								<ul class='summary'>
									<li>${item.typeInfo.summary}</li>
								</ul>
								</#if>
							</li>
						</#list>
					</ul>
					<@summaryInheritedMethods data=part.inheritedMethods />
				</div>
			</#list>
		</div>
		</#if>
	</div>
</#if>
</#assign>
<#--

-->
<#assign tmplFooter>
<#if meta??>
<div id="footer">
	<div id="footerContent">
		<ul>
			<#if meta.footerText??>
			<li class="copyright">
				${meta.footerText}
			</li>
			</#if>
		</ul>
	</div>
</div>
</#if>
</#assign>
<#--

-->
<#macro tocList list>
<#if list??>
	<div class="list">
	<#if list.title??>
		${list.title}
	</#if>
	<#if list.listGroup??>
		<#list list.listGroup as group>
			<@tocListGroup groupData=group />
		</#list>
	</#if>
	</div>
</#if>
</#macro>
<#--

-->
<#macro listGroupItem itemData>
<#if itemData.link??>
	<@link linkData=itemData.link />
</#if>
<#if itemData.summary??>
	<ul class='summary'>
		<li>
			${itemData.summary}
		</li>
	</ul>
</#if>
</#macro>
<#--

-->
<#macro listItemId linkData><#if linkData.uri??>
menu_${linkData.uri}
<#elseif linkData.name??>
menu_${linkData.name}
</#if></#macro>
<#--

-->
<#macro listItemClass listData><#if listData.package??>package </#if><#if listData.interface??>interface </#if><#if listData.private??>private </#if></#macro>
<#--

-->
<#macro listItem listData><li<@listItemAttributes listData=listData />><@listGroupItem itemData=listData /></li></#macro>
<#--

-->
<#macro listItems groupData>listItems
<#if groupData.listGroupTitle.item??>
	<#list groupData.listGroupTitle.item as item>
		<@listItem listData=item />
	</#list>
<#else>
	<h2>${groupData.listGroupTitle}</h2>
</#if>
<#if groupData.listGroup??>
	<#list groupData.listGroup as group>
		<@tocListGroup groupData=group />
	</#list>
</#if>
</#macro>
<#--

-->
<#macro listItemAttributes listData><#if listData.link??> id='<@listItemId linkData=listData.link />'</#if> class='<@listItemClass listData=listData />'</#macro>
<#--

-->
<#macro tocListGroup groupData>
<ul<#if groupData.id??> id='${groupData.id}'</#if>>
	<#if groupData.listGroupTitle?? && groupData.listGroupTitle.item??>
	<li <@listItemAttributes listData=groupData.listGroupTitle.item[0] />>
	<#else>
	<li <@listItemAttributes listData=groupData />>
	</#if>
		<#if groupData.listGroupTitle??>
			<#if groupData.listGroupTitle.item??>
				<#list groupData.listGroupTitle.item as item>
					<@link linkData=item.link />
				</#list>
			<#else>
				<h2>${groupData.listGroupTitle}</h2>
			</#if>
		</#if>
		<#if groupData.item??>
			<#list groupData.item as item>
				<@listItem listData=item />
			</#list>
		</#if>
		<#if groupData.listGroup??>
			<#list groupData.listGroup as group>
				<@tocListGroup groupData=group />
			</#list>
		</#if>
	</li>
</ul>
</#macro>
<#--		
			
-->
<#assign tmplNavigation>
	<#if navigation??>
	<div id='sidebar'>
		<div id='clearHeaderLeft'></div> 
		<div id='sidebarContent'>
			<@tocList list=navigation.tocList />
			${tmplGlobalNav}
		</div>
	</div>
	<#elseif tocHtml??>
		${tocHtml}
	</#if>
</#assign>
<#--

-->
<#assign tmplGlobalNav>
	<#if navigation.globalNav??>
	<div class="globalNav">
		<#if navigation.globalNav.title??>
			<span class='item'>${navigation.globalNav.title}</span>
		</#if>
		<#if navigation.globalNav.item??>
			<ul>
				<#list navigation.globalNav.item as item>
					<li>
						<@listItem listData=item />
					</li>
				</#list>
			</ul>
		</#if>
	</div>
	</#if>
</#assign>
<#--

-->
<#assign tmplMemberSections>
	<#if memberSections??>
		<#list memberSection as section>
		<div class='memberSection<#if section.private?? && section.private=1> private</#if>'>
			<h2 id='${section.id}'>${section.title}</h2>
			<#list section.member as member>
				<div class='member<#if member.private?? && member.private=1> private</#if>' id='${member.id}'>
				<#if member.title.link??>
					<h3><@link linkData=member.title.link /></h3>
				<#else>
					<h3>${member.title}</h3>
				</#if>
					<#if member.fullMemberString??>
						<div class='fullMemberString'>
							<span class='code'>${member.fullMemberString.memberString}</span><#if member.fullMemberString.access??><span class='access'>(${member.fullMemberString.access})</span></#if>
						</div>
					</#if>
					<#if member.description??>
						<div class='description'>
						<#if member.description.field??>
							<div class='fields'>
							<#list member.description.field as field>
								<div class='field'>
									<span class='title'>${field.title}</span>
									<#if field.description.item??>
										<@descriptionField title=field.description.title items=field.description.item />
									<#else>
										<@descriptionField title=field.description.title />
									</#if>
								</div>
							</#list>
							</div>
						</#if>
						<#if member.description.text??>
							<p>${member.description.text}</p>
						</#if>
						</div>
					</#if>
					<#if member.field??>
					<div class='boxWithBorder'>
						<#list member.field as field>
							<@field data=field />
						</#list>
					</div>
					</#if>
				</div>
			</#list>
		</div>
		</#list>
	</#if>
</#assign>
<#--

HTML

-->
<#assign tmplHtmlDoc><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" encoding="${encoding}">
	<head>
		<title>${htmlTitle}</title>
<#if cssFile??><#list cssFile as css>
		<link rel="stylesheet" type="text/css" href="${css}" />
</#list></#if>
<#if jsFile??><#list jsFile?sort as js>
		<script type="text/javascript" src="${js}"></script>
</#list></#if>
	</head>
	<body<#if showNavigation??> class='isShowingNavigation'</#if> id='page_${pageClass}'>
	    <div id='page'> 
			<div id='wrapper'>
				<div id='outer'> 
					<div id='floatWrap'> 
						<div id='main'>
							<div id='clearHeaderCenter'></div> 
							<div id='mainContent'>
								<#if title??>
								<h1>${title}</h1>
								</#if>
								${tmplClassData}
								${tmplPageSummary}
								<@tocList list=tocList />
								${tmplMemberSections}
							</div>
						</div>
						${tmplNavigation}
					</div>
					<div class='clear'>&nbsp;</div> 
				</div>
			</div>
			<div id='header'>
				<div id='headerContentWrapper'>
					<div id='headerContent'>
						<ul id='headerButtons'>
							<#if showNavigation??>
								<li id='toggleTocButton'><a href="#"><span class='disclosure'>&#9660;</span><span class='closure'>&#9658;</span>Navigation</a></li>
							</#if>
							<#if meta.showPrivate??>${tmplShowHidePrivate}</#if>
						</ul>
					</div>
				</div>
			</div>
			${tmplFooter}
		</div>
     </body>
</html>
</#assign>
<#--


-->
<#if document??>${tmplHtmlDoc}
<#elseif navigation??>${tmplNavigation}
</#if>