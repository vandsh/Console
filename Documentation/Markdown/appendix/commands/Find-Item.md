# Find-Item 
 
Finds items using the Sitecore Content Search API. 
 
## Syntax 
 
Find-Item [-Index] &lt;String&gt; [-Criteria &lt;SearchCriteria[]&gt;] [-Where &lt;String&gt;] [-WhereValues &lt;Object[]&gt;] [-OrderBy &lt;String&gt;] [-First &lt;Int32&gt;] [-Last &lt;Int32&gt;] [-Skip &lt;Int32&gt;] 
 
 
## Detailed Description 
 
The Find-Item command searches for items using the Sitecore Content Search API. 
 
© 2010-2017 Adam Najmanowicz, Michael West. All rights reserved. Sitecore PowerShell Extensions 
 
## Parameters 
 
### -Index&nbsp; &lt;String&gt; 
 
Name of the Index that will be used for the search:

Find-Item -Index sitecore_master_index -First 10 
 
<table>
    <thead></thead>
    <tbody>
        <tr>
            <td>Aliases</td>
            <td></td>
        </tr>
        <tr>
            <td>Required?</td>
            <td>true</td>
        </tr>
        <tr>
            <td>Position?</td>
            <td>1</td>
        </tr>
        <tr>
            <td>Default Value</td>
            <td></td>
        </tr>
        <tr>
            <td>Accept Pipeline Input?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Accept Wildcard Characters?</td>
            <td>false</td>
        </tr>
    </tbody>
</table> 
 
### -Criteria&nbsp; &lt;SearchCriteria[]&gt; 
 
simple search criteria in the following example form:

@{
    Filter = "Equals";
    Field = "_templatename";
    Value = "PowerShell Script";
}, 
@{
    Filter = "StartsWith";
    Field = "_fullpath";
    Value = "/sitecore/system/Modules/PowerShell/Script Library/System Maintenance";
},
@{
    Filter = "DescendantOf";
    Value = (Get-Item "master:/system/Modules/PowerShell/Script Library/")
}

Where "Filter" is one of the following values:
- Equals
- StartsWith,
- Contains,
- EndsWith
- DescendantOf

Fields by which you can filter can be discovered using the following script:

Find-Item -Index sitecore_master_index `
          -Criteria @{Filter = "StartsWith"; Field = "_fullpath"; Value = "/sitecore/content/" } `
          -First 1 | 
    select -expand "Fields" 
 
<table>
    <thead></thead>
    <tbody>
        <tr>
            <td>Aliases</td>
            <td></td>
        </tr>
        <tr>
            <td>Required?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Position?</td>
            <td>named</td>
        </tr>
        <tr>
            <td>Default Value</td>
            <td></td>
        </tr>
        <tr>
            <td>Accept Pipeline Input?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Accept Wildcard Characters?</td>
            <td>false</td>
        </tr>
    </tbody>
</table> 
 
### -Where&nbsp; &lt;String&gt; 
 
Works on Sitecore 7.5 and later versions only.

Filtering Criteria using Dynamic Linq syntax: http://weblogs.asp.net/scottgu/dynamic-linq-part-1-using-the-linq-dynamic-query-library 
 
<table>
    <thead></thead>
    <tbody>
        <tr>
            <td>Aliases</td>
            <td></td>
        </tr>
        <tr>
            <td>Required?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Position?</td>
            <td>named</td>
        </tr>
        <tr>
            <td>Default Value</td>
            <td></td>
        </tr>
        <tr>
            <td>Accept Pipeline Input?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Accept Wildcard Characters?</td>
            <td>false</td>
        </tr>
    </tbody>
</table> 
 
### -WhereValues&nbsp; &lt;Object[]&gt; 
 
Works on Sitecore 7.5 and later versions only.

An Array of objects for Dynamic Linq "-Where" parameter as explained in: http://weblogs.asp.net/scottgu/dynamic-linq-part-1-using-the-linq-dynamic-query-library 
 
<table>
    <thead></thead>
    <tbody>
        <tr>
            <td>Aliases</td>
            <td></td>
        </tr>
        <tr>
            <td>Required?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Position?</td>
            <td>named</td>
        </tr>
        <tr>
            <td>Default Value</td>
            <td></td>
        </tr>
        <tr>
            <td>Accept Pipeline Input?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Accept Wildcard Characters?</td>
            <td>false</td>
        </tr>
    </tbody>
</table> 
 
### -OrderBy&nbsp; &lt;String&gt; 
 
Works on Sitecore 7.5 and later versions only.

Field by which the search results sorting should be performed. 
Dynamic Linq ordering syntax used.
http://weblogs.asp.net/scottgu/dynamic-linq-part-1-using-the-linq-dynamic-query-library 
 
<table>
    <thead></thead>
    <tbody>
        <tr>
            <td>Aliases</td>
            <td></td>
        </tr>
        <tr>
            <td>Required?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Position?</td>
            <td>named</td>
        </tr>
        <tr>
            <td>Default Value</td>
            <td></td>
        </tr>
        <tr>
            <td>Accept Pipeline Input?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Accept Wildcard Characters?</td>
            <td>false</td>
        </tr>
    </tbody>
</table> 
 
### -First&nbsp; &lt;Int32&gt; 
 
Number of returned search results. 
 
<table>
    <thead></thead>
    <tbody>
        <tr>
            <td>Aliases</td>
            <td></td>
        </tr>
        <tr>
            <td>Required?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Position?</td>
            <td>named</td>
        </tr>
        <tr>
            <td>Default Value</td>
            <td></td>
        </tr>
        <tr>
            <td>Accept Pipeline Input?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Accept Wildcard Characters?</td>
            <td>false</td>
        </tr>
    </tbody>
</table> 
 
### -Last&nbsp; &lt;Int32&gt; 
 
 
 
<table>
    <thead></thead>
    <tbody>
        <tr>
            <td>Aliases</td>
            <td></td>
        </tr>
        <tr>
            <td>Required?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Position?</td>
            <td>named</td>
        </tr>
        <tr>
            <td>Default Value</td>
            <td></td>
        </tr>
        <tr>
            <td>Accept Pipeline Input?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Accept Wildcard Characters?</td>
            <td>false</td>
        </tr>
    </tbody>
</table> 
 
### -Skip&nbsp; &lt;Int32&gt; 
 
Number of search results to be skipped skip before returning the results commences. 
 
<table>
    <thead></thead>
    <tbody>
        <tr>
            <td>Aliases</td>
            <td></td>
        </tr>
        <tr>
            <td>Required?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Position?</td>
            <td>named</td>
        </tr>
        <tr>
            <td>Default Value</td>
            <td></td>
        </tr>
        <tr>
            <td>Accept Pipeline Input?</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Accept Wildcard Characters?</td>
            <td>false</td>
        </tr>
    </tbody>
</table> 
 
## Outputs 
 
The output type is the type of the objects that the cmdlet emits. 
 
* Sitecore.ContentSearch.SearchTypes.SearchResultItem 
 
## Notes 
 
Help Author: Adam Najmanowicz, Michael West 
 
## Examples 
 
### EXAMPLE 1 
 
Fields by which filtering can be performed using the -Criteria parameter 
 
```powershell   
 
Find-Item -Index sitecore_master_index `
          -Criteria @{Filter = "StartsWith"; Field = "_fullpath"; Value = "/sitecore/content/" } `
          -First 1 | 
    select -expand "Fields" 
 
``` 
 
### EXAMPLE 2 
 
Find all children of a specific item including that item - return Sitecore items 
 
```powershell   
 
$root = Get-Item -Path "master:/system/Modules/PowerShell/Script Library/"
Find-Item -Index sitecore_master_index -Criteria @{Filter = "DescendantOf"; Value = $root.ID } | Initialize-Item
 
``` 
 
### EXAMPLE 3 
 
Find all Template Fields using Dynamic LINQ syntax 
 
```powershell   
 
Find-Item `
    -Index sitecore_master_index `
    -Where 'TemplateName = @0 And Language=@1' `
    -WhereValues "Template Field", "en" 
 
``` 
 
### EXAMPLE 4 
 
Find all Template Fields using the -Criteria parameter syntax 
 
```powershell   
 
Find-Item `
        -Index sitecore_master_index `
        -Criteria @{Filter = "Equals"; Field = "_templatename"; Value = "Template Field"},
                  @{Filter = "Equals"; Field = "_language"; Value = "en"} 
 
```

### EXAMPLE 5

Find the first 10 items in the master database Media Library with a non-empty "Alt" value.

```powershell
$root = Get-Item -Path "master:{3D6658D8-A0BF-4E75-B3E2-D050FABCF4E1}"
$criteria = @(
    @{ Filter = "DescendantOf"; Value = $root.ID }
    @{ Filter="Equals"; Value=""; Field="Alt"; Invert=$true }
)
Find-Item -Index sitecore_master_index -Criteria $criteria -First 10 
```

## Related Topics 
 

* [Initialize-Item](/appendix/commands/Initialize-Item.md)
* Get-Item
* Get-ChildItem
* <a href='https://gist.github.com/AdamNaj/273458beb3f2b179a0b6' target='_blank'>https://gist.github.com/AdamNaj/273458beb3f2b179a0b6</a><br/>
* <a href='http://weblogs.asp.net/scottgu/dynamic-linq-part-1-using-the-linq-dynamic-query-library' target='_blank'>http://weblogs.asp.net/scottgu/dynamic-linq-part-1-using-the-linq-dynamic-query-library</a><br/>
* <a href='https://github.com/SitecorePowerShell/Console/' target='_blank'>https://github.com/SitecorePowerShell/Console/</a><br/>
