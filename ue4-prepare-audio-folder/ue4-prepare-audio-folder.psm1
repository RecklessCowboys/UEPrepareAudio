<#
.SYNOPSIS
  Prepare batch of audio files for import into UE4. See ue4-prepare-audio
  for more information.

  By default, non-audio files are not copied. If you set -CopyNonAudioFiles then non-audio
  files will be copied with no conversion applied.

.NOTES
  To see more information during the copy, set $InformationPreference = "Continue" in your PowerShell.

#>
function ue4-prepare-audio-folder {
  param(
    [Parameter(Mandatory)] [string] $InDir,
    [Parameter(Mandatory)] [string] $OutDir,
    [switch] $NoDownmix,
    [switch] $AllowOverwrite,
    [switch] $LogVerbose,
    [switch] $CopyNonAudioFiles
  )

  # $DebugPreference = "Continue"
  # $InformationPreference = "Continue"
  $ErrorActionPreference = "Stop"

  # Remove any unnecessary trailing directory separators because it screws up string
  # based path manipulation later.
  $InDir=$InDir.TrimEnd([IO.Path]::DirectorySeparatorChar)
  $InDir=$InDir.TrimEnd([IO.Path]::AltDirectorySeparatorChar)
  $OutDir=$OutDir.TrimEnd([IO.Path]::DirectorySeparatorChar)
  $OutDir=$OutDir.TrimEnd([IO.Path]::AltDirectorySeparatorChar)

  Write-Debug "Trimmmed InDir: $InDir"
  Write-Debug "Trimmed OutDir: $OutDir"

  $AudioFileExtensionArray=@('.aac','.ac3','.aiff','.amr','.au','.avi','.flac','.flv','.m4a','.mka','.mkv','.mov','.mp3','.mp4','.mpg','.ogg','.ra','.swf','.voc','.wav','.webm','.wma','.wmv')
  $AudioFileExtensionSet=New-Object System.Collections.Generic.HashSet[string]
  ForEach($extension in $AudioFileExtensionArray){
    $AudioFileExtensionSet.Add($extension) | Out-Null
  }

  if ([IO.File]::Exists($OutDir)) {
    Write-Error "Output directory already exists."
  }

  $ResolvedInDir=[IO.Path]::GetFullPath((Resolve-Path $InDir))

  Write-Information "Creating directory structure for destination."
  Copy-Item $ResolvedInDir $OutDir -Filter {PSIsContainer} -Recurse
  $ResolvedOutDir=[IO.Path]::GetFullPath((Resolve-Path $OutDir))

  Write-Debug "ResolvedInDir $ResolvedInDir"
  Write-Debug "ResolvedOutDir $ResolvedOutDir"

  gci -Recurse -Path $ResolvedInDir -File | ForEach-Object {

    $AbsoluteOutDir=Join-Path $ResolvedOutDir (Split-Path -Parent $_.FullName).Remove(0, $ResolvedInDir.Length)
    $AbsoluteOutPath=Join-Path $AbsoluteOutDir ([io.path]::GetFileNameWithoutExtension($_.FullName) + ".wav")

    if ($AudioFileExtensionSet.Contains($_.Extension))
    {
        Write-Information "CONVERTING: $($_.FullName)"
        ue4-prepare-audio -InPath $_.FullName -OutPath $AbsoluteOutPath -AllowOverwrite:$AllowOverwrite -NoDownmix:$NoDownmix -LogVerbose:$LogVerbose
        Write-Output $AbsoluteOutPath
    }
    elseif ($CopyNonAudioFiles)
    {
        Write-Information "COPYING: $($_.FullName)"
        Copy-Item -Path $_.FullName -Destination $AbsoluteOutDir
    }
    else
    {
        Write-Information "SKIPPING: $($_.FullName)"
    }
  }
}
