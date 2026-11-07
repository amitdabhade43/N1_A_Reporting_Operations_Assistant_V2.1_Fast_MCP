# NinjaOne MCP Expert Agent (Markdown-driven)

A local FastAPI chat UI using Foundry Local as the model endpoint and NinjaOne MCP Streamable HTTP for tools. The model chooses tools dynamically; there is no fixed phrase router for inventory queries. Agent behavior is kept in Markdown files under `agent/`.

## Project contents

- `app.py` — generic runtime: Foundry client, MCP discovery, LangChain agent execution, API/UI endpoints.
- `agent/ninjaone-expert.md` — agent role and core behavior.
- `agent/instructions/*.md` — tool policy, data analysis, and response style.
- `static/index.html` — browser chat UI with tool activity and tool catalog.
- `.env.example` — configuration template.

## Requirements

- Python 3.11+ recommended.
- Foundry Local running with an OpenAI-compatible `/v1` endpoint and a model loaded.
- NinjaOne MCP server running with Streamable HTTP transport.
- The selected Foundry model must support tool calling. Vision input additionally requires a vision-capable model and compatible endpoint.

## Windows setup

Open PowerShell in this project folder:

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
Copy-Item .env.example .env
notepad .env
```

Edit `.env` using your actual Foundry endpoint/model IDs and MCP URL. Model IDs must match `GET <FOUNDRY_BASE_URL>/models` exactly. Example:

```env
FOUNDRY_BASE_URL=http://127.0.0.1:64414/v1
FOUNDRY_MODEL_PHI=YOUR_EXACT_MODEL_ID
FOUNDRY_MODEL_QWEN=YOUR_EXACT_VISION_MODEL_ID
MCP_URL=http://127.0.0.1:8000/mcp
```

Start the app:

```powershell
python -m uvicorn app:app --host 127.0.0.1 --port 8080
```

Open <http://127.0.0.1:8080>.

## Verify connections

- Foundry model list: `Invoke-RestMethod "$env:FOUNDRY_BASE_URL/models"` (or use the full URL from `.env`).
- App health: <http://127.0.0.1:8080/api/health>
- MCP tool catalog: <http://127.0.0.1:8080/api/tools>

If `/api/tools` fails, check the MCP URL and server. If chat fails with a model connection/tool-calling error, check Foundry Local status, loaded model ID, endpoint port, and model tool-calling compatibility.

## Customize agent behavior

Edit Markdown files under `agent/`. Restart the app after editing because instructions are loaded when each model agent is initialized. No Python change is needed for ordinary instruction/workflow changes.

## How it works

1. The app discovers tools dynamically from the MCP server.
2. The LLM receives the available tools and Markdown instructions.
3. The model selects and calls one or more tools.
4. Tool results are returned to the model for further reasoning/tool calls.
5. The model produces a tailored answer; the UI displays tool activity.

The agent can only answer with information/actions exposed by the connected MCP tools. Completeness depends on tool pagination and returned fields. The runtime does not bypass MCP permissions.

## Troubleshooting

- **`ModuleNotFoundError`**: activate `.venv` and run `pip install -r requirements.txt`.
- **MCP connection error**: verify `MCP_URL`, server process, and Streamable HTTP endpoint path.
- **Foundry connection error**: verify `FOUNDRY_BASE_URL`, active port, loaded model, and `/v1/models`.
- **Tool calls not made**: the selected model or endpoint may not support tool calling reliably. Test with a tool-capable model and confirm the tool catalog appears in `/api/tools`.
- **Incomplete counts**: use MCP total metadata or pagination support; the model cannot count records that the server did not return.


## NinjaOne domain skill and supplied tool notes

This project now loads `agent/skills/ninjaone-rmm/SKILL.md` and `agent/references/tool-catalog-notes.md` into the runtime system prompt. The skill guides tool selection, multi-tool data correlation, field-focused responses, pagination caveats, and confirmation for state-changing operations. The supplied tool list is a **partial reference**; the app discovers the actual available tools and schemas from the configured MCP server at runtime.

The skill does not create missing MCP capabilities. Any operation can only be performed if the connected MCP server exposes a corresponding tool and the server credentials/scopes permit it.

## Confirmed MCP compatibility

The NinjaOne guidance reflects the shared MCP server code (`app.py`, `ninjaone_api.py`, `config.py`): read-only list endpoints, device detail/components, and allowlisted query reports. Tools and schemas are discovered live from MCP. Generic `params` support does not imply identical filters or pagination across endpoints. The EU configuration values are defaults; use the tenant's actual region and `.env`.


# V2 — NinjaOne Reporting & Operations Assistant

V2 adds report exports, recurring schedules, report history, and optional SMTP delivery to the MCP-powered conversational agent.

## V2 capabilities
- Natural-language NinjaOne queries through live MCP tool discovery.
- Multi-tool agent workflows and conversational follow-up discussion.
- Export the latest assistant answer as CSV, styled Excel workbook, or designed PDF.
- Excel includes a report sheet and report-info sheet; PDF includes title, metadata, formatted content, and page footer.
- Create recurring reports using five-field cron syntax and a timezone.
- Scheduled jobs re-run the saved prompt against live NinjaOne MCP data on each execution.
- Pause/resume/delete schedules and inspect execution history through the API.
- Optional email attachments via SMTP.

## Run V2
Use the existing Windows setup steps above, then install the added dependencies:
```powershell
pip install -r requirements.txt
```
Configure `.env`, start the MCP server and Foundry Local model, then start this app. Open `http://127.0.0.1:8080`.

## Report export workflow
1. Ask the agent for the desired live report in chat.
2. Review the response and any caveats.
3. Select CSV/Excel/PDF format(s) and click **Export latest answer**.
4. Download the generated files from the links shown in chat.

The export currently formats the agent's latest answer text. It does not claim to reconstruct every raw API record from the model's narrative. For row-level structured exports, ask the agent to return a clear table and verify that all relevant pages/records were retrieved.

## Scheduled report workflow
In the Scheduled reports panel:
- Enter a schedule name.
- Enter the natural-language report prompt.
- Set a five-field cron expression (default `0 9 * * 1`, Mondays at 09:00).
- Optional email recipient requires SMTP configuration.
- Click **Create weekly schedule**.

Timezone is currently set to `Asia/Kolkata` in the UI. The API accepts an explicit timezone. Schedule management endpoints:
- `POST /api/reports/schedules`
- `GET /api/reports/schedules`
- `POST /api/reports/schedules/{id}/toggle?enabled=true|false`
- `DELETE /api/reports/schedules/{id}`
- `GET /api/reports/history`
- `POST /api/reports/generate`
- `GET /api/reports/files/{filename}`

### SMTP configuration (optional)
Set `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `SMTP_FROM`, and `SMTP_USE_TLS` in `.env`. Treat SMTP credentials as secrets. Email delivery is only attempted when a schedule has an email recipient and SMTP is configured.

## Operational notes and limitations
- Scheduled jobs run inside this app process. Keep the app running for schedules to execute. For production/multi-instance use, move scheduling to a dedicated worker and use a shared database/lock.
- SQLite stores schedule definitions and run history in `assistant_data.sqlite3`.
- Generated files are stored in `reports/`; protect this folder and configure retention/backups as appropriate.
- This local starter has no user authentication/authorization layer. Keep it bound to loopback or place it behind authenticated ingress before exposing it to a network.
- Report content is generated from agent responses. High-fidelity tabular export from structured API records is a future enhancement; the current Excel/PDF output is designed for polished narrative/report summaries.
- Schedules are intended for read-only reporting. Avoid prompts requesting changes/actions.
