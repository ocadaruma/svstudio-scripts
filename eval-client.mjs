#!/usr/bin/env node

/**
 * eval-client.mjs
 *
 * CLI client for the SVStudio EvalServer.
 * Sends Lua code to the file-based RPC server and prints the result.
 *
 * Usage:
 *   node eval-client.mjs "code"           Eval a single line of Lua code
 *   node eval-client.mjs -c 'code'        Same as above (flag style)
 *   node eval-client.mjs -f file.lua      Eval code from a file
 *   node eval-client.mjs --ping           Check if server is alive
 *   node eval-client.mjs --status         Get server status
 *   node eval-client.mjs --stdin          Read code from stdin
 *   echo 'code' | node eval-client.mjs --stdin
 *
 * Environment variables (optional):
 *   COMMAND_FILE  Path to the command file (default: /tmp/svstudio-eval-command.json)
 *   RESPONSE_FILE Path to the response file (default: /tmp/svstudio-eval-response.json)
 *   TIMEOUT       Response timeout in ms (default: 10000)
 */

import fs from "fs/promises";
import path from "path";
import { createInterface } from "readline";

// Configuration
const COMMAND_FILE = process.env.COMMAND_FILE || "/tmp/svstudio-eval-command.json";
const RESPONSE_FILE = process.env.RESPONSE_FILE || "/tmp/svstudio-eval-response.json";
const RESPONSE_TIMEOUT = parseInt(process.env.TIMEOUT || "300000", 10);
const RESPONSE_POLL_INTERVAL = 500;

// Request ID counter
let requestIdCounter = 0;

/**
 * Generate a unique request ID.
 */
function generateRequestId() {
  return `req_${Date.now()}_${++requestIdCounter}`;
}

/**
 * Write a command to the command file.
 */
async function writeCommand(command) {
  try {
    await fs.writeFile(COMMAND_FILE, JSON.stringify(command));
  } catch (error) {
    throw new Error(`Failed to write command: ${error.message}`);
  }
}

/**
 * Wait for and read the response from the response file.
 */
async function readResponse() {
  const startTime = Date.now();

  while (Date.now() - startTime < RESPONSE_TIMEOUT) {
    try {
      await fs.access(RESPONSE_FILE);
    } catch {
      await sleep(RESPONSE_POLL_INTERVAL);
      continue;
    }

    try {
      const data = await fs.readFile(RESPONSE_FILE, "utf-8");
      // Clear the response file for next request
      await fs.writeFile(RESPONSE_FILE, "");
      return JSON.parse(data);
    } catch (parseError) {
      // Might be a race condition, retry
      await sleep(RESPONSE_POLL_INTERVAL);
    }
  }

  throw new Error(`Timeout waiting for response (${RESPONSE_TIMEOUT}ms)`);
}

/**
 * Send a command and wait for the response.
 */
async function sendCommand(action, params = {}) {
  const requestId = generateRequestId();
  const command = {
    requestId,
    action,
    ...params,
  };

  await writeCommand(command);

  // Small delay to let the server pick up the command
  await sleep(100);

  return await readResponse();
}

/**
 * Sleep for the given number of milliseconds.
 */
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Eval Lua code on the server.
 */
async function evalCode(code) {
  const response = await sendCommand("eval", { code });
  return response;
}

/**
 * Ping the server.
 */
async function ping() {
  const response = await sendCommand("ping");
  return response;
}

/**
 * Get server status.
 */
async function getStatus() {
  const response = await sendCommand("get_status");
  return response;
}

/**
 * Read all input from stdin.
 */
async function readStdin() {
  const rl = createInterface({ input: process.stdin });
  const chunks = [];
  for await (const line of rl) {
    chunks.push(line);
  }
  return chunks.join("\n");
}

/**
 * Format and print a response.
 */
function printResponse(response) {
  if (response.success) {
    const result = response.result;
    if (result === null || result === undefined) {
      console.log("(null)");
    } else if (typeof result === "object") {
      console.log(JSON.stringify(result, null, 2));
    } else {
      console.log(result);
    }
  } else {
    console.error(`Error: ${response.error || "Unknown error"}`);
    process.exitCode = 1;
  }
}

/**
 * Print usage information.
 */
function printUsage() {
  console.log(`
Usage: node eval-client.mjs [options] [code]

Options:
  -c, --code <code>      Lua code to evaluate
  -f, --file <file>      Path to a Lua file to evaluate
  --stdin                Read code from stdin
  --ping                 Check if the server is alive
  --status               Get server status and host info
  -h, --help             Show this help message

Examples:
  node eval-client.mjs "SV:print('hello')"
  node eval-client.mjs -c 'return SV:getProject():getDuration()'
  node eval-client.mjs -f script.lua
  echo 'return SV:getProject():getDuration()' | node eval-client.mjs --stdin
  node eval-client.mjs --ping
  node eval-client.mjs --status

Environment:
  COMMAND_FILE  Command file path (default: /tmp/svstudio-eval-command.json)
  RESPONSE_FILE Response file path (default: /tmp/svstudio-eval-response.json)
  TIMEOUT       Response timeout in ms (default: 10000)
`);
}

/**
 * Main entry point.
 */
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    printUsage();
    process.exit(0);
  }

  // Handle flags
  if (args.includes("-h") || args.includes("--help")) {
    printUsage();
    process.exit(0);
  }

  if (args.includes("--ping")) {
    const response = await ping();
    printResponse(response);
    return;
  }

  if (args.includes("--status")) {
    const response = await getStatus();
    printResponse(response);
    return;
  }

  // Get code to evaluate
  let code;

  if (args.includes("--stdin")) {
    code = await readStdin();
  } else {
    const fileIndex = args.indexOf("-f") !== -1 ? args.indexOf("-f") + 1 : args.indexOf("--file") + 1;
    if (fileIndex > 0 && fileIndex < args.length) {
      const filePath = args[fileIndex];
      code = await fs.readFile(filePath, "utf-8");
    } else {
      const codeIndex = args.indexOf("-c") !== -1 ? args.indexOf("-c") + 1 : args.indexOf("--code") + 1;
      if (codeIndex > 0 && codeIndex < args.length) {
        code = args[codeIndex];
      } else {
        // First positional argument is the code
        code = args[0];
      }
    }
  }

  if (!code || code.trim() === "") {
    console.error("Error: No code to evaluate");
    process.exit(1);
    return;
  }

  const response = await evalCode(code);
  printResponse(response);
}

main().catch((error) => {
  console.error(`Fatal: ${error.message}`);
  process.exit(1);
});
