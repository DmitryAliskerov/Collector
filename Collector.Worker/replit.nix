{ pkgs }: {
	deps = [
		pkgs.libcap
  pkgs.elixir
        pkgs.elixir_ls
        pkgs.sqlite
        pkgs.inotify-tools
	];
}