---
name: powershell-scripting
description: Use when creating, modifying, or refactoring PowerShell scripts that require production-quality standards including OOP architecture, guard-clause validation, fail-fast error handling, comprehensive parameter validation, and parameterized design for reusability.
---

# PowerShell Script Development

## Objective

Produce production-quality PowerShell scripts that are testable, maintainable, extensible, and follow explicit structural and naming conventions.

## Scope

**In-scope:**

- Creation of new PowerShell scripts and script modules
- Refactoring existing procedural PowerShell code into structured patterns
- Classes and object-oriented design for PowerShell
- Function parameter validation and parameterized design
- Error handling and fail-fast patterns
- Naming conventions for functions, variables, classes, and parameters
- Script-level parameterization and configuration management
- Documentation and code clarity standards

**Out-of-scope:**

- PowerShell module manifests (.psd1 files)
- Desired State Configuration (DSC) resources
- WinRM and remoting configuration
- PowerShell Workflows
- Non-Windows PowerShell Core considerations (use PowerShell 7+ standards)
- Advanced debugging and profiling techniques

## Inputs

**Required inputs:**

- PowerShell script file (new or existing .ps1 file)
- Purpose and functional requirements
- Whether this is new development or refactoring existing code

**Optional inputs:**

- Existing script structure or patterns to build upon
- Specific domain context (registry operations, file management, etc.)
- Performance or scalability constraints

**Assumptions:**

- PowerShell 7+ is available on target system
- Windows environment (not cross-platform Core considerations)
- User has administrative access when required by script function
- Standard PowerShell execution policies are in place

## Outputs

**Format:** Production-quality PowerShell script files (.ps1) meeting all validation criteria.

**Structure:**

Scripts contain the following ordered sections:

1. YAML frontmatter (if this is an agent skill)
2. Constants (global scope only)
3. Classes (all business logic)
4. Helper functions (all except Main)
5. Main function (defined last)
6. Single Main invocation

**Files produced:**

- Primary script file: `[Name].ps1`
- All scripts include inline documentation with `<# #>` comment blocks
- Complete parameter validation with attributes
- Comprehensive error messages with process context

**Formatting requirements:**

- PascalCase for parameters and variables
- PascalCase for class names
- Verb-Noun naming for all functions (using approved PowerShell verbs)
- Maximum 3 levels of nesting in control flow
- One blank line between functions/classes
- Clear guard clauses at function entry points

## Constraints

**MUST:**

- Encapsulate all business logic in classes, not procedural functions
- Validate all script parameters with attributes before execution
- Place exactly zero procedural logic at global scope (only constants and structure)
- Define the Main function last, immediately before the Main invocation
- Throw errors immediately for invalid preconditions (fail-fast pattern)
- Include `<# #>` documentation for all classes and methods
- Use guard clauses (not mid-function exits) for validation
- Use specific exception types in catch blocks (never bare `catch { }`)
- Use exact error messages including process context, cause, and solution
- Return one result type per function; avoid multi-value implicit returns

**MUST NOT:**

- Place procedural processing logic at global scope
- Hard-code registry paths, file paths, or configuration values
- Use `return` statements in the middle of functions
- Catch errors without handling or re-throwing them
- Use Write-Host for diagnostic/verbose output (use Write-Verbose instead)
- Reimplement functionality already available in utility functions
- Create scripts that require editing to change behavior (parameterize instead)

**MAY:**

- Use fallback options only when primary solution is expected to fail in normal scenarios
- Implement CmdletBinding for advanced features like -WhatIf or -Confirm
- Create private helper methods prefixed with underscore
- Use verbose logging with Write-Verbose when expensive diagnostics are needed

## Procedure

Follow these steps sequentially to create production-quality PowerShell scripts:

1. **Define script purpose and parameters** - Identify what the script does, what inputs it accepts, and what configuration can change
2. **Design classes** - Create classes that encapsulate related data and behavior; identify state and methods needed
3. **Document all classes and methods** - Write `<# #>` documentation explaining purpose, parameters, return types
4. **Implement helper functions** - Extract reusable logic into named helper functions with complete parameter validation
5. **Implement Main function** - Define Main function to orchestrate classes and helper functions with all parameters
6. **Add parameter validation** - Use validation attributes (ValidateNotNullOrEmpty, ValidateSet, ValidateScript, etc.)
7. **Implement guard clauses** - Place all input validation at function start; throw errors for invalid preconditions
8. **Add error handling** - Use specific exception types; include process context, cause, and solution in error messages
9. **Implement fail-fast behavior** - Throw on invalid state immediately; avoid silent fallbacks except for documented expected scenarios
10. **Add verbose logging** - Use Write-Verbose with consistent context prefixes like `[ClassName.Method]`
11. **Apply naming conventions** - Use Verb-Noun for functions, PascalCase for variables, classes, and parameters
12. **Verify structure** - Check that script contains only: constants, classes, helpers, Main, then Main invocation
13. **Add single Main invocation** - Invoke Main with script parameters passed via $PSBoundParameters
14. **Test with parameters** - Call script with different parameter values to verify behavior without editing code

## Validation

**Pass Conditions (all required):**

- Script structure follows ordered template (constants, classes, helpers, Main, invocation)
- All functions and classes include documentation explaining purpose, parameters, and return types
- All parameters have validation attributes and defaults
- All functions use guard clauses and single exit point
- No procedural logic exists at global scope (except Main invocation)
- All errors include process context, what failed, why, and how to fix
- All functions use specific exception types in catch blocks
- Naming conventions are consistent throughout (Verb-Noun, PascalCase for variables)
- No hard-coded values for paths, registry keys, or configuration
- Maximum nesting depth is 3 levels; complex logic extracted to methods

**Failure Modes:**

- Script fails validation if procedural logic exists at global scope
- Script fails validation if any function lacks guard clauses
- Script fails validation if any parameter lacks validation attributes
- Script fails validation if catch blocks are generic without exception type
- Script fails validation if hard-coded values exist in functions or classes
- Script fails validation if documentation is missing for any class or method
- Script fails validation if nesting exceeds 3 levels

**Verification Checklist:**

- [ ] Script Parameters: Script accepts parameters via param() block; not hard-coded
- [ ] Script Structure: Constants in global scope; classes and functions defined; single Main function call
- [ ] Minimal Global Scope: No procedural logic at module level (except Main invocation)
- [ ] Parameter Validation: Script parameters have validation attributes and defaults
- [ ] OOP: Complex logic is in classes, not scattered functions
- [ ] Documentation: All classes and methods have documentation explaining purpose, parameters, return values
- [ ] Nesting: Code depth doesn't exceed 3 levels; complex nested logic extracted to helper methods
- [ ] Error Messages: Include process context, what failed, why, and how to fix
- [ ] Guard Clauses: Function starts with input validation checks
- [ ] Single Exit: Function has exactly one return/exit statement (at the end)
- [ ] Fail Fast: Errors thrown immediately for invalid preconditions; no silent failures
- [ ] Naming: Functions use Verb-Noun; variables/parameters use PascalCase
- [ ] No Hard Coding: Registry paths, file paths, and configuration values are parameters or constants
- [ ] CmdletBinding: Functions use `[CmdletBinding()]` if they support advanced features
- [ ] Error Handling: Specific exception types caught (not generic catch-all)
- [ ] Logging: Uses `Write-Verbose`, `Write-Warning`, `Write-Error` appropriately

## Persona

### Production-Quality Code First Architect

You have 8+ years building PowerShell solutions that must run reliably in production without modification. You approach all design decisions by asking "How will this behave when called with different parameters in production?" before considering convenience.

You prioritize testability and reusability: code that cannot be tested or reused is unfinished. You are skeptical of global scope state and hard-coded values but trust parameterized, class-based designs. You demand explicit parameter validation and guard clauses at function entry—defensive programming prevents silent failures.

When facing tradeoffs, you choose maintainability and clarity over clever shortcuts. You structure code for the next developer (who may be you in 6 months). You encapsulate complexity in classes and extract nested logic into named methods—shallow nesting and single responsibility make code readable and verifiable.

## Core Design Principles

Production-quality PowerShell rests on four non-negotiable pillars:

1. **OOP First** - Encapsulate functionality in classes; avoid procedural scripts
2. **Guard Clauses** - Validate inputs at function entry; throw errors immediately
3. **Fail Fast** - Error on invalid preconditions; no silent fallbacks except documented expected scenarios
4. **Parameterization** - Customize behavior via parameters; never hard-code values

## Script Structure

Scripts must follow this exact ordered structure:

```powershell
# Constants (global scope only)
[string]$BasePath = "HKLM:\Software"
[int]$MaxRetries = 3

# Classes (all business logic)
class RegistryProcessor {
    # Implementation
}

# Helper functions (except Main)
function Invoke-Processing {
    param([string]$Path)
    # Implementation
}

# Main function (defined last)
function Main {
    param([string]$Path = $BasePath)
    # Implementation
}

# Single entry point
Main @PSBoundParameters
```

**Violations:**

- Do NOT place processing logic at global scope
- Do NOT define Main in the middle of the script
- Do NOT invoke functions before they are defined (except via function names in code)

## Object-Oriented Programming

All business logic belongs in classes. Classes provide:

- **State management** - Properties for data that persists across method calls
- **Encapsulation** - Private helper methods prefixed with underscore
- **Clarity** - Related data and behavior grouped together
- **Testability** - Methods can be called with different inputs and verified

**When to use classes:**

- When managing state (like `$BasePath` or `$BackupEnabled`)
- When grouping related operations (registry, file, or API operations)
- When you need multiple instances with different configurations
- When logic would benefit from private helper methods

Example registry manager:

```powershell
class RegistryManager {
    [string]$BasePath
    [bool]$BackupEnabled

    RegistryManager([string]$path) {
        $this.BasePath = $path
        $this.BackupEnabled = $true
    }

    [bool] KeyExists([string]$keyPath) {
        $fullPath = Join-Path $this.BasePath $keyPath
        return Test-Path -Path $fullPath
    }

    [void] CreateKey([string]$keyPath) {
        $fullPath = Join-Path $this.BasePath $keyPath
        New-Item -Path $fullPath -Force | Out-Null
    }
}
```

**Documentation requirement:** All classes and methods must include `<# #>` documentation.

```powershell
<#
.SYNOPSIS
Manages registry operations with validation and error handling.

.DESCRIPTION
This class provides methods to read and write registry keys and values
with comprehensive permission and existence validation.
#>
class RegistryManager {
    [string]$BasePath

    <#
    .SYNOPSIS
    Initialize a new RegistryManager instance.

    .PARAMETER Path
    The registry path to manage (e.g., 'HKLM:\Software\MyApp')
    #>
    RegistryManager([string]$path) {
        $this.BasePath = $path
    }

    <#
    .SYNOPSIS
    Check if a registry key exists.

    .PARAMETER KeyPath
    The relative path to the key (relative to BasePath)

    .OUTPUTS
    [bool] $true if key exists, $false otherwise
    #>
    [bool] KeyExists([string]$keyPath) {
        $fullPath = Join-Path $this.BasePath $keyPath
        return Test-Path -Path $fullPath
    }
}
```

## Guard Clauses and Fail-Fast Error Handling

Guard clauses validate inputs at the function start. They throw immediately when preconditions fail.

**Structure every function this way:**

1. Guard clauses (input validation) - First statements in function
2. Main logic - If all guards pass, execute logic
3. Single return/exit - One point of exit at function end

Example:

```powershell
function Set-RegistryValue {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [object]$Value
    )

    # Guard clauses (all at top)
    if (-not (Test-Path $Path)) {
        throw "Registry path does not exist: '$Path'"
    }

    # Main logic
    try {
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -ErrorAction Stop
        return $true
    }
    catch [UnauthorizedAccessException] {
        throw "Insufficient permissions to modify registry: '$Path'. Run as administrator."
    }
    catch {
        throw "Failed to set registry value '$Name' in '$Path': $($_.Exception.Message)"
    }
}
```

**Error messages must include:**

- What was being attempted (the process)
- What went wrong (specific error)
- Where it happened (path, key, value name)
- Why it failed (underlying cause)
- How to fix it (remediation step if known)

Example error message:

```text
Failed to set registry value.
Process: Setting 'DisableAutoUpdate' = '1' in 'HKLM:\Software\MyApp'
Error: Access to the registry key 'HKLM\Software\MyApp' is denied.
Cause: Current user lacks registry write permissions
Solution: Run PowerShell as Administrator or grant permissions to current user
```

## Parameter Validation

All function parameters must be validated using attributes. Never validate inside function logic.

```powershell
function New-RegistryBackup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$RegistryPath,

        [Parameter()]
        [ValidateScript({ Test-Path $_ -IsValid })]
        [string]$BackupPath = "$env:TEMP\RegistryBackup",

        [Parameter()]
        [ValidateSet('Full', 'Incremental')]
        [string]$BackupType = 'Full',

        [Parameter()]
        [ValidateRange(1, 365)]
        [int]$RetentionDays = 30
    )

    process {
        # All parameters are now validated; no validation code needed inside function
    }
}
```

**Use these validation attributes:**

- `[ValidateNotNullOrEmpty()]` - For required strings
- `[ValidateSet(...)]` - For restricted values (enums)
- `[ValidateRange(min, max)]` - For numeric boundaries
- `[ValidateScript({...})]` - For complex validation logic
- `[ValidatePattern(...)]` - For regex patterns

## Naming Conventions

Follow these conventions consistently:

| Element         | Convention                      | Examples                                                    |
| --------------- | ------------------------------- | ----------------------------------------------------------- |
| Functions       | Verb-Noun (approved verbs only) | `Get-RegistryValue`, `Set-WindowsTheme`, `Invoke-Operation` |
| Parameters      | PascalCase                      | `$RegistryPath`, `$ValueName`, `$BackupLocation`            |
| Variables       | PascalCase                      | `$UserChoice`, `$BackupPath`, `$ConfigSettings`             |
| Classes         | PascalCase                      | `RegistryManager`, `ThemeConfiguration`, `FileProcessor`    |
| Private members | Underscore prefix               | `$_backupPath`, `_ValidateInput()`                          |

Do NOT use camelCase, snake_case, or UPPERCASE for variables/parameters.

## Code Organization and Nesting

Keep nesting shallow. Extract nested logic into named methods when nesting exceeds 2 levels.

**Anti-pattern (5 levels of nesting):**

```powershell
foreach ($key in $keys) {
    if ($key.Valid) {
        foreach ($subkey in $key.SubKeys) {
            if ($subkey.Enabled) {
                foreach ($value in $subkey.Values) {
                    if ($value.Important) {
                        # Too deep - hard to follow
                    }
                }
            }
        }
    }
}
```

**Correct approach (max 2 levels via extraction):**

```powershell
class RegistryProcessor {
    [void] ProcessKeys([array]$keys) {
        foreach ($key in $keys) {
            $this._ProcessSingleKey($key)
        }
    }

    hidden [void] _ProcessSingleKey([object]$key) {
        if (-not $key.Valid) { return }
        $this._ProcessSubKeys($key.SubKeys)
    }

    hidden [void] _ProcessSubKeys([array]$subKeys) {
        foreach ($subkey in $subKeys) {
            if (-not $subkey.Enabled) { continue }
            $this._ProcessValues($subkey.Values)
        }
    }

    hidden [void] _ProcessValues([array]$values) {
        foreach ($value in $values) {
            if ($value.Important) {
                $this._HandleImportantValue($value)
            }
        }
    }

    hidden [void] _HandleImportantValue([object]$value) {
        # Processing logic here - clear and shallow nesting
    }
}
```

## Error Handling

Use specific exception types. Never use bare `catch { }` without handling.

```powershell
class ConfigurationManager {
    [void] ApplyConfiguration([hashtable]$Config) {
        if ($null -eq $Config -or $Config.Count -eq 0) {
            throw [ArgumentException]::new("Configuration cannot be null or empty")
        }

        try {
            foreach ($key in $Config.Keys) {
                $this._ApplyConfigItem($key, $Config[$key])
            }
        }
        catch [UnauthorizedAccessException] {
            throw "Insufficient permissions to apply configuration. Run as administrator."
        }
        catch {
            throw "Failed to apply configuration: $($_.Exception.Message)"
        }
    }

    hidden [void] _ApplyConfigItem([string]$key, [object]$value) {
        # Implementation
    }
}
```

## Script Parameters and Customization

Scripts must accept configuration via parameters, not hard-coded values.

```powershell
[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Registry path to process")]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$RegistryPath = "HKLM:\Software\MyApp",

    [Parameter(HelpMessage = "Enable automatic backup before modifications")]
    [bool]$BackupEnabled = $true,

    [Parameter(HelpMessage = "Backup location")]
    [ValidateScript({ Test-Path (Split-Path $_) -PathType Container })]
    [string]$BackupPath = "$env:TEMP\RegistryBackup",

    [Parameter(HelpMessage = "Verbosity level")]
    [ValidateSet('Verbose', 'Normal', 'Silent')]
    [string]$LogLevel = 'Normal'
)

# Constants (non-configurable infrastructure)
[string]$ScriptVersion = "1.0.0"
[int]$MaxRetries = 3

# Classes and functions...

function Main {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter()]
        [bool]$BackupEnabled
    )

    # Implementation
}

# Pass script parameters to Main
Main -Path $RegistryPath -BackupEnabled $BackupEnabled
```

**How to invoke with custom parameters:**

```powershell
# Use defaults
.\MyScript.ps1

# Override specific parameters
.\MyScript.ps1 -RegistryPath "HKCU:\Software\MyApp"

# Override multiple parameters
.\MyScript.ps1 -RegistryPath "HKCU:\Software\MyApp" -BackupEnabled $false -LogLevel 'Verbose'
```

## Verbose Logging

Use `Write-Verbose` for diagnostic output. Do NOT use `Write-Host` for verbose logging.

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$RegistryPath
)

function Get-ExtensionItems {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RegistryPath
    )

    Write-Verbose "[Get-ExtensionItems] Starting enumeration: $RegistryPath"

    $items = Get-ChildItem -Path $RegistryPath -ErrorAction Stop
    Write-Verbose "[Get-ExtensionItems] Found $($items.Count) items"

    return $items
}

function Main {
    param([string]$Path)

    if ($VerbosePreference -eq 'Continue') {
        # Expensive diagnostics only in verbose mode
        $null = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
        Write-Verbose "[Main] Performed diagnostic scan on: $Path"
    }

    Get-ExtensionItems -RegistryPath $Path
}

# Call with -Verbose to enable verbose logging
Main @PSBoundParameters
```

## Advanced Patterns

### Pipeline Support

Enable functions to work in PowerShell pipelines:

```powershell
function Set-RegistryValues {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [hashtable]$Values
    )

    begin {
        Write-Verbose "Starting registry value updates"
    }

    process {
        foreach ($key in $Values.Keys) {
            Set-ItemProperty -Path $Path -Name $key -Value $Values[$key]
        }
    }

    end {
        Write-Verbose "Completed registry value updates"
    }
}
```

### CmdletBinding for Advanced Features

Use `[CmdletBinding()]` to enable -WhatIf, -Confirm, and other advanced features:

```powershell
function Import-RegistryFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path,

        [Parameter()]
        [switch]$CreateBackup,

        [Parameter()]
        [string]$BackupPath
    )

    begin {
        if ($CreateBackup -and [string]::IsNullOrWhiteSpace($BackupPath)) {
            $BackupPath = "$env:TEMP\RegistryBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess($Path, "Import registry file")) {
            if ($CreateBackup) {
                # Create backup logic
            }

            # Import logic
        }
    }
}
```

## Examples and Application

This section demonstrates applying the skill to different development scenarios. Each example shows realistic input and expected output.

### Example 1: New Registry Management Script

**Scenario:** Create script to manage application registry settings with backup capability

**Expected Output Structure:**

```powershell
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$RegistryPath = "HKLM:\Software\MyApp",

    [Parameter()]
    [string]$BackupPath = "$env:TEMP\AppBackup"
)

<#
.SYNOPSIS
Manages application registry settings with backup support.
#>
class RegistryManager {
    [string]$RegistryPath
    [string]$BackupPath

    RegistryManager([string]$regPath, [string]$backupPath) {
        $this.RegistryPath = $regPath
        $this.BackupPath = $backupPath
    }

    <#
    .SYNOPSIS
    Create a registry backup.
    #>
    [void] BackupRegistry() {
        Write-Verbose "[RegistryManager.BackupRegistry] Creating backup: $($this.BackupPath)"

        if (-not (Test-Path $this.BackupPath)) {
            New-Item -Path $this.BackupPath -ItemType Directory -Force | Out-Null
        }

        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = Join-Path $this.BackupPath "Backup_$timestamp.reg"

        try {
            reg export $this.RegistryPath $backupFile /y | Out-Null
            Write-Verbose "[RegistryManager.BackupRegistry] Backup created: $backupFile"
        }
        catch {
            throw "Failed to create registry backup: $($_.Exception.Message)"
        }
    }
}

function Main {
    param(
        [Parameter(Mandatory)]
        [string]$RegistryPath,

        [Parameter()]
        [string]$BackupPath
    )

    if ([string]::IsNullOrWhiteSpace($BackupPath)) {
        throw "BackupPath cannot be empty"
    }

    $manager = [RegistryManager]::new($RegistryPath, $BackupPath)
    $manager.BackupRegistry()
}

Main -RegistryPath $RegistryPath -BackupPath $BackupPath
```

### Example 2: Refactoring Procedural Script

**Before (Procedural):**

```powershell
$BasePath = "HKLM:\Software\MyApp"
$items = Get-ChildItem $BasePath
foreach ($item in $items) {
    $name = $item.PSChildName
    $value = Get-ItemProperty -Path $item.PSPath
    if ($value.Enabled -eq 1) {
        Write-Host "Found: $name"
    }
}
```

**After (Refactored):**

```powershell
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$RegistryPath = "HKLM:\Software\MyApp"
)

class RegistryScanner {
    [string]$BasePath

    RegistryScanner([string]$path) {
        if (-not (Test-Path $path)) {
            throw "Registry path not found: $path"
        }
        $this.BasePath = $path
    }

    <#
    .SYNOPSIS
    Find all enabled items in the registry path.

    .OUTPUTS
    [array] Array of enabled item names
    #>
    [array] FindEnabledItems() {
        Write-Verbose "[RegistryScanner.FindEnabledItems] Scanning: $($this.BasePath)"

        $items = Get-ChildItem -Path $this.BasePath -ErrorAction Stop
        $enabledItems = @()

        foreach ($item in $items) {
            if ($this._IsItemEnabled($item.PSPath)) {
                $enabledItems += $item.PSChildName
            }
        }

        Write-Verbose "[RegistryScanner.FindEnabledItems] Found $($enabledItems.Count) enabled items"
        return $enabledItems
    }

    hidden [bool] _IsItemEnabled([string]$itemPath) {
        try {
            $value = Get-ItemProperty -Path $itemPath -Name "Enabled" -ErrorAction SilentlyContinue
            return $null -ne $value -and $value.Enabled -eq 1
        }
        catch {
            return $false
        }
    }
}

function Main {
    param([string]$RegistryPath)

    $scanner = [RegistryScanner]::new($RegistryPath)
    $enabledItems = $scanner.FindEnabledItems()

    Write-Verbose "[Main] Processing $($enabledItems.Count) items"
    foreach ($item in $enabledItems) {
        Write-Information "Found: $item"
    }
}

Main -RegistryPath $RegistryPath
```

### Example 3: Complex Logic with Shallow Nesting

**Scenario:** Process nested registry structure with error recovery and retry logic

**Expected Output (showing nesting extraction):**

```powershell
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$RegistryPath = "HKLM:\Software\MyApp"
)

class NestedRegistryProcessor {
    [string]$RegistryPath
    [int]$MaxRetries = 3

    NestedRegistryProcessor([string]$path) {
        $this.RegistryPath = $path
    }

    <#
    .SYNOPSIS
    Process all registry items and subkeys.
    #>
    [void] ProcessAllItems() {
        Write-Verbose "[NestedRegistryProcessor.ProcessAllItems] Starting"

        try {
            $items = Get-ChildItem -Path $this.RegistryPath -ErrorAction Stop
            foreach ($item in $items) {
                $this._ProcessSingleItem($item)
            }
        }
        catch {
            throw "Failed to process registry items: $($_.Exception.Message)"
        }
    }

    hidden [void] _ProcessSingleItem([object]$item) {
        $itemPath = $item.PSPath

        Write-Verbose "[NestedRegistryProcessor._ProcessSingleItem] Processing: $itemPath"

        try {
            $properties = Get-ItemProperty -Path $itemPath -ErrorAction Stop

            if ($this._ShouldProcess($properties)) {
                $this._ProcessProperties($itemPath, $properties)
            }
        }
        catch {
            Write-Verbose "[NestedRegistryProcessor._ProcessSingleItem] Error: $($_.Exception.Message)"
        }
    }

    hidden [bool] _ShouldProcess([object]$properties) {
        return $null -ne $properties -and $properties.Enabled -eq 1
    }

    hidden [void] _ProcessProperties([string]$itemPath, [object]$properties) {
        foreach ($property in $properties.PSObject.Properties) {
            if ($property.Name -notmatch "^PS") {
                $this._ApplyProperty($itemPath, $property)
            }
        }
    }

    hidden [void] _ApplyProperty([string]$itemPath, [System.Management.Automation.PSPropertyInfo]$property) {
        $retryCount = 0

        while ($retryCount -lt $this.MaxRetries) {
            try {
                Write-Verbose "[NestedRegistryProcessor._ApplyProperty] Setting $($property.Name)"
                # Apply property logic here
                return
            }
            catch {
                $retryCount++
                if ($retryCount -ge $this.MaxRetries) {
                    throw "Failed to apply property $($property.Name) after $($this.MaxRetries) retries"
                }
                Start-Sleep -Milliseconds 100
            }
        }
    }
}

function Main {
    param([string]$RegistryPath)

    $processor = [NestedRegistryProcessor]::new($RegistryPath)
    $processor.ProcessAllItems()
}

Main -RegistryPath $RegistryPath
```
