bool truthy(v) => (v is bool) ? v : (v as String).toLowerCase() == "true";
