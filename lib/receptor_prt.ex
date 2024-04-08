defmodule ReceptorPRT do
  require Logger

  @request_timeout 5000

  def start(prt) do
    %{"host" => host, "port" => port, "session_id" => session_id} = prt

    host = host |> String.split(".") |> Enum.map(&String.to_integer(&1)) |> List.to_tuple()
    session_id = session_id |> Integer.to_string()
    {:ok, socket} = :gen_tcp.connect(host, port, [:binary, active: false])

    open_session(socket, session_id)
  end

  defp open_session(socket, session_id) do
    command = "APL=sibs.deswin.prt.PrtSrvGateway,PRTSES=#{session_id}"
    Logger.info("Opening session: #{command}")
    write(socket, command)

    case read(socket) do
      {:ok, ^session_id} ->
        Logger.info("Receiving Session (#{session_id}) opened")
        {:ok, pid} = Task.start_link(fn -> ReceptorPRT.handle_response(socket) end)
        Process.register(pid, :pr)
        loop_read(socket)

      _ ->
        Process.exit(self(), :kill)
    end
  end

  defp perform_request(prt_header, request) do
    Task.start(fn ->
        :poolboy.transaction(
          :worker,
          fn pid ->
            try do
              GenServer.call(pid, {:http_request, prt_header, request})
            catch
              e, r ->
                Logger.error("poolboy transaction caught error: #{inspect(e)}, #{inspect(r)}")
                :ok
            end
          end,
          @request_timeout
        )
      end)
  end

  def handle_response(socket) do
    receive do
      {:response, prt_header, response} ->
        Logger.info("Sending Response to PRT: #{response}")
        ReceptorPRT.write(socket, prt_header <> response)
      _ ->
        :error
    end
    handle_response(socket)
  end

  def loop_read(socket) do
    {:ok, data} = read(socket)
    <<prt_header::binary-size(12), request::binary>> = data
    Logger.info("Received from PRT: #{request}")

    perform_request(prt_header, request)
    loop_read(socket)
  end

  defp read(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 2)
    <<size::size(16)>> = data
    :gen_tcp.recv(socket, size - 2)
  end

  def write(socket, command) do
    size = String.length(command) + 2
    :gen_tcp.send(socket, <<size::16>>)
    :gen_tcp.send(socket, command)
  end

end
