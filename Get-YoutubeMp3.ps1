param(
    [Parameter(Mandatory=$true)]
    $youtubeUrl,
    [switch] $keepOriginal
)

$webmFilename = youtube-dl --restrict-filenames --get-filename $youtubeUrl
$baseFilename = ([io.fileinfo]$webmFilename).basename
youtube-dl -x --restrict-filenames --audio-format best --audio-quality 0 $youtubeUrl
$youtubeAudioFilename = Get-Item "$($baseFilename).*" | Select -ExpandProperty fullname


$pattern = 'max_volume: (-?\d+\.\d) dB'
Write-Host "Checking for max volume in $youtubeAudioFilename" -ForegroundColor Magenta
$maxVolOutput = ffmpeg -i "$youtubeAudioFilename" -af "volumedetect" -f null NUL 2>&1 | Select-String $pattern
if (!($maxVolOutput -match $pattern))
{
    Write-Host "Couldn't find the max volume in the ffmpeg output, unable to normalize." -ForegroundColor Red
    Exit 1
}

[double]$maxVol = $matches[1]
Write-Host "The maximum volume is $maxVol." -ForegroundColor Magenta

if ($maxVol -eq 0)
{
    Write-Host "Volume doesn't need to be normalized." -ForegroundColor Green

    $audioFileInfo = [io.fileinfo]$youtubeAudioFilename
    if ($audioFileInfo.Extension -ne ".mp3")
    {
        Write-Host "Converting from $($audioFileInfo.Extension) to .mp3" -ForegroundColor Magenta
        $convertedFilename = "$($baseFilename)_converted.mp3"
        ffmpeg -i "$youtubeAudioFilename" -c:a libmp3lame -q:a 0 $convertedFilename
    }
    else
    {
        Write-Host "No conversion necessary since the file is already an mp3." -ForegroundColor Green
        $keepOriginal = $true
    }
}
else
{
    $normalizedFilename = "$($baseFilename)_normalized.mp3"
    $gain = [math]::abs($maxVol)
    $gainDb = "$($gain)dB"
    Write-Host "Increasing volume by $gainDb" -ForegroundColor Magenta
    ffmpeg -i "$youtubeAudioFilename" -af "volume=$($gainDb)" -c:a libmp3lame -q:a 0 $normalizedFilename
}

if (!$keepOriginal){
    rm $youtubeAudioFilename
}
