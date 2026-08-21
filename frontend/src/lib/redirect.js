/**
 * Safe in-app path for ?next= (mobile checkout handoff).
 * Only same-origin relative paths; blocks protocol-relative and external URLs.
 */
export function safeNextPath(raw) {
  if (!raw || typeof raw !== "string") return null;
  const path = raw.trim();
  if (!path.startsWith("/")) return null;
  if (path.startsWith("//") || path.includes("\\")) return null;
  if (path.includes("://")) return null;
  return path;
}

export function defaultPathForRole(role) {
  if (role === "admin") return "/admin/dashboard";
  if (role === "reseller") return "/reseller/dashboard";
  return "/";
}
