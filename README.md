# UE4 Prepare Audio Scripts

PowerShell scripts that convert audio files into a
[format compatible with Unreal Engine](https://docs.unrealengine.com/en-US/Engine/Audio/WAV).
Currently this means 16-bit little endian PCM stored in a WAV file, stereo or mono.

I assume the primary use case are spatialized sounds in UE4, so by default stereo
is downmixed into mono, but this can be suppressed with an option.

Input file sample rates are left unchanged.

These scripts can pull audio for any file your ffmpeg installation is capable of
decoding, though there is a list of file extensions in the batch processing
tool that may need to be modified for your use case.

## Requirements

- [ffmpeg.exe](https://ffmpeg.org/) and ffprobe.exe must be in your PATH

## Installation

  1. Copy this directory to %USERPROFILE%\Documents\WindowsPowerShell\Modules
  2. Install ffmpeg.

## Usage: ue4-prepare-audio

Run `ue4-prepare-audio` to convert a single audio file 

## Usage: ue4-prepare-audio-folder

Run `ue4-prepare-audio-folder` to convert an entire directory structure. This creates a new directory
structure that mimics the source directory but fills it with converted files.
