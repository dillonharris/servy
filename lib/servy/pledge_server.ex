defmodule Servy.PledgeServer do
  @process_name :pledge_server

  # Client interface
  def start do
    IO.puts("Starting the pledge server...")
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @process_name)
    pid
  end

  def recent_pledges do
    send(@process_name, {self(), :recent_pledges})

    receive do
      {:response, pledges} ->
        pledges
    end
  end

  def create_pledge(name, amount) do
    send(@process_name, {self(), :create_pledge, name, amount})

    receive do
      {:response, status} ->
        status
    end
  end

  def total_pledged do
    send(@process_name, {self(), :total_pledged})

    receive do
      {:response, total} ->
        total
    end
  end

  # Server
  def listen_loop(state) do
    IO.puts("\nWaiting for a message...")

    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]
        send(sender, {:response, id})
        IO.puts("#{name} pledged #{amount}!")
        IO.puts("New state is #{inspect(new_state)}")
        listen_loop(new_state)

      {sender, :total_pledged} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
        send(sender, {:response, total})
        listen_loop(state)

      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        IO.puts("Sent pledges to #{inspect(sender)}")
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected messages: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
