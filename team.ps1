# Usage:
#   .\team.ps1 up                      start Ollama + Docker stack
#   .\team.ps1 down                    stop stack
#   .\team.ps1 ask "goal text"         research -> data -> AI/GenAI -> Esteban summary chain
#   .\team.ps1 board                   show the task board
param([Parameter(Position=0)][string]$cmd='board',[Parameter(Position=1)][string]$text)
$env:PATH = "C:\Program Files\Docker\Docker\resources\bin;$env:PATH"
Set-Location $PSScriptRoot
function H { docker exec hermes hermes @args }
function NewTask($title,$who,$body,$parent) {
  $a = @('kanban','create',$title,'--assignee',$who,'--body',$body,'--json')
  if ($parent) { $a += @('--parent',$parent) }
  $j = docker exec hermes hermes @a | Out-String
  ($j | Select-String '"id":\s*"(t_[a-z0-9]+)"').Matches.Groups[1].Value
}
switch ($cmd) {
  'up' {
    $env:OLLAMA_MODELS="$PSScriptRoot\models"; $env:OLLAMA_FLASH_ATTENTION='1'; $env:OLLAMA_KV_CACHE_TYPE='q8_0'; $env:OLLAMA_KEEP_ALIVE='24h'
    if (-not (Get-Process ollama -ErrorAction SilentlyContinue)) { Start-Process "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe" -ArgumentList serve -WindowStyle Hidden }
    if (-not (Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue)) { Start-Process 'C:\Program Files\Docker\Docker\Docker Desktop.exe'; Start-Sleep 60 }
    docker compose up -d
  }
  'down' { docker compose down }
  'board' { H kanban list }
  'ask' {
    $r  = NewTask "Research: $text" researcher "Goal: $text`nSearch with SearXNG (curl 'http://searxng:8080/search?q=<query>&format=json'). Complete with a concise sourced summary in the completion summary." $null
    $ds = NewTask "Analyse: $text" data-scientist "Goal: $text`nUse the parent research. Complete with key analysis and recommendations in the completion summary." $r
    $de = NewTask "Data plan: $text" data-engineer "Goal: $text`nUse the parent results. Propose the data pipeline/storage needed. Complete with a short plan." $ds
    $ai = NewTask "AI/GenAI design: $text" ai-engineer "Goal: $text`nUse the parent results. Propose the agent/LLM/RAG design. Complete with a short design." $de
    NewTask "Esteban: consolidate $text" esteban "Goal: $text`nRead parent results, update /opt/data/shared/TEAM_NOTES.md (Goal, Decisions, Answers, Next tasks), then complete." $ai | Out-Null
    "Chain started. Watch with: .\team.ps1 board  |  notes: shared\TEAM_NOTES.md"
  }
}
