const major = parseInt(process.versions.node.split(".")[0], 10);
if (major !== 22) {
  console.error(`
Village NetAcad backend requires Node.js 22 LTS (current: ${process.version}).

  nvm use          (if .nvmrc is present)
  .\\dev.ps1       (uses bundled Node 22 in Cursor)
  Or install Node 22: https://nodejs.org/
`);
  process.exit(1);
}
