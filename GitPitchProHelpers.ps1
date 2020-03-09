function Start-GitPitchDesktop {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0)]
        [string]
        $Path = $PWD.Path,
        [Parameter(Position = 1)]
        [int]
        $Port = 80,
        [Parameter()]
        [ValidateSet('Normal','Hidden','Minimized','Maximized')]
        [String]
        $WindowStyle = 'Hidden'
    )
    Process {
        $dockerStarted = docker info *>&1
        if ($dockerStarted -match 'errors pretty printing info') {
            Write-Host "Starting Docker Desktop"
            $dockerExe = 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
            Start-Process $dockerExe
            Write-Host -ForegroundColor Yellow "Waiting for the Docker daemon to be available." -NoNewline
            Start-Sleep -Seconds 10
            $i = 0
            do {
                $i++
                Start-Sleep -Seconds 1
                Write-Host -ForegroundColor Yellow "." -NoNewline
                $dockerStarted = docker info *>&1
            }
            until ($i -ge 300 -or ($null -ne $dockerStarted -and $dockerStarted -notmatch 'errors pretty printing info'))
            Write-Host ""
        }
        if ($null -eq (docker image ls | Where-Object {$_ -match 'gitpitch'})) {
            Write-Host -ForegroundColor Green "Pulling latest GitPitch Pro image"
            docker pull gitpitch/desktop:pro
        }
        Write-Host -ForegroundColor Green "Confirmed Docker daemon is available and latest GitPitch Pro image is pulled, running container"
        $url = 'http://localhost'
        $url += if ($Port -ne 80) {
            ":$Port/"
        }
        else {
            '/'
        }
        do {
            if ($null -ne (docker container ls --all | Select-String 'Exited.*GitPitchPro')) {
                Write-Host "Starting stopped container"
                docker container start GitPitchPro
            }
            else {
                Start-Sleep -Seconds 2
                try {
                    $null = Invoke-WebRequest $url -ErrorAction Stop
                }
                catch {
                    try {
                        Start-Process docker -ArgumentList "run -it --name GitPitchPro -v ${Path}:/repo -p ${Port}:${Port} -e PORT=${Port} gitpitch/desktop:pro" -WindowStyle $WindowStyle -ErrorAction Stop
                    }
                    catch {
                    }
                }
            }
        }
        until ($null -ne (docker container ls | Select-String gitpitch))
        Write-Host -ForegroundColor Cyan "Access GitPitch Pro @ $url"
    }
}

function Stop-GitPitchDesktop {
    [CmdletBinding(DefaultParameterSetName = 'NoRemove')]
    Param (
        [Parameter(ParameterSetName = 'NoRemove')]
        [Switch]
        $NoRemove,
        [Parameter(ParameterSetName = 'Prune')]
        [Switch]
        $Prune
    )
    Process {
        docker container stop GitPitchPro
        if ($Prune) {
            docker container prune --force
        }
        elseif (-not $NoRemove) {
            docker container rm GitPitchPro
        }
    }
}
