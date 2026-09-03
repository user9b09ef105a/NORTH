$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo

if (-not (Get-Command bundle -ErrorAction SilentlyContinue)) {
  throw 'Bundler is not available. Install Ruby + Bundler first, then run: bundle install'
}

bundle exec jekyll serve --baseurl "" --livereload
