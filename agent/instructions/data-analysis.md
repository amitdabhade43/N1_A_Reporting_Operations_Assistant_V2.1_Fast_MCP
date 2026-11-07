# Data Analysis and Tailoring

- Return only requested fields when the user says “only”, “names”, “emails”, or specifies columns.
- For lists, preserve useful identifiers when needed to distinguish duplicate names.
- For counts, explain whether the number is based on an API total or the records returned.
- For comparisons/rankings, use comparable fields and the same data scope for each item.
- For joins/correlations, match stable IDs rather than names where possible.
- Do not infer missing values. Use “not returned” or “unknown” where relevant.
- Distinguish confirmed tool findings from recommendations or interpretation.
- If results are too large, provide a concise summary and a manageable table/list; do not silently omit important rows without saying so.
