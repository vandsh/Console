#Requires -Version 3

Add-Type @"
using System.Net;
using System.IO;

public class WebClientWithResponse : WebClient
{
    // we will store the response here. We could store it elsewhere if needed.
    // This presumes the response is not a huge array...
    public byte[] Response { get; private set; }

    protected override WebResponse GetWebResponse(WebRequest request)
    {
        var response = base.GetWebResponse(request);
        var httpResponse = response as HttpWebResponse;
        if (httpResponse != null)
        {
            using (var stream = httpResponse.GetResponseStream())
            {
                using (var ms = new MemoryStream())
                {
                    stream.CopyTo(ms);
                    Response = ms.ToArray();
                }
            }
        }
        return response;
    }
}
"@

function Invoke-RemoteScript2 {
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = "InProcess")]
    param(
        
        [Parameter(ParameterSetName = 'InProcess')]
        [Parameter(ParameterSetName = 'Session')]
        [Parameter(ParameterSetName = 'Uri')]
        [scriptblock]$ScriptBlock,

        [Parameter(ParameterSetName = 'Session')]
        [ValidateNotNull()]
        [pscustomobject]$Session,

        [Parameter(ParameterSetName = 'Uri')]
        [Uri[]]$ConnectionUri,

        [Parameter(ParameterSetName = 'Uri')]
        [string]$SessionId,

        [Parameter(ParameterSetName = 'Uri')]
        [string]$Username,

        [Parameter(ParameterSetName = 'Uri')]
        [string]$Password,

        [Parameter(ParameterSetName = 'Uri')]
        [System.Management.Automation.PSCredential]
        $Credential,
        
        [Parameter()]
        [Alias("ArgumentList")]
        [hashtable]$Arguments,

        [Parameter(ParameterSetName = 'Session')]
        [switch]$AsJob
    )

    process {

        if ($PSCmdlet.MyInvocation.BoundParameters["WhatIf"].IsPresent) {
            $functionScriptBlock = {
                $WhatIfPreference = $true
            }
            $ScriptBlock = [scriptblock]::Create($functionScriptBlock.ToString() + $ScriptBlock.ToString());
        }
        $hasRedirectedMessages = $false
        if ($PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent -or $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
            $hasRedirectedMessages = $true
            $functionScriptBlock = {
                if ($PSVersionTable.PSVersion.Major -ge 5) {
                    function Write-Information {
                        param([string]$Message)
                        $InformationPreference = "Continue"
                        Microsoft.PowerShell.Utility\Write-Information -Message $Message 6>&1
                    }
                }
                function Write-Debug {
                    param([string]$Message)
                    $DebugPreference = "Continue"
                    Microsoft.PowerShell.Utility\Write-Debug -Message $Message 5>&1
                }
                function Write-Verbose {
                    param([string]$Message)
                    $VerbosePreference = "Continue"
                    Microsoft.PowerShell.Utility\Write-Verbose -Message $Message 4>&1
                }
                function Write-Warning {
                    param([string]$Message)
                    $WarningPreference = "Continue"
                    Microsoft.PowerShell.Utility\Write-Warning -Message $Message 3>&1
                }
                function Write-Error {
                    param([string]$Message)
                    $WarningPreference = "Continue"
                    Microsoft.PowerShell.Utility\Write-Error -Message $Message 2>&1
                }
            }
            $ScriptBlock = [scriptblock]::Create($functionScriptBlock.ToString() + $ScriptBlock.ToString());
        }

        if ($AsJob.IsPresent) {
            $nestedScript = $ScriptBlock.ToString()
            $ScriptBlock = [scriptblock]::Create("Start-ScriptSession -ScriptBlock { $($nestedScript) } -ArgumentList `$params | Select-Object -ExpandProperty ID")
        }

        $usingVariables = @(Get-UsingVariables -ScriptBlock $scriptBlock | 
                Group-Object -Property SubExpression | 
                ForEach {
                $_.Group | Select -First 1
            })
    
        $invokeWithArguments = $false        
        if ($usingVariables.count -gt 0) {
            $usingVar = $usingVariables | Group-Object -Property SubExpression | ForEach {$_.Group | Select -First 1}  
            Write-Debug "CommandOrigin: $($MyInvocation.CommandOrigin)"      
            $usingVariableValues = Get-UsingVariableValues -UsingVar $usingVar
            $invokeWithArguments = $true
        }
  
        if ($invokeWithArguments) {
            if (!$Arguments) { $Arguments = @{} 
            }

            $paramsPrefix = "`$params."
            if ($AsJob.IsPresent) {
                $paramsPrefix = "$"
            }
            $command = $ScriptBlock.ToString()
            foreach ($usingVarValue in $usingVariableValues) {
                $Arguments[($usingVarValue.NewName.TrimStart('$'))] = $usingVarValue.Value
                $command = $command.Replace($usingVarValue.Name, "$($paramsPrefix)$($usingVarValue.NewName.TrimStart('$'))")
            }

            $newScriptBlock = $command
        }
        else {
            $newScriptBlock = $scriptBlock.ToString()
        }

        if ($Arguments) {
            $parameters = ConvertTo-CliXml -InputObject $Arguments
        }

        if ($PSCmdlet.ParameterSetName -eq "InProcess") {
            # TODO: This will likely fail for params.
            [scriptblock]::Create($newScriptBlock).Invoke()
        }
        else {
            if ($PSCmdlet.ParameterSetName -eq "Session") {
                $Username = $Session.Username
                $Password = $Session.Password
                $SessionId = $Session.SessionId
                $Credential = $Session.Credential
                $ConnectionUri = $Session | ForEach-Object { $_.Connection.BaseUri }
            }

            $serviceUrl = "/-/script/script/?"
            $serviceUrl += "user=" + $Username + "&password=" + $Password

            foreach ($uri in $ConnectionUri) {

                # http://hostname/-/script/type/origin/location
                $url = $uri.AbsoluteUri.TrimEnd("/") + $serviceUrl

                Write-Verbose -Message "Preparing to invoke the script against the service at url $($url)"
                $webclient = New-Object WebClientWithResponse
            
                if ($Credential) {
                    $webclient.Credentials = $Credential
                }
                Write-Host $url
                [byte[]]$response = & {
                    try {
                        Write-Verbose -Message "Transferring script to server"
                        [System.Net.HttpWebResponse]$script:errorResponse = $null;
                        New-UsingBlock($memorystream = [IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($newScriptBlock))) {
                            $bytes = New-Object byte[] 1024
                            $totalBytesToRead = $memorystream.Length
                            $bytesRead = 0
                            $bytesToRead = $bytes.Length
                            if ($totalBytesToRead - $bytesToRead -lt $bytes.Length) {
                                $bytesToRead = $totalBytesToRead - $bytesRead
                            }
                            $bytes = New-Object byte[] $bytesToRead

                            New-UsingBlock($webStream = $webclient.OpenWrite($url)) {
                                while (($bytesToRead = $memorystream.Read($bytes, 0, $bytes.Length)) -gt 0) {
                                    $webStream.Write($bytes, 0, $bytes.Length)
                                    $bytesRead += $bytes.Length
                                    if ($totalBytesToRead - $bytesRead -lt $bytes.Length) {
                                        $bytesToRead = $totalBytesToRead - $bytesRead
                                    }
                                    $bytes = New-Object byte[] $bytesToRead
                                }
                                                
                                #$webStream.Close()
                            }
                            $webclient.Response
                            #$memorystream.Close()
                            Write-Verbose -Message "Script transfer complete."
                        }
                    }
                    catch [System.Net.WebException] {
                        [System.Net.WebException]$script:ex = $_.Exception
                        [System.Net.HttpWebResponse]$script:errorResponse = $ex.Response
                        Write-Verbose -Message "Response exception message: $($ex.Message)"
                        Write-Verbose -Message "Response status description: $($errorResponse.StatusDescription)"
                        if ($errorResponse.StatusCode -eq [System.Net.HttpStatusCode]::Forbidden) {
                            Write-Verbose -Message "Check that the proper credentials are provided and that the service configurations are enabled."
                        }
                        elseif ($errorResponse.StatusCode -eq [System.Net.HttpStatusCode]::NotFound) {
                            Write-Verbose -Message "Check that the service files exist and are properly configured."
                        }
                    }
                }
                
                if ($errorResponse) {
                    Write-Error -Message "Server responded with error: $($errorResponse.StatusDescription)" -Category ConnectionError `
                        -CategoryActivity "Download" -CategoryTargetName $uri -Exception ($script:ex) -CategoryReason "$($errorResponse.StatusCode)" -CategoryTargetType $RootPath 
                }
                
                <#
                if ($singleConnection.Uri.AbsoluteUri -notmatch ".*\.asmx(\?wsdl)?") {
                    $singleConnection.Uri = [Uri]"$($singleConnection.Uri.AbsoluteUri.TrimEnd('/'))/sitecore%20modules/PowerShell/Services/RemoteAutomation.asmx?wsdl"
                }
    
                if (!$singleConnection.Proxy) {
                    $proxyProps = @{
                        Uri = $singleConnection.Uri
                    }
    
                    if ($Credential) {
                        $proxyProps["Credential"] = $Credential
                    }
    
                    $singleConnection.Proxy = New-WebServiceProxy @proxyProps
                    if ($Credential) {
                        $singleConnection.Proxy.Credentials = $Credential
                    }
                }
                if (-not $singleConnection.Proxy) { return $null }

                $response = $singleConnection.Proxy.ExecuteScriptBlock2($Username, $Password, $newScriptBlock, $parameters, $SessionId)
                #>
                if ($response) {
                    if ($hasRedirectedMessages) {
                        foreach ($record in ConvertFrom-CliXml -InputObject $response) {
                            if ($record -is [PSObject] -and $record.PSObject.TypeNames -contains "Deserialized.System.Management.Automation.VerboseRecord") {
                                Write-Verbose $record.ToString()
                            }
                            elseif ($record -is [PSObject] -and $record.PSObject.TypeNames -contains "Deserialized.System.Management.Automation.InformationRecord") {
                                Write-Information $record.ToString()
                            }
                            elseif ($record -is [PSObject] -and $record.PSObject.TypeNames -contains "Deserialized.System.Management.Automation.DebugRecord") {
                                Write-Debug $record.ToString()
                            }
                            elseif ($record -is [PSObject] -and $record.PSObject.TypeNames -contains "Deserialized.System.Management.Automation.WarningRecord") {
                                Write-Warning $record.ToString()
                            }
                            elseif ($record -is [PSObject] -and $record.PSObject.TypeNames -contains "Deserialized.System.Management.Automation.ErrorRecord") {
                                Write-Error $record.ToString()
                            }
                            else {
                                $record
                            }
                        }
                    }
                    else {
                        #ConvertFrom-CliXml -InputObject $response
                        [Text.Encoding]::UTF8.GetString($response)
                    }
                }
                elseif ($response -eq "login failed") {
                    Write-Verbose "Login with the specified account failed."
                    break            
                }
                else {
                    Write-Verbose "No response returned by the service. If results were expected confirm that the service is enabled and the account has access."
                }
            }
        }      
    }
}