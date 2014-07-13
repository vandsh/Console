﻿using System.Management.Automation;

using Sitecore.Data.Items;

namespace Cognifide.PowerShell.PowerShellIntegrations.Commandlets.Data
{
    [Cmdlet("Get", "ItemClone")]
    [OutputType(new[] { typeof(Item) }, ParameterSetName = new[] { "Item from Pipeline", "Item from Path", "Item from ID" })]
    public class GetItemCloneCommand : BaseItemCommand
    {
        protected override void ProcessItem(Item item)
        {
            WriteObject(item.GetClones());
        }
    }
}