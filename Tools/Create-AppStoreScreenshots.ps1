Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$OutPhone = Join-Path $Root "AppStoreScreenshots\iPhone"
$OutPad = Join-Path $Root "AppStoreScreenshots\iPad"
New-Item -ItemType Directory -Force -Path $OutPhone, $OutPad | Out-Null

function Color-Hex($hex, [int]$alpha = 255) {
    $clean = $hex.TrimStart("#")
    $r = [Convert]::ToInt32($clean.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($clean.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($clean.Substring(4, 2), 16)
    return [System.Drawing.Color]::FromArgb($alpha, $r, $g, $b)
}

function New-Font($size, $style = [System.Drawing.FontStyle]::Regular) {
    return [System.Drawing.Font]::new("Segoe UI", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function RoundRect-Path([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function Fill-RoundRect($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r, $color) {
    $path = RoundRect-Path $x $y $w $h $r
    $brush = [System.Drawing.SolidBrush]::new($color)
    $g.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
}

function Stroke-RoundRect($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r, $color, [float]$width = 2) {
    $path = RoundRect-Path $x $y $w $h $r
    $pen = [System.Drawing.Pen]::new($color, $width)
    $g.DrawPath($pen, $path)
    $pen.Dispose()
    $path.Dispose()
}

function Draw-Text($g, [string]$text, $font, $color, [float]$x, [float]$y, [float]$w, [float]$h, $align = "Near") {
    $brush = [System.Drawing.SolidBrush]::new($color)
    $format = [System.Drawing.StringFormat]::new()
    $format.Alignment = [System.Drawing.StringAlignment]::$align
    $format.LineAlignment = [System.Drawing.StringAlignment]::Near
    $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    $rect = [System.Drawing.RectangleF]::new($x, $y, $w, $h)
    $g.DrawString($text, $font, $brush, $rect, $format)
    $brush.Dispose()
    $format.Dispose()
}

function Wrap-Lines($g, [string]$text, $font, [float]$maxWidth) {
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($paragraph in $text -split "`n") {
        $words = $paragraph -split " "
        $line = ""
        foreach ($word in $words) {
            $candidate = if ($line.Length -eq 0) { $word } else { "$line $word" }
            if ($g.MeasureString($candidate, $font).Width -le $maxWidth) {
                $line = $candidate
            } else {
                if ($line.Length -gt 0) { $lines.Add($line) }
                $line = $word
            }
        }
        if ($line.Length -gt 0) { $lines.Add($line) }
    }
    return $lines
}

function Draw-Wrapped($g, [string]$text, $font, $color, [float]$x, [float]$y, [float]$maxWidth, [float]$lineHeight, [int]$maxLines = 99) {
    $brush = [System.Drawing.SolidBrush]::new($color)
    $lines = @(Wrap-Lines $g $text $font $maxWidth)
    $count = [Math]::Min($maxLines, $lines.Count)
    for ($i = 0; $i -lt $count; $i++) {
        $g.DrawString($lines[$i], $font, $brush, [System.Drawing.PointF]::new($x, $y + ($i * $lineHeight)))
    }
    $brush.Dispose()
    return $y + ($count * $lineHeight)
}

function Draw-Pill($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$h, $fill, $textColor) {
    Fill-RoundRect $g $x $y $w $h ($h / 2) $fill
    $font = New-Font 24 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g $text $font $textColor ($x + 18) ($y + 10) ($w - 36) ($h - 10) "Center"
    $font.Dispose()
}

function Draw-Background($g, [int]$w, [int]$h) {
    $rect = [System.Drawing.Rectangle]::new(0, 0, $w, $h)
    $brush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $rect,
        (Color-Hex "130B1F"),
        (Color-Hex "F8F5FF"),
        90
    )
    $g.FillRectangle($brush, $rect)
    $brush.Dispose()

    Fill-RoundRect $g (-180) 160 520 520 260 (Color-Hex "7C3AED" 70)
    Fill-RoundRect $g ($w - 320) 460 420 420 210 (Color-Hex "14B8A6" 40)
    Fill-RoundRect $g 120 ($h - 460) 420 420 210 (Color-Hex "F97316" 35)
}

function Draw-Header($g, [string]$headline, [string]$subhead, [int]$w, [bool]$isPad) {
    $margin = if ($isPad) { 170 } else { 96 }
    $titleSize = if ($isPad) { 78 } else { 62 }
    $subSize = if ($isPad) { 34 } else { 30 }
    $logoFont = New-Font 34 ([System.Drawing.FontStyle]::Bold)
    $titleFont = New-Font $titleSize ([System.Drawing.FontStyle]::Bold)
    $subFont = New-Font $subSize ([System.Drawing.FontStyle]::Regular)

    Fill-RoundRect $g $margin 90 72 72 22 (Color-Hex "7C3AED")
    Draw-Text $g "VS" $logoFont (Color-Hex "FFFFFF") ($margin + 9) 105 56 50 "Center"
    Draw-Text $g "ViralSpark AI" $logoFont (Color-Hex "FFFFFF") ($margin + 96) 106 520 60 "Near"

    $y = Draw-Wrapped $g $headline $titleFont (Color-Hex "FFFFFF") $margin 230 ($w - ($margin * 2)) ($titleSize + 8) 2
    [void](Draw-Wrapped $g $subhead $subFont (Color-Hex "ECE7FF") $margin ($y + 24) ($w - ($margin * 2)) ($subSize + 10) 3)

    $logoFont.Dispose()
    $titleFont.Dispose()
    $subFont.Dispose()
}

function Draw-AppFrame($g, [float]$x, [float]$y, [float]$w, [float]$h, [string]$screenTitle, [string]$activeTab) {
    Fill-RoundRect $g $x $y $w $h 52 (Color-Hex "F8F7FC")
    Stroke-RoundRect $g $x $y $w $h 52 (Color-Hex "FFFFFF" 180) 5
    Fill-RoundRect $g ($x + 24) ($y + 24) ($w - 48) ($h - 48) 36 (Color-Hex "FFFFFF")

    $titleFont = New-Font 34 ([System.Drawing.FontStyle]::Bold)
    $smallFont = New-Font 18 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g $screenTitle $titleFont (Color-Hex "15111F") ($x + 62) ($y + 60) ($w - 124) 58 "Near"
    Draw-Pill $g "Pro" ($x + $w - 152) ($y + 62) 82 42 (Color-Hex "7C3AED") (Color-Hex "FFFFFF")

    $tabY = $y + $h - 118
    Fill-RoundRect $g ($x + 52) $tabY ($w - 104) 72 26 (Color-Hex "F0ECFA")
    $tabs = @("Home", "Calendar", "Library", "Settings")
    $tabW = ($w - 104) / 4
    for ($i = 0; $i -lt 4; $i++) {
        $tx = $x + 52 + ($i * $tabW)
        if ($tabs[$i] -eq $activeTab) {
            Fill-RoundRect $g ($tx + 10) ($tabY + 10) ($tabW - 20) 52 18 (Color-Hex "FFFFFF")
            Draw-Text $g $tabs[$i] $smallFont (Color-Hex "7C3AED") $tx ($tabY + 24) $tabW 30 "Center"
        } else {
            Draw-Text $g $tabs[$i] $smallFont (Color-Hex "8B8699") $tx ($tabY + 24) $tabW 30 "Center"
        }
    }
    $titleFont.Dispose()
    $smallFont.Dispose()
}

function Draw-Card($g, [float]$x, [float]$y, [float]$w, [float]$h, [string]$title, [string]$body, [string]$accent = "7C3AED") {
    Fill-RoundRect $g $x $y $w $h 28 (Color-Hex "F7F4FF")
    Stroke-RoundRect $g $x $y $w $h 28 (Color-Hex "E7DDFC") 2
    Fill-RoundRect $g ($x + 24) ($y + 24) 54 54 16 (Color-Hex $accent)
    $titleFont = New-Font 28 ([System.Drawing.FontStyle]::Bold)
    $bodyFont = New-Font 22 ([System.Drawing.FontStyle]::Regular)
    Draw-Text $g $title $titleFont (Color-Hex "15111F") ($x + 96) ($y + 24) ($w - 122) 40 "Near"
    [void](Draw-Wrapped $g $body $bodyFont (Color-Hex "5F5A6B") ($x + 96) ($y + 65) ($w - 122) 28 3)
    $titleFont.Dispose()
    $bodyFont.Dispose()
}

function Draw-PhoneDashboard($g, [float]$x, [float]$y, [float]$w, [float]$h) {
    Draw-AppFrame $g $x $y $w $h "Creator cockpit" "Home"
    $cx = $x + 62
    $cy = $y + 150
    Draw-Card $g $cx $cy ($w - 124) 150 "Free generations" "5 daily drafts included. Upgrade when your content calendar starts moving fast." "7C3AED"
    $cy += 180
    $font = New-Font 30 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g "Quick actions" $font (Color-Hex "15111F") $cx $cy 480 48 "Near"
    $font.Dispose()
    $cy += 66
    $actions = @(
        @("Viral Hooks","Bolt"),
        @("Video Script","Script"),
        @("Captions","CTA"),
        @("Content Ideas","Idea"),
        @("Hashtags","Tags"),
        @("7-Day Plan","Plan")
    )
    $cardW = ($w - 148) / 2
    for ($i = 0; $i -lt $actions.Count; $i++) {
        $col = $i % 2
        $row = [Math]::Floor($i / 2)
        $rx = $cx + ($col * ($cardW + 24))
        $ry = $cy + ($row * 148)
        Draw-Card $g $rx $ry $cardW 124 $actions[$i][0] $actions[$i][1] "4F46E5"
    }
    $cy += 500
    Draw-Card $g $cx $cy ($w - 124) 135 "Recent generation" "10 bold hooks for pricing a coaching package, each scored for retention." "DB2777"
    $cy += 160
    Draw-Card $g $cx $cy ($w - 124) 135 "Saved favorite" "Stop selling the session. Start selling the transformation." "F97316"
}

function Draw-Hooks($g, [float]$x, [float]$y, [float]$w, [float]$h) {
    Draw-AppFrame $g $x $y $w $h "Viral Hooks" "Home"
    $cx = $x + 62
    $cy = $y + 150
    Draw-Card $g $cx $cy ($w - 124) 156 "Hook brief" "Topic: Price coaching packages. Tone: bold. Audience: first-time coaches." "7C3AED"
    $cy += 188
    $font = New-Font 28 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g "10 hook options" $font (Color-Hex "15111F") $cx $cy 480 42 "Near"
    $font.Dispose()
    $cy += 58
    $hooks = @(
        @("Most coaches are pricing the wrong thing.", "96/100"),
        @("If your offer feels expensive, this is why.", "94/100"),
        @("Stop charging for calls. Charge for outcomes.", "93/100"),
        @("The pricing mistake that quietly kills trust.", "91/100")
    )
    foreach ($hook in $hooks) {
        Fill-RoundRect $g $cx $cy ($w - 124) 180 28 (Color-Hex "F7F4FF")
        $hfont = New-Font 26 ([System.Drawing.FontStyle]::Bold)
        $bfont = New-Font 21 ([System.Drawing.FontStyle]::Regular)
        Draw-Text $g $hook[1] $hfont (Color-Hex "7C3AED") ($cx + $w - 250) ($cy + 26) 140 40 "Center"
        Draw-Text $g $hook[0] $hfont (Color-Hex "15111F") ($cx + 28) ($cy + 24) ($w - 300) 40 "Near"
        [void](Draw-Wrapped $g "Why it works: opens a curiosity gap and gives the creator a clear retention angle." $bfont (Color-Hex "5F5A6B") ($cx + 28) ($cy + 76) ($w - 190) 28 2)
        $hfont.Dispose()
        $bfont.Dispose()
        $cy += 204
    }
}

function Draw-Scripts($g, [float]$x, [float]$y, [float]$w, [float]$h) {
    Draw-AppFrame $g $x $y $w $h "Video Script" "Home"
    $cx = $x + 62
    $cy = $y + 150
    Draw-Card $g $cx $cy ($w - 124) 150 "Script brief" "30s TikTok video for freelancers who want more qualified leads." "4F46E5"
    $cy += 184
    $sections = @(
        @("Hook", "Most freelancers do not need more content. They need clearer content."),
        @("Main points", "1. Name the buyer.  2. Show the pain.  3. Give one next step."),
        @("Scene-by-scene", "0-3s face camera. 4-15s show the old way. 16-27s show the fix."),
        @("CTA", "Comment SPARK and save this before your next post.")
    )
    foreach ($section in $sections) {
        Draw-Card $g $cx $cy ($w - 124) 150 $section[0] $section[1] "7C3AED"
        $cy += 174
    }
}

function Draw-Calendar($g, [float]$x, [float]$y, [float]$w, [float]$h) {
    Draw-AppFrame $g $x $y $w $h "Calendar" "Calendar"
    $cx = $x + 62
    $cy = $y + 150
    Draw-Card $g $cx $cy ($w - 124) 145 "7-Day plan" "Launch week for a digital product. Instagram Reels. Educational tone." "2563EB"
    $cy += 178
    $posts = @(
        @("Day 1: Pain point", "Drafted"),
        @("Day 2: Myth-busting", "Filmed"),
        @("Day 3: Tutorial", "Edited"),
        @("Day 4: Story", "Posted"),
        @("Day 5: Comparison", "Drafted")
    )
    foreach ($post in $posts) {
        Fill-RoundRect $g $cx $cy ($w - 124) 126 24 (Color-Hex "F7F4FF")
        $tfont = New-Font 26 ([System.Drawing.FontStyle]::Bold)
        $bfont = New-Font 21
        Draw-Text $g $post[0] $tfont (Color-Hex "15111F") ($cx + 26) ($cy + 20) ($w - 330) 36 "Near"
        Draw-Pill $g $post[1] ($cx + $w - 284) ($cy + 24) 152 44 (Color-Hex "E9D5FF") (Color-Hex "5B21B6")
        Draw-Text $g "Angle, caption draft, and reminder ready." $bfont (Color-Hex "5F5A6B") ($cx + 26) ($cy + 66) ($w - 180) 34 "Near"
        $tfont.Dispose()
        $bfont.Dispose()
        $cy += 148
    }
}

function Draw-Library($g, [float]$x, [float]$y, [float]$w, [float]$h) {
    Draw-AppFrame $g $x $y $w $h "Library" "Library"
    $cx = $x + 62
    $cy = $y + 150
    Draw-Pill $g "All" $cx $cy 84 46 (Color-Hex "7C3AED") (Color-Hex "FFFFFF")
    Draw-Pill $g "Hooks" ($cx + 104) $cy 130 46 (Color-Hex "F0ECFA") (Color-Hex "5F5A6B")
    Draw-Pill $g "Scripts" ($cx + 252) $cy 140 46 (Color-Hex "F0ECFA") (Color-Hex "5F5A6B")
    $cy += 78
    $items = @(
        @("Pricing hook", "Stop selling the session. Start selling the transformation."),
        @("Lead gen caption", "The fastest way to make your offer easier to understand."),
        @("Hashtag set", "#ContentStrategy #CreatorTips #ShortFormVideo"),
        @("Campaign idea", "A myth-busting post for buyers who think price is the problem.")
    )
    foreach ($item in $items) {
        Draw-Card $g $cx $cy ($w - 124) 172 $item[0] $item[1] "DB2777"
        $cy += 200
    }
}

function Draw-Pro($g, [float]$x, [float]$y, [float]$w, [float]$h) {
    Draw-AppFrame $g $x $y $w $h "ViralSpark Pro" "Settings"
    $cx = $x + 62
    $cy = $y + 150
    Draw-Card $g $cx $cy ($w - 124) 168 "Create without limits" "Unlimited generations, advanced hooks, content planning, saved library, exports, and batch ideas." "F59E0B"
    $cy += 202
    $features = @("Unlimited generations", "Advanced hooks", "30-day content plans", "Saved library and exports", "Batch 30 content ideas")
    foreach ($feature in $features) {
        Fill-RoundRect $g $cx $cy ($w - 124) 92 24 (Color-Hex "F7F4FF")
        $font = New-Font 26 ([System.Drawing.FontStyle]::Bold)
        Fill-RoundRect $g ($cx + 24) ($cy + 24) 44 44 22 (Color-Hex "7C3AED")
        Draw-Text $g $feature $font (Color-Hex "15111F") ($cx + 92) ($cy + 25) ($w - 230) 42 "Near"
        $font.Dispose()
        $cy += 112
    }
    Draw-Card $g $cx ($cy + 20) ($w - 124) 140 "Yearly Pro" "GBP 99.99 per year. Auto-renewable subscription through Apple." "7C3AED"
}

function Save-Screenshot([string]$path, [int]$w, [int]$h, [string]$headline, [string]$subhead, [string]$screen, [bool]$isPad) {
    $bmp = [System.Drawing.Bitmap]::new($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    Draw-Background $g $w $h
    Draw-Header $g $headline $subhead $w $isPad

    if ($isPad) {
        $frameX = 170
        $frameY = 680
        $frameW = $w - 340
        $frameH = 1840
    } else {
        $frameX = 110
        $frameY = 620
        $frameW = $w - 220
        $frameH = 1980
    }

    switch ($screen) {
        "dashboard" { Draw-PhoneDashboard $g $frameX $frameY $frameW $frameH }
        "hooks" { Draw-Hooks $g $frameX $frameY $frameW $frameH }
        "scripts" { Draw-Scripts $g $frameX $frameY $frameW $frameH }
        "calendar" { Draw-Calendar $g $frameX $frameY $frameW $frameH }
        "library" { Draw-Library $g $frameX $frameY $frameW $frameH }
        "pro" { Draw-Pro $g $frameX $frameY $frameW $frameH }
    }

    $g.Dispose()
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

$shots = @(
    @{ Name = "01-dashboard.png"; Screen = "dashboard"; Head = "Create short-form content faster"; Sub = "Hooks, scripts, captions, hashtags, and plans in one creator workspace." },
    @{ Name = "02-hooks.png"; Screen = "hooks"; Head = "Generate viral hooks in seconds"; Sub = "Get scored hook options with clear reasons each one can stop the scroll." },
    @{ Name = "03-scripts.png"; Screen = "scripts"; Head = "Turn topics into full scripts"; Sub = "Draft hooks, scenes, captions, CTAs, and hashtags for short-form video." },
    @{ Name = "04-calendar.png"; Screen = "calendar"; Head = "Plan your next 7 or 30 days"; Sub = "Store planned posts, track production status, and set local reminders." },
    @{ Name = "05-library.png"; Screen = "library"; Head = "Save your best ideas"; Sub = "Keep reusable hooks, scripts, captions, hashtag sets, and content plans." },
    @{ Name = "06-pro.png"; Screen = "pro"; Head = "Unlock unlimited creation"; Sub = "Pro includes unlimited generations, premium workflows, exports, and batch ideas." }
)

foreach ($shot in $shots) {
    Save-Screenshot (Join-Path $OutPhone $shot.Name) 1284 2778 $shot.Head $shot.Sub $shot.Screen $false
    Save-Screenshot (Join-Path $OutPad $shot.Name) 2048 2732 $shot.Head $shot.Sub $shot.Screen $true
}

Write-Host "Generated App Store screenshots:"
Get-ChildItem $OutPhone, $OutPad -Filter *.png | Select-Object FullName, Length
