# onepacerr-ui

Elm dashboard for OnePacerr, distributed as a static web package through a Nix
flake.

## Package

Build the production bundle with:

```console
nix build
```

The web root is available at:

```text
result/share/onepacerr-ui
```

The flake exposes the same derivation as `packages.<system>.default`,
`packages.<system>.frontend`, and `packages.<system>.onepacerr-ui`.

The package deliberately does not select or configure a web server. Consumers
can serve it with Caddy, nginx, Apache, a container, or another static server.
The deployment server must:

1. Serve the package's `share/onepacerr-ui` directory.
2. Fall back to `index.html` for frontend routes.
3. Proxy browser requests from `/api/*` to OnePacerr's `/api/v1/*` endpoints.

## Development

Enter the development shell and run Vite:

```console
nix develop
npm run dev
```

Vite serves the UI at `http://localhost:5173` and uses the development proxy in
`vite.config.js`.

## NixOS integration

Add the flake as an input and follow the deployment's nixpkgs input:

```nix
inputs.onepacerr-ui = {
  url = "github:nixypanda/onepacerr-ui";
  inputs.nixpkgs.follows = "nixpkgs-unstable";
};
```

Pass the input to the deployment modules, for example with `specialArgs`:

```nix
nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit onepacerr-ui; };
  modules = [ ./configuration.nix ];
};
```

Then select the package in the host's web-server configuration:

```nix
{ onepacerr-ui, pkgs, ... }:

let
  webRoot = "${onepacerr-ui.packages.${pkgs.system}.frontend}/share/onepacerr-ui";
in
{
  # Configure the web server of your choice with webRoot.
}
```

### Caddy example

This mirrors the existing CalCo pattern in the Rivendell dotfiles: TLS and
routing remain host-owned policy.

```nix
services.caddy.virtualHosts."onepacerr.example.com".extraConfig = ''
  handle /api/* {
    uri replace /api/ /api/v1/
    reverse_proxy 127.0.0.1:3010
  }
  handle /assets/* {
    root * ${webRoot}
    header Cache-Control "public, max-age=31536000, immutable"
    file_server
  }
  handle {
    root * ${webRoot}
    header Cache-Control "no-cache"
    try_files {path} /index.html
    file_server
  }
'';
```

### nginx example

```nix
services.nginx.virtualHosts."onepacerr.example.com" = {
  root = webRoot;
  locations."/".tryFiles = "$uri $uri/ /index.html";
  locations."/api/".proxyPass = "http://127.0.0.1:3010/api/v1/";
};
```
