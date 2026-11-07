# Supplied NinjaOne MCP tool catalog notes

These descriptions were supplied by the project owner and are a partial reference. The runtime must still discover actual tools and schemas from MCP. The names below are not hard-coded into Python and may differ from the connected server's current catalog.

## Tools in the supplied excerpt

- `ninjaone_rmm_approve_devices`: approve/reject pending devices; mode is an upstream path segment and request body carries device IDs.
- `ninjaone_rmm_create_staged_device`: stage a device for enrollment.
- `ninjaone_rmm_delete_asset_relationship`: delete an ITAM asset relationship.
- `ninjaone_rmm_delete_asset_tag`: delete asset tags by ID or bulk operation.
- `ninjaone_rmm_delete_checklist_template`: delete a checklist template or bulk-delete templates.
- `ninjaone_rmm_delete_contact`: permanently delete a contact.
- `ninjaone_rmm_delete_custom_tab`: delete a custom tab.
- `ninjaone_rmm_delete_document_template`: delete a document template.
- `ninjaone_rmm_delete_knowledge_base_article`: delete knowledge-base articles.
- `ninjaone_rmm_delete_node_role`: delete node roles.
- `ninjaone_rmm_delete_organization_document`: delete an organization document.
- `ninjaone_rmm_delete_policy_condition`: delete a policy condition using policy and condition IDs.
- `ninjaone_rmm_delete_related_item`: delete a related item by ID or entity pair.
- `ninjaone_rmm_delete_software_license`: delete a software license.
- `ninjaone_rmm_delete_unmanaged_device`: delete an unmanaged ITAM device.
- `ninjaone_rmm_delete_user`: delete a technician or end-user; user type must match the account class.
- `ninjaone_rmm_delete_webhook`: remove the tenant webhook.
- `ninjaone_rmm_generate_installer`: generate an organization installer or retrieve a location installer.
- `ninjaone_rmm_get_activities`: list tenant-wide or device activities; paginate using `lastActivityId` as `after` when exposed.
- `ninjaone_rmm_get_alerts`: list open alerts tenant-wide or for a device.
- `ninjaone_rmm_get_asset_relationship`: list relationship types, all relationships, or relationships for an entity.
- `ninjaone_rmm_get_asset_tag`: list ITAM asset tags.
- `ninjaone_rmm_get_automation_scripts`: list scripts or device scripting options.
- `ninjaone_rmm_get_backup_jobs`: list backup or integrity-check jobs.
- `ninjaone_rmm_get_checklist_template`: list checklist templates or retrieve a template by ID when supported.

## Safety classification

The supplied excerpt includes read operations, creation/staging, approval/rejection, and deletion operations. Treat any write/delete/action tool as state-changing. Confirm the exact target and requested operation before executing, and rely on the live tool schema for required arguments.

## Current tools confirmed from the owner's MCP `app.py`

These are the confirmed wrapper names from the shared MCP server code. Live MCP discovery remains authoritative for actual schemas.

### Explicit tools
- `list_users` — GET `/v2/users`
- `list_technicians` — GET `/v2/user/technicians`
- `list_devices` — GET `/v2/devices`; supports `page_size` (1–500) and `after`
- `get_device` — GET `/v2/device/{device_id}`
- `list_organizations` — GET `/v2/organizations`
- `list_roles` — GET `/v2/roles`
- `list_user_roles` — GET `/v2/user/roles`
- `get_query_report` — GET `/v2/queries/{report_name}`; report name is allowlisted
- `get_device_component` — GET `/v2/device/{device_id}/{component}`; component is allowlisted

### Dynamically registered read-only tools
Each accepts optional `params` query parameters:
- `list_groups` — `/v2/groups`
- `list_locations` — `/v2/locations`
- `list_policies` — `/v2/policies`
- `list_activities` — `/v2/activities`
- `list_alerts` — `/v2/alerts`
- `list_jobs` — `/v2/jobs`
- `list_tasks` — `/v2/tasks`
- `list_automation_scripts` — `/v2/automation/scripts`
- `list_contacts` — `/v2/contacts`
- `list_custom_field_definitions` — `/v2/device-custom-fields`
- `list_custom_tabs` — `/v2/custom-tabs`
- `list_document_templates` — `/v2/document-templates`
- `list_knowledge_base_articles` — `/v2/knowledgebase/articles`
- `list_software_products` — `/v2/software-products`
- `list_software_licenses` — `/v2/software-licenses`
- `list_vulnerability_scan_groups` — `/v2/vulnerability-scan-groups`
- `list_asset_tags` — `/v2/asset-tags`
- `list_asset_relationships` — `/v2/asset-relationships`
- `list_related_items` — `/v2/related-items`
- `list_organization_documents` — `/v2/organization-documents`
- `list_node_roles` — `/v2/node-roles`
- `list_backup_jobs` — `/v2/backup/jobs`

### Query report allowlist
`antivirus_status`, `antivirus_threats`, `backup_usage`, `computer_systems`, `custom_fields`, `custom_fields_detailed`, `device_health`, `disks`, `logged_on_users`, `network_interfaces`, `operating_systems`, `os_patch_installs`, `os_patches`, `policy_overrides`, `processors`, `raid_controllers`, `raid_drives`, `scoped_custom_fields`, `scoped_custom_fields_detailed`, `software`, `software_patch_installs`, `software_patches`, `volumes`, `windows_services`.

### Device component allowlist
`summary`, `software`, `os_patches`, `software_patches`, `os_patch_installs`, `software_patch_installs`, `disks`, `volumes`, `processors`, `network_interfaces`, `windows_services`, `last_logged_on_user`, `custom_fields`, `policy_overrides`.

### Client/config notes
- The shared API client uses OAuth client credentials, token caching, and an async lock for refresh.
- `ninjaone_api.get()` is read-only and restricts paths to `/v2/`; MCP wrappers use fixed paths and allowlists.
- `config.py` defaults to EU API/token endpoints and `monitoring` scope. Use the user's actual `.env` and tenant region.
- Generic `params` does not imply all endpoints support the same filters or pagination. Only `list_devices` explicitly exposes `page_size` and `after` in the shared code.
- The shared MCP implementation is currently read-only. Do not assume tools from the earlier partial write/delete catalog are available unless live MCP discovery shows them.
