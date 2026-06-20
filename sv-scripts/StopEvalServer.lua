-- =============================================================================
-- StopEvalServer.lua
--
-- Terminates the EvalServer by writing "terminated" to the state file.
-- The server's polling loop will detect this and call SV:finish().
-- =============================================================================

STATE_FILE = "/tmp/svstudio-eval-state.txt"

function getClientInfo()
    return {
        name = "StopEvalServer",
        author = "Haruki Okada",
        category = "Eval",
        versionNumber = 1,
        minEditorVersion = 65540
    }
end

function main()
    local file = io.open(STATE_FILE, "w")
    if file then
        file:write("terminated")
        file:close()
        SV:print("EvalServer stop signal sent")
    else
        SV:showMessageBox("Error", "Failed to write state file")
    end
    SV:finish()
end
