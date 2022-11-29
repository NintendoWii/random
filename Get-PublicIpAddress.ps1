function Get-PublicIpAddress{
    $ipregex = [regex] "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
    $regionregex= [regex] "<td>Region</td><td>(.+)</td>"
    $locationregex= [regex] "bindPopup(.+).+Actual location may be different"
    $coordregex= [regex] "L.marker(.+).+addTo.+map"
    $ispregex= [regex] "<td>Organization</td><td>(.+)</td>"

    $IP_obj= [pscustomobject][ordered]@{
            PublicIP= $null
            Region= $null
            City = $null
            Country = $null
            GeoCoord= $null
            ISP= $null
    }

    $web= Invoke-WebRequest -uri "https://www.showmyip.com/"
    $web= $($web.content)

    $public= $ipregex.Matches($web) | % { $_.value }
    $IP_obj.PublicIP = $public[0].TrimStart().trimend()
    
    $location= $locationregex.match($web)  |% {$_.value}
    $region= $regionregex.Matches($web) | % { $_.value }
    $IP_obj.City = $location.split("'").split('<')[1].split(',')[0].TrimStart().trimend()
    $IP_obj.Country = $location.split("'").split('<')[1].split(',')[1].TrimStart().trimend()
    $IP_obj.Region = $region.split('>').split('<')[-3].trimstart().trimend()
    
    $coord= $coordregex.match($web)  |% {$_.value}
    $IP_obj.GeoCoord = $coord.split('[').split(']')[1].TrimStart().trimend()

    $isp= $ispregex.Matches($web) | % { $_.value }
    $IP_obj.ISP = $isp.split('>').split('<')[-3].trimstart().trimend()

    return $IP_obj
}

#Demo
Get-publicIpAddress
pause


