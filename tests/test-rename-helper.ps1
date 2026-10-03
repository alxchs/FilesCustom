# Test runner for FileNameExtensionHelper (MASTER_SPEC §5)
# Run from repository root: powershell -File tests/test-rename-helper.ps1

$helperPath = Join-Path $PSScriptRoot "..\src\Files.App\Helpers\FileNameExtensionHelper.cs"
if (-not (Test-Path $helperPath)) {
    Write-Error "Helper file not found at $helperPath"
    exit 1
}

$cs = @"
#nullable enable

$(Get-Content $helperPath -Raw)

public class RenameHelperTests {
    public static int RunAll() {
        var cases = new (string input, bool isFolder, bool isShortcut, string expName, string expExt)[] {
            ("arquivo.txt", false, false, "arquivo", ".txt"),
            ("arquivo.md", false, false, "arquivo", ".md"),
            ("arquivo", false, false, "arquivo", ""),
            ("arquivo.tar.gz", false, false, "arquivo", ".tar.gz"),
            ("arquivo.final.txt", false, false, "arquivo.final", ".txt"),
            ("arquivo final 01.txt", false, false, "arquivo final 01", ".txt"),
            ("arquivo.", false, false, "arquivo.", ""),
            (".gitignore", false, false, ".gitignore", ""),
            (".env", false, false, ".env", ""),
            (".env.local", false, false, ".env", ".local"),
            ("Folder A", true, false, "Folder A", ""),
            ("shortcut.lnk", false, true, "shortcut.lnk", ""),
            ("arquivo.txt.", false, false, "arquivo.txt.", ""),
            ("ARQUIVO.TAR.GZ", false, false, "ARQUIVO", ".TAR.GZ"),
            (".tar.gz", false, false, ".tar", ".gz"),
            ("a.b.c", false, false, "a.b", ".c"),
            ("", false, false, "", ""),
            ("archive.tar.bz2", false, false, "archive", ".tar.bz2"),
            ("archive.tar.xz", false, false, "archive", ".tar.xz"),
            ("archive.tar.zst", false, false, "archive", ".tar.zst")
        };
        int failed = 0;
        foreach (var c in cases) {
            var res = Files.App.Helpers.FileNameExtensionHelper.Split(c.input, c.isFolder, c.isShortcut);
            if (res.NamePart != c.expName || res.ExtensionPart != c.expExt) {
                Console.WriteLine($"[FAIL] '{c.input}' -> Name='{res.NamePart}', Ext='{res.ExtensionPart}' (Expected Name='{c.expName}', Ext='{c.expExt}')");
                failed++;
            } else {
                Console.WriteLine($"[PASS] '{c.input}' -> Name='{res.NamePart}', Ext='{res.ExtensionPart}', HasExt={res.HasExtension}");
            }
        }
        if (failed == 0) {
            Console.WriteLine($"\nAll {cases.Length} test cases passed successfully.");
        }
        return failed;
    }
}
"@

Add-Type -TypeDefinition $cs -Language CSharp
$res = [RenameHelperTests]::RunAll()
if ($res -ne 0) {
    Write-Error "Tests failed: $res failures."
    exit 1
} else {
    exit 0
}
