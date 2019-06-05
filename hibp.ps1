Param (
	$i,
	$o	
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
 
$headers = @{
    "User-Agent"  = "Powershell Account Check"
    "api-version" = 2
}
$baseUri = "https://haveibeenpwned.com/api"

# Sanity check to make sure a input file and output path is defined
if (!$i){
	Write-Host "Usage: ./hibp -i [input file] -o [output file path]" -ForegroundColor Green
	exit
}
if (!$o){
	Write-Host "Usage: ./hibp -i [input file path] -o [output file path]" -ForegroundColor Green
	exit
}

# Calculate the time it will take for the scan to run based on the 2 second delay.
# If a scan would take more than 5 minutes, it provides a time estimate and the option to continue.
# $fc is also used to calculate the do loop used to run checks.
$fc=0
Get-content -Path $i | foreach-object{$fc++}
$time = [int](($fc*2)/60)
$continue = "a"
if ($time -gt 5){
	while ($continue -ne "y"){
		$continue = Read-Host "This will take approxmiately $time minutes, do you wish to continue? (y/n)"
		if ($continue -eq "n"){
			exit
	}
	}
}
	
	
# sets the output path and report name
$outputpath = $o + "\breach.csv"


$emails = Get-content -Path $i
$count = 0
do{
    $emails | ForEach-Object {
        $email = ($emails -split " ")[$count]
        $uriEncodeEmail = [uri]::EscapeDataString($email)
        $uri = "$baseUri/breachedaccount/$uriEncodeEmail"
        $breachResult = $null
        try {
            [array]$breachResult = Invoke-RestMethod -Uri $uri -Headers $headers -ErrorAction SilentlyContinue
        }
        catch {
            if($error[0].Exception.response.StatusCode -match "NotFound"){
                Write-Host "No Breach detected for $email" -ForegroundColor Green
            }else{
                Write-Host "Cannot retrieve results due to rate limiting or suspect IP. You may need to try a different computer"
            }
        }
        if ($breachResult) {
            foreach ($breach in $breachResult) {
                $breachObject = [ordered]@{
                    Email              = $email
                    BreachName         = $breach.Name
                    BreachTitle        = $breach.Title
                    BreachDate         = $breach.BreachDate
                    BreachAdded        = $breach.AddedDate
                    BreachDescription  = $breach.Description
                    BreachDataClasses  = ($breach.dataclasses -join ', ')
                    IsVerified         = $breach.IsVerified
                    IsFabricated       = $breach.IsFabricated
                    IsActive           = $breach.IsActive
                    IsRetired          = $breach.IsRetired
                    IsSpamList         = $breach.IsSpamList
                }
                $breachObject = New-Object PSobject -Property $breachObject
                $breachObject | Export-csv $outputpath -NoTypeInformation -Append
                Write-Host "Breach detected for $email - $($breach.name)" -ForegroundColor Yellow
                Write-Host $breach.description -ForegroundColor DarkYellow
            }
        }
		$count = $count + 1
        Start-sleep -Milliseconds 2000
    }
}while ($count -lt $fc)
Write-Host "Report can be found in $outputpath"
