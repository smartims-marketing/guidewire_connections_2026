# Embeds the photos in ./assets into index.html as CSS variables, so the page stays a single file.
# Run again after replacing any image:  powershell -ExecutionPolicy Bypass -File .\embed-images.ps1
$root = $PSScriptRoot
$map = [ordered]@{
  'img-hero'     = 'hero-vegas.jpg'
  'img-cube'     = 'iiab-cube.jpg'
  'img-wave'     = 'xymphony-wave.jpg'
  'img-stage'    = 'session-stage.jpg'
  'img-cocktail' = 'cocktail.jpg'
  'img-skyline'  = 'vegas-skyline.jpg'
  'img-logo'     = 'logo-smartims.png'
  'img-xym-logo' = 'logo-xymphony.png'
  'img-team-shyam'     = 'team-shyam.jpg'
  'img-team-vinod'     = 'team-vinod.jpg'
  'img-team-debadutta' = 'team-debadutta.jpg'
  'img-team-danielle'  = 'team-danielle.jpg'
  'img-team-austin'    = 'team-austin.jpg'
}

$vars = foreach ($name in $map.Keys) {
  $file = Join-Path $root "assets\$($map[$name])"
  $mime = if ($file -like '*.png') { 'image/png' } else { 'image/jpeg' }
  $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($file))
  "--${name}:url(data:$mime;base64,$b64);"
}
$block = '<style id="img-data">:root{' + ($vars -join '') + '}</style>'

$htmlPath = Join-Path $root 'index.html'
$html = [IO.File]::ReadAllText($htmlPath)
$html = [regex]::Replace($html, '<style id="img-data">[\s\S]*?</style>', { param($m) $block })
$utf8 = New-Object Text.UTF8Encoding $false
[IO.File]::WriteAllText($htmlPath, $html, $utf8)
"Embedded $($map.Count) images into index.html ($([math]::Round((Get-Item $htmlPath).Length / 1KB)) KB)"

$wpHeader = @"
<?php
/**
 * Template Name: Guidewire Connections 2026 (Full Page)
 * Description: Standalone Smart IMS landing page for Guidewire Connections 2026. Renders without the theme header, footer or styles.
 */
if ( ! defined( 'ABSPATH' ) ) { exit; }
?>
"@
$wpDir = Join-Path $root 'wordpress'
New-Item -ItemType Directory -Force $wpDir | Out-Null
[IO.File]::WriteAllText((Join-Path $wpDir 'page-guidewire-connections-2026.php'), $wpHeader + $html, $utf8)
"Updated wordpress\page-guidewire-connections-2026.php"
