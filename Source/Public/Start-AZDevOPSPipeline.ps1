function Start-AZDevOPSPipeline {
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Project,

        [Parameter()]
        [string]$Organization
    )

    if (-not [string]::IsNullOrEmpty($Organization)) {
        $Org = GetAZDevOPSHeader -Organization $Organization
    }
    else {
        $Org = GetAZDevOPSHeader
    }

    $AllPipelinesURI = "https://dev.azure.com/$($org.Organization)/$Project/_apis/pipelines?api-version=7.1-preview.1"
    $AllPipelines = InvokeAZDevOPSRestMethod -Method Get -Uri $AllPipelinesURI 
    $PipelineID = ($AllPipelines.value | Where-Object -Property Name -EQ $Name).id

    if ([string]::IsNullOrEmpty($PipelineID)) {
        throw "No pipeline with name $Name found."
    }

    $URI = "https://dev.azure.com/$($org.Organization)/$Project/_apis/pipelines/$PipelineID/runs?api-version=7.1-preview.1"
    $Body = '{"stagesToSkip":[],"resources":{"repositories":{"self":{"refName":"refs/heads/master"}}},"variables":{}}'
    
    $InvokeSplat = @{
        Method = 'Post' 
        Uri = $URI 
        Body = $Body
    }

    InvokeAZDevOPSRestMethod @InvokeSplat
}