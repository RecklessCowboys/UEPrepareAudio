<#
.SYNOPSIS
  Convert an audio file to a a PCM-16, little endian WAV file compatible for import into Unreal Engine 4.

.DESCRIPTION
  ue4-prepare-audio does the following:
    - converts input audio to a 16-bit little endian PCM WAV file
    - Downmixes stereo to mono (by default, can be overriden with -NoDownmix)

  The sample rate is left unchanged.

  ue4-prepare-audio by default will not allow you to overwrite files. You can change this behavior with -AllowOverwrite.

  ue4-prepare-audio requires ffprobe.exe and ffmpeg.exe, both part of the ffmpeg install: https://ffmpeg.org/

  For more information see:
    https://docs.unrealengine.com/en-US/Engine/Audio/Overview

.NOTES
  To see more information during the copy, set $InformationPreference = "Continue" in your PowerShell.

#>
function ue4-prepare-audio {
  param(
    [Parameter(Mandatory)] [string] $InPath,
    [Parameter(Mandatory)] [string] $OutPath,
    [switch] $NoDownmix,
    [switch] $AllowOverwrite,
    [switch] $LogVerbose
  )

  # $DebugPreference = "Continue"
  # $InformationPreference = "Continue"
  $ErrorActionPreference = "Stop"

  if ($OutPath.Equals($InPath)) {
    Write-Error "InPath equals OutPath"
  }

  $LongPathPrefix="\\?\"
  if (!$InPath.StartsWith($LongPathPrefix))
  {
    $InPath = $LongPathPrefix + $InPath
  }
  if (!$OutPath.StartsWith($LongPathPrefix))
  {
    $OutPath = $LongPathPrefix + $OutPath
  }

  # Convert Paths to long file paths, otherwise ffprobe will fail with a long path.

  #
  # Use ffprobe.exe to find out about the input file.
  #
  $FFProbeXml=([xml](ffprobe.exe -hide_banner -loglevel error -show_streams -select_streams a -print_format xml $InPath))
  $Stream0=$FFProbeXml.ffprobe.streams.stream
  $InChannels=$Stream0.channels

  #
  # Tool only handles 1 (mono) or 2 (stereo) channels
  #
  if ($InChannels -ne 1 -and $InChannels -ne 2) {
    Write-Error "Stream has $InChannels but this tool expects 1 or 2."
  }

  #
  # Convert the file for UE4
  #

  $arguments = @()
  if ($LogVerbose) {
    $arguments += @('-loglevel', 'verbose')
  } else {
    $arguments += @('-loglevel', 'error')
  }
  $arguments += @('-i', $InPath, '-metadata', 'encoded_by=ue4-prepare-audio')
  if ($AllowOverwrite) {
    $arguments += @('-y')
  }
  if (!$NoDownmix) {
    $arguments += @('-ac', '1')
  }
  $arguments += @('-codec:a', 'pcm_s16le', $OutPath)
  Write-Debug "RUNNING: ffmpeg.exe $arguments"
  & ffmpeg.exe $arguments
  if (!$?) {
    Write-Error "ffmpeg failed"
  }
}