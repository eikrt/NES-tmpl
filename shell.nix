with import <nixpkgs> { };

mkShell {

  # Package names can be found via https://search.nixos.org/packages
  nativeBuildInputs = [
    cc65
    fceux
    c64-debugger
  ];

  NIX_ENFORCE_PURITY = true;

  shellHook = ''
  '';
}
