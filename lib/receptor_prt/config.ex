defmodule ReceptorPRT.Config do
  def load do
    path = Path.join(File.cwd!(), "receptor_app.yaml")
    YamlElixir.read_from_file(path)
  end
end
