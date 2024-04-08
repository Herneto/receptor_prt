defmodule PoolboyPRT.Worker do
  use GenServer
  require Logger
  require Jason

  def start_link(_) do
    {:ok, content} = ReceptorPRT.Config.load()
    {:ok, api} = Map.fetch(content, "api")
    GenServer.start_link(__MODULE__, api)
  end

  def init(api) do
    {:ok, api}
  end

  def handle_call({:http_request, prt_header, request}, _from, state) do
    %{
      "payment_url" => payment_url,
      "request_param" => request_param,
      "response_param" => response_param
    } = state

    request_body = Jason.decode!("{\"#{request_param}\": \"#{request}\"}")

    req =
        Req.new(
          url: payment_url,
          json: request_body,
          receive_timeout: 5000,
          connect_options: [timeout: 500]
        )

    response = Req.post(req)

    Logger.info("Performing HTTP request for: #{request}")

    case response do
      {:error, %Mint.TransportError{reason: reason}} ->
        Logger.info("Error on request #{request}: #{reason}")
      {:ok,resp} ->
        send(:pr, {:response, prt_header, resp.body["#{response_param}"]})
      _ ->
        Logger.info("Unknown result for request #{request}")
    end
    {:reply, nil, state}
  end
end
