$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "../..")

function Import-LocalEnv {
    param([switch]$AllowExample)

    $envLocal = Join-Path $RepoRoot ".env.local"
    $envExample = Join-Path $RepoRoot ".env.example"

    if (Test-Path -LiteralPath $envLocal) {
        $path = $envLocal
    }
    elseif ($AllowExample -and (Test-Path -LiteralPath $envExample)) {
        $path = $envExample
    }
    else {
        throw "Missing .env.local. Copy .env.example to .env.local and set local-only values."
    }

    $values = @{}
    foreach ($line in Get-Content -LiteralPath $path) {
        $trimmed = $line.Trim()
        if ($trimmed.Length -eq 0 -or $trimmed.StartsWith("#")) {
            continue
        }

        $parts = $trimmed -split "=", 2
        if ($parts.Count -ne 2) {
            continue
        }

        $name = $parts[0].Trim()
        $value = $parts[1].Trim()
        $values[$name] = $value
    }

    return $values
}

function Get-EnvValue {
    param(
        [hashtable]$Config,
        [string]$Name,
        [string]$Default = ""
    )

    if ($Config.ContainsKey($Name) -and $Config[$Name]) {
        return $Config[$Name]
    }

    return $Default
}

function Assert-LocalDatabaseTarget {
    param([hashtable]$Config)

    $appEnv = Get-EnvValue $Config "APP_ENV"
    $hostName = Get-EnvValue $Config "POSTGRES_HOST"
    $dbName = Get-EnvValue $Config "POSTGRES_DB"
    $databaseUrl = Get-EnvValue $Config "DATABASE_URL"

    if ($appEnv -ne "local") {
        throw "Refusing DB command because APP_ENV is '$appEnv', not 'local'."
    }

    if ($hostName -notin @("localhost", "127.0.0.1", "::1")) {
        throw "Refusing DB command for non-local POSTGRES_HOST '$hostName'."
    }

    if ($dbName -notmatch "(^|_)local($|_)") {
        throw "Refusing DB command because POSTGRES_DB '$dbName' has no local marker."
    }

    if ($databaseUrl -match "prod|production|staging|uat") {
        throw "Refusing DB command because DATABASE_URL appears to target non-local environment."
    }
}

function Get-RequiredTool {
    param([string]$Name)

    $tool = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $tool) {
        throw "Required tool '$Name' not found."
    }

    return $tool
}

function Get-PostgresArgs {
    param([hashtable]$Config)

    return @{
        Host = Get-EnvValue $Config "POSTGRES_HOST" "localhost"
        Port = Get-EnvValue $Config "POSTGRES_PORT" "5432"
        Database = Get-EnvValue $Config "POSTGRES_DB" "ginsengfood_operational_local"
        User = Get-EnvValue $Config "POSTGRES_USER" "ginsengfood_local"
        Password = Get-EnvValue $Config "POSTGRES_PASSWORD"
    }
}

function Set-PostgresPassword {
    param([hashtable]$Args)

    if ($Args.Password -and $Args.Password -notlike "__set*") {
        $env:PGPASSWORD = $Args.Password
    }
}
