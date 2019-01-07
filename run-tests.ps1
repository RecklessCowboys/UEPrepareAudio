$ErrorActionPreference="Stop"

if (!(Test-Path 'test-data' -PathType Container)) {
    Write-Error 'test-data folder not found'
}

#
# By default, git for Windows cannot handle long paths. We could require everyone
# who checks out this repository to set git's core.longpaths variable, but instead
# we'll just store the long path test files in a 7z archive, and then use 7z
# to extract it. The Expand-Archive command fails on long paths, which is why 7z is used instead.
#
if (!(Test-Path '.\test-data\regression tests\longpaths')) {
    Write-Output "Extracting longpaths with 7z..."
    pushd '.\test-data\regression tests'
    7z x longpaths.zip
    popd
}

$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("ue4-prepare-audio-test-" + [System.Guid]::NewGuid())
Write-Output "Using Temp Dir: $tempDir"

Write-Output "Running Conversion Tests..."

ue4-prepare-audio-folder -InDir test-data -OutDir $tempDir

Write-Output "Finished running conversion tests."