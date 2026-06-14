local home = os.getenv("HOME")
local jdtls_path = home .. "/.local/share/nvim/mason/packages/jdtls"
local lombok_path = home .. "/.local/share/lombok/lombok.jar"

-- 1. Dynamically locate the equinox launcher jar (handles version updates gracefully)
local path_to_lsp_server = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

-- 2. Detect OS to map the correct configuration directory
local path_to_config = jdtls_path .. "/config_linux"

-- 3. Isolate workspaces per-project so multi-project editing doesn't clash
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local path_to_workspace = home .. "/.local/share/nvim/jdtls-workspace/" .. project_name

-- 4. Gather capabilities (handles standard auto-completion attachments)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if status_ok then
  capabilities = cmp_nvim_lsp.default_capabilities()
end

-- 5. Build the Execution Command
local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    
    -- INJECT LOMBOK AGENT BELOW:
    "-javaagent:" .. lombok_path,
    
    "-Dlog.level=ALL",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    
    "-jar", path_to_lsp_server,
    "-configuration", path_to_config,
    "-data", path_to_workspace,
  },
  root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
  capabilities = capabilities,
}

-- 6. Boot the Language Server!
require("jdtls").start_or_attach(config)
